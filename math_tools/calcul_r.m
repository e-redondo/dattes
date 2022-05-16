function [Rp, R_I,Rt,RDoD,Rdt,err] = calcul_r(t,U,I,DoDAh,instant_end_rest,duration_pulse,duration_repos,t_calcul_R,graph)
%--------------------------------------------------------------------------
%function [Rp, R_I,Rt,RDoD,Rdt,err] = calcul_r(t,U,I,DoDAh,instant_end_rest,duration_pulse,duration_repos,t_calcul_R,graph)
% fonction pour calculer la resistance vu par un pulse
% vu le front montant(impulsion) de courant du pulse, on va interpoller separement les
% points de la phase de repos et les points de la phase pulse pour
% retrouver des points estimes sur le front montant
%
% -------------------------------------------------------------------------
%       VARIABLES D ENTREE
% t,I,U: sont des vecteurs contenant des informations du repos + pulse
% les informations du repos viennent en premier
% t: vecteur de temps [sec]
% I: vecteur de courant [ampere]
% U: vecteur de tension [volt]
% instant_end_rest: est le dernier instant de temps de la phase de repos [sec]
% duration_pulse: duree du PULSE prise en compte pour l'interpolation [sec]
% ATTENTION: n'est pas forcement la duration entiere du pulse
% duration_repos: duree du REPOS prise en compte pour l'interpolation [sec]
% ATTENTION: n'est pas forcement la duration entiere du repos
% graph: variable pour montrer les resultats
%
%       VARIABLES DE SORTIE
% Rp: resistance estimee du pulse [ohms]
% R_I: courant a laquelle le courant a ete mesure [ampere]
% Rt: Instant de calcul de la résistance par rapport au temps depuis le début de l'essai [s]
% RDoD : DoD auquel la résistance est calculée [%]
% Rdt :  Instant de calcul de la résistance par rapport au temps depuis le
% début du pulse [s]
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%       TRAITEMENT DES DONNEES D'ENTREE
%--------------------------------------------------------------------------
Rp = 0;
R_I = 0;
Rt = 0;
RDoD = 0;
Rdt = 0;
err = 0;

if (isempty(t) || isempty(U) || isempty(I))
    fprintf('ERREUR vecteur(s) dentree vide(s)\n');                   % traitement des erreus de donnees de entree
    error('$')
% elseif any(t == 0) || any(U == 0)                                     % � REVOIR
%     fprintf('ERREUR vecteur(s) avec au moins un element nulle(s)\n'); % traitement des erreus de donnees de entree
%     error('$')
elseif all(I == 0)
    fprintf('ERREUR courant toujours null ?\n');                   % traitement des erreus de donnees de entree
    error('$')
elseif any(diff(t)<= 0)
    fprintf('ERREUR t doit augmenter toujours \n');                    % verifie se le vecteur de temps est toujours croissante
    error('$')
    %ca va etre traite apres: (length(trepos)<3  >>> nan)
% elseif (instant_end_rest == 0 || instant_end_rest == t(1))
%     fprintf('ERREUR instant_end_rest nulle ou pas de repos? \n');           % traitement des erreus de donnees de entree
%     error('$')
% elseif (instant_end_rest < t(1))
%     fprintf('ERREUR instant_end_rest inferieur au temps t \n');             % instant_end_rest ne peut pas etre plus petit que t(1)
%     error('$')
% elseif (instant_end_rest > t(end))
%     fprintf('ERREUR instant_end_rest superieur au temps t \n');             % instant_end_rest ne peut pas etre plus grand que t(fin)
%     error('$')
% elseif (duration_pulse == 0 || duration_repos == 0)
%     fprintf('ERREUR duration_pulse et/ou duration_repos nulle(s), il faut sp�cifier une duration non nulle\n'); % traitement des erreus de donnees de entree
%     error('$')
% else
%     if (instant_end_rest - duration_repos < t(1))
%         fprintf('Warning! duration_repos, duration trop grande \n'); % traitement des erreus de donnees de entree
%         warning('$')          %changer pour un warning ex: dr = min(duration_repos,repos_t(end)-repos_t(1));
%     elseif (instant_end_rest + duration_pulse > t(end))
%         fprintf('ERREUR duration_pulse, duration trop grande \n'); % traitement des erreus de donnees de entree
%         warning('$')
        
    end

 repos = (t<instant_end_rest & t>=(instant_end_rest - duration_repos)); % on s'interesse a la periode de temps du repos: (instant_end_rest - duration_repos)=<t<(instant_end_rest)
    trepos = t(repos);  %faire un sous ensemble avec les informations souhaitees de temps
    Urepos = U(repos);  %faire un sous ensemble avec les informations souhaitees de tension
    Irepos = I(repos);  %faire un sous ensemble avec les informations souhaitees de courant
    
    if length(trepos)<3
        err=-1;
        Rp = nan;
        R_I = nan;
        Rt = nan;
        RDoD = nan;
        Rdt = nan;
        return;
    end
    
    pulse = (t>instant_end_rest);    % on s'interesse a la periode de temps du pulse: (instant_end_rest)<t<=(instant_end_rest + duration_repos)
    tpulse = t(pulse);
    Upulse = U(pulse);
    Ipulse = I(pulse);
    if length(tpulse)<3
        err=-2;
        Rp = nan;
        R_I = nan;
        Rt = nan;
        RDoD = nan;
        Rdt = nan;
        return;
        
    end
    
    if max(t)<instant_end_rest+duration_pulse
        err=-2;
        Rp = nan;
        R_I = nan;
        Rt = nan;
        RDoD = nan;
        Rdt = nan;
        return;
    end
    

        
    %--------------------------------------------------------------------------
    %                          PRINCIPAL
    %--------------------------------------------------------------------------

          %ATTENTION maintenant ce sont des vecteurs
        Rp = [];
        R_I = [];
        Rt = [];
        RDoD = [];
        Rdt = [];  
        
        
    for ind = 1:length(t_calcul_R)
        if max(tpulse)-min(tpulse)<t_calcul_R(ind)
            continue
        else
            w = abs(tpulse-tpulse(end));                               %poids d'interpolation polynominal pour le pulse, les points loin de l'impulse de courant ont un poids plus eleve
            Ural_pul = fitting_pol2(tpulse,Upulse,instant_end_rest+t_calcul_R(ind),w);%U ralonge pour le pulse, ont extrapole le point a l'instant de l'impulse
            w = abs(trepos-trepos(1));
            Ural_rep = fitting_pol2(trepos,Urepos,instant_end_rest+t_calcul_R(ind),w);%U ralonge pour le repos,ont extrapole le point a l'instant de l'impulse
            
            R_I(end+1) = mean(Ipulse);                                 %le courant d'estimation de la resistance est la moyenne du courant (filtrer le bruit)
            Rp(end+1) = (Ural_pul-Ural_rep)/R_I(end);                       %la resistance est la difference de potentiel entre le repos et le pulse divise par le courant
            Rt(end+1) = t(1) + duration_repos;
            RDoD(end+1) = DoDAh(1);
            Rdt(end+1) = t_calcul_R(ind);
        end
    end
    
    
       
    %--------------------------------------------------------------------------
    %       TRAITEMENT DES ERREURS DE SORTIE
    %--------------------------------------------------------------------------
    if (any(Rp<0) || any(isnan(Rp)))                              % resistance negative et Not A Number, erreur!
        fprintf('ERREUR Rp negative ou NAN\n');                % traitement des erreus de donnees de sortie
    end
    %--------------------------------------------------------------------------
    %       MONTRE LES RESULTATS?
    %--------------------------------------------------------------------------

    
    if exist('graph','var')
        if graph
            montrer_resultats(t,U,I,instant_end_rest,Ural_pul,Ural_rep,R_I,tpulse,Upulse,trepos,Urepos,t_calcul_R)
        end
    end
end
%DEBUG
% montrer_resultats(t,U,I,instant_end_rest,Ural_pul,Ural_rep,R_I,tpulse,Upulse,trepos,Urepos,t_calcul_R)




%--------------------------------------------------------------------------
%       MONTRE LES RESULTATS
%--------------------------------------------------------------------------
function montrer_resultats(t,U,I,instant_end_rest,Ural_pul,Ural_rep,R_I,tpulse,Upulse,trepos,Urepos,t_calcul_R)
%en fonction du SOC
figure,
w = abs(tpulse-tpulse(end));  
Ural_pul_syn = fitting_pol2(tpulse,Upulse,tpulse+t_calcul_R,w);%U ralonge pour le pulse
w = abs(trepos-trepos(1));
Ural_rep_syn = fitting_pol2(trepos,Urepos,trepos+t_calcul_R,w);%U ralonge pour le repos

subplot(211),plot(t-instant_end_rest,U,'.-',0,Ural_pul,'r^',0,Ural_rep,'rs'),hold on
subplot(211),plot(tpulse-instant_end_rest,Ural_pul_syn,'m.-',trepos-instant_end_rest+t_calcul_R,Ural_rep_syn,'c.-'),hold on
subplot(212),plot(t-instant_end_rest,I,'.-',0,R_I,'r^'),hold on

subplot(211),xlim([min(trepos-instant_end_rest) max(tpulse-instant_end_rest)])
xlabel('temps[s]'), ylabel('tension U[V]')
legend('points mesures U','U ralong� pulse','U ralong� repos','projection U pulse','projection U repos');
subplot(212),xlim([min(trepos-instant_end_rest) max(tpulse-instant_end_rest)])
xlabel('temps[s]'), ylabel('courant I[A]')
legend('points mesures I','R_I');
end
