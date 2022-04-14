function [Rp, R_I, err] = calcul_r(t,U,I,t_fin_repos,duration_pulse,duration_repos,graph)

%--------------------------------------------------------------------------
%function [Rp R_I] = calcul_r(t,I,U,ind_fin_repos,duration_pulse,graph)
% fonction pour calculer la resistance vu par un pulse
% vu le front montant(imulsion) de courant du pulse, on va interpoller separement les
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
% t_fin_repos: est le dernier instant de temps de la phase de repos [sec]
% duration_pulse: duree du PULSE prise en compte pour l'interpolation [sec]
% ATTENTION: n'est pas forcement la duration entiere du pulse
% duration_repos: duree du REPOS prise en compte pour l'interpolation [sec]
% ATTENTION: n'est pas forcement la duration entiere du repos
% graph: variable pour montrer les resultats
%
%       VARIABLES DE SORTIE
% Rp: resistance estimee du pulse [ohms]
% R_I: courant a laquelle le courant a ete mesure [ampere]
%--------------------------------------------------------------------------
%
%TODO: reduire nombre d'entrees, juste t,U,I et eventuellement m, si m pas
%donne, le calculer avec modeBanc puis decouper en fonction de m
%TODO: mettre dernier argument au format 'options', 'g', 'm', etc.
%'g' = grap, 'm' = calculer 'm', par defaut si par de 4eme argument.

%--------------------------------------------------------------------------
%       TRAITEMENT DES ERREURS D'ENTREE
%--------------------------------------------------------------------------
Rp = 0;
R_I = 0;
err = 0;

if (isempty(t) || isempty(U) || isempty(I))
    fprintf('ERREUR vecteur(s) dentree vide(s)\n');                   % traitement des erreus de donnees de entree
    error('$')
elseif any(t == 0) || any(U == 0)                                     % � REVOIR
    fprintf('ERREUR vecteur(s) avec au moins un element nulle(s)\n'); % traitement des erreus de donnees de entree
    error('$')
elseif all(I == 0)
    fprintf('ERREUR courant toujours null ?\n');                   % traitement des erreus de donnees de entree
    error('$')
elseif any(diff(t)<= 0)
    fprintf('ERREUR t doit augmenter toujours \n');                    % verifie se le vecteur de temps est toujours croissante
    error('$')
    %ca va etre traite apres: (length(trepos)<3  >>> nan)
% elseif (t_fin_repos == 0 || t_fin_repos == t(1))
%     fprintf('ERREUR t_fin_repos nulle ou pas de repos? \n');           % traitement des erreus de donnees de entree
%     error('$')
elseif (t_fin_repos < t(1))
    fprintf('ERREUR t_fin_repos inferieur au temps t \n');             % t_fin_repos ne peut pas etre plus petit que t
    error('$')
elseif (t_fin_repos > t(end))
    fprintf('ERREUR t_fin_repos superieur au temps t \n');             % t_fin_repos ne peut pas etre plus petit que t
    error('$')
elseif (duration_pulse == 0 || duration_repos == 0)
    fprintf('ERREUR duration_pulse et/ou duration_repos nulle(s), il faut sp�cifier une duration non nulle\n'); % traitement des erreus de donnees de entree
    error('$')
else
    if (t_fin_repos - duration_repos < t(1))
        fprintf('Warning! duration_repos, duration trop grande \n'); % traitement des erreus de donnees de entree
        warning('$')          %changer pour un warning ex: dr = min(duration_repos,repos_t(end)-repos_t(1));
    elseif (t_fin_repos + duration_pulse > t(end))
        fprintf('ERREUR duration_pulse, duration trop grande \n'); % traitement des erreus de donnees de entree
        warning('$')
        
    end
    %--------------------------------------------------------------------------
    %       PRINCIPAL
    %--------------------------------------------------------------------------
    repos = (t<t_fin_repos & t>=t_fin_repos - duration_repos); % on s'interesse a la periode de temps du repos: (t_fin_repos - duration_repos)=<t<(t_fin_repos)
    trepos = t(repos);  %faire un sous ensemble avec les informations souhaitees de temps
    Urepos = U(repos);  %faire un sous ensemble avec les informations souhaitees de tension
    Irepos = I(repos);  %faire un sous ensemble avec les informations souhaitees de courant
    if length(trepos)<3
        err=-1;
        Rp = nan;
        R_I = nan;
        return;
    end
    pulse = (t>t_fin_repos & t<=t_fin_repos+duration_pulse);    % on s'interesse a la periode de temps du pulse: (t_fin_repos)<t<=(t_fin_repos + duration_repos)
    tpulse = t(pulse);
    Upulse = U(pulse);
    Ipulse = I(pulse);
    if length(tpulse)<3
        err=-2;
        Rp = nan;
        R_I = nan;
        return;
    end
    %TODO: try other weightning (more weigth t(1) less t(end)
    %TODO: try other fitting methods? 
    w = tpulse-tpulse(1);                               %poids d'interpolation polynominal pour le pulse, les points loin de l'impulse de courant ont un poids plus eleve
    Ural_pul = fitting_pol2(tpulse,Upulse,t_fin_repos,w);%U ralonge pour le pulse, ont extrapole le point a l'instant de l'impulse
    
    w = trepos-trepos(1);
    Ural_rep = fitting_pol2(trepos,Urepos,t_fin_repos,w);%U ralonge pour le repos,ont extrapole le point a l'instant de l'impulse
    
    R_I = mean(Ipulse);                                 %le courant d'estimation de la resistance est la moyenne du courant (filtrer le bruit)
    Rp = (Ural_pul-Ural_rep)/R_I;                       %la resistance est la difference de potentiel entre le repos et le pulse divise par le courant
    
    %--------------------------------------------------------------------------
    %       TRAITEMENT DES ERREURS DE SORTIE
    %--------------------------------------------------------------------------
    if (Rp<0 || isnan(Rp))                              % resistance negative et Not A Number, erreur!
        fprintf('ERREUR Rp negative\n');                % traitement des erreus de donnees de sortie
    end
    
    %--------------------------------------------------------------------------
    %       MONTRE LES RESULTATS?
    %--------------------------------------------------------------------------
    if exist('graph','var')
        if graph
            montrer_resultats(t,U,I,t_fin_repos,Ural_pul,Ural_rep,R_I,tpulse,Upulse,trepos,Urepos)
        end
    end
end
%DEBUG
%montrer_resultats(t,U,I,t_fin_repos,Ural_pul,Ural_rep,R_I,tpulse,Upulse,trepos,Urepos)

end


%--------------------------------------------------------------------------
%       MONTRE LES RESULTATS
%--------------------------------------------------------------------------
function montrer_resultats(t,U,I,t_fin_repos,Ural_pul,Ural_rep,R_I,tpulse,Upulse,trepos,Urepos)
%en fonction du SOC
figure,
w = tpulse-tpulse(1);
Ural_pul_syn = fitting_pol2(tpulse,Upulse,tpulse,w);%U ralonge pour le pulse
w = trepos-trepos(1);
Ural_rep_syn = fitting_pol2(trepos,Urepos,trepos,w);%U ralonge pour le repos

subplot(211),plot(t-t_fin_repos,U,'.-',0,Ural_pul,'r^',0,Ural_rep,'rs'),hold on
subplot(211),plot(tpulse-t_fin_repos,Ural_pul_syn,'m.-',trepos-t_fin_repos,Ural_rep_syn,'c.-'),hold on
subplot(212),plot(t-t_fin_repos,I,'.-',0,R_I,'r^'),hold on

subplot(211),xlim([min(trepos-t_fin_repos) max(tpulse-t_fin_repos)])
xlabel('temps[s]'), ylabel('tension U[V]')
legend('points mesures U','U ralong� pulse','U ralong� repos','projection U pulse','projection U repos');
subplot(212),xlim([min(trepos-t_fin_repos) max(tpulse-t_fin_repos)])
xlabel('temps[s]'), ylabel('courant I[A]')
legend('points mesures I','R_I');
end
