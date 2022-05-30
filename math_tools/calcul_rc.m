 function [R, C, err] = calcul_rc(tm,Um,Im,options,R0,C0,Rmin,Rmax,Cmin,Cmax)
% function [R, C, err] = calcul_rc(tm,Um,Im,options,R0,C0,Rmin,Rmax,Cmin,Cmax)
%
%identificationRC Calcul des parametres d'un circuit RC à partir des
%mesures (temps,tension, courant)
% Cette fonction utilise reponseRC
% tm [nx1 double]: vecteur temps mesure
% Um [nx1 double]: vecteur tension mesuree
% Im [nx1 double]: vecteur courant mesure
% options [string]: options d'execution:
%       si options contient 'g': mode graphique, montre les resultats
%       si options contient 'c': 'C fixe', on fixe C a C0
% R0 [1x1 double]: valeur initiale de R
% C0 [1x1 double]: valeur initiale de C
%
% See also  reponseRC

if ~exist('options','var')
    options='';
end
if ~exist('R0','var')
    R0=1e-3;
end
if ~exist('C0','var')
    C0=100;
end

if ismember('c',options)
    %identification des deux parametres (R et C)
    monCaller = @(x) erreurRC(x(1),x(2),tm,Um,Im);
    x0 = [R0; C0];
else
    %identification d'un parametre (C fixe)
    C = C0;%C fixe
    monCaller = @(x) erreurRC(x,C,tm,Um,Im);
    x0 = [R0];
end
%recherche du minimum
[x,fval,exitflag,output] = fminsearch(monCaller,x0);

% if ~isnan(monCaller(x0))
% 
% A = [];
% b = [];
% Aeq = [];
% beq = [];
% 
% 
% lb=[Rmin Cmin];
% ub=[Rmax Cmax];
% optim_options = optimoptions('fmincon','Algorithm','interior-point','Display','off');
% 
% [x,fval,exitflag,output] = fmincon(monCaller,x0,A,b,Aeq,beq,lb,ub,[],optim_options);
% 
% else
%     
%     R = nan;
%     C = nan;
%     err = nan;
% return
% end



if exitflag<1
    R = nan;
    C = nan;
    err = nan;
    return
end

R = x(1);
if ismember('c',options)%si deux parametres
    C = x(2);
end

Us = reponseRC(tm,Im,R,C);
Is = Im;
ts = tm;
err = mean(erreurQuadratique(Um,Us));

if ~isempty(strfind(options, 'g'))
        showResult(tm,Im,Um,ts,Is,Us,err);
end

end


function erreur = erreurRC(R,C,tm,Um,Im)
%erreur = erreurRC(Q,alpha,tm,Um,Im)
%erreurCPE simule un circuit RC  et compare le resultat avec des mesures
%La simulation est faite en utilisant la fonction reponseRC.
% -R,C [1x1 double]: parametres du circuit RC
% -tm,Um,Im [nx1 double]: vecteurs temps, tension et courant (mesures)
%

if ~isnumeric(R) ||  ~isnumeric(C) ||  ~isnumeric(tm) ||  ~isnumeric(Um) ||  ~isnumeric(Im) 
    erreur = [];
    fprintf('erreurRC:ERREUR, toutes les entrees doivent etre numeriques\n');
    return
end
if numel(R) ~= 1 || numel(C) ~= 1 
    erreur = [];
    fprintf('erreurRC:ERREUR, R et C doivent etre scalaires (1x1)\n');
    return
end
if ~isequal(size(tm),size(Um)) || ~isequal(size(tm),size(Im)) || size(tm,1)~=length(tm)
    erreur = [];
    fprintf('erreurRC:ERREUR; tm,Um et Im doivent etre vecteurs de la meme taille (nx1)\n');
    return
end


U = reponseRC(tm,Im,R,C);
U = U(:);
Um = Um(:);

erreur = mean(erreurQuadratique(Um,U));


end

function err_qua = erreurQuadratique(Um,Us)

err_qua = abs(Us-Um).^2;
end

function showResult(tm,Im,Um,ts,Is,Us,err)
figure,
subplot(211),plot(tm,Im,'.-',ts,Is,'r.-'),ylabel('courant (A)')
subplot(212),plot(tm,Um,'.-',ts,Us,'r.-',tm,Us-Um,'g.'),ylabel('tension (V)')
legend('mesure','simu',sprintf('erreur quadratique: %f',err),'location','best')
end


function [Um2,Im,tm,DoDm,Urelax,Instant_rest]=remove_spikes(Um2,Im,tm,DoDm,p_RC,phase_RC)
%remove_spikes Nettoie les points de courants abberants lors d'un pulse
%Um2,Im,tm,sont issus de getPhase2
%p_RC vient de split_phases
%See also getPhase2, split_phases
%%


%imprecision in rest part
Instant_rest = tm-p_RC(phase_RC).tIni<0;% negative = rest
Urelax = mean(Um2(Instant_rest));
Um2_polarization = Um2-Urelax; %

% Split rest and pulse voltages, currents and times
Um2_rest = Um2(Instant_rest);
Um2_pulse = Um2(~Instant_rest);
Im_re = Im(Instant_rest);
Im_pulse = Im(~Instant_rest);
tm_re = tm(Instant_rest);
tm_pulse = tm(~Instant_rest);
DoD_re = DoDm(Instant_rest);
DoD_pulse = DoDm(~Instant_rest);

%Rest
[Um2_rest,Im_re,tm_re,DoD_re]=clean_data(Um2_rest,Im_re,tm_re,DoD_re);


%Pulse
[Um2_pulse,Im_pulse,tm_pulse,DoD_pulse]=clean_data(Um2_pulse,Im_pulse,tm_pulse,DoD_pulse);

%Rebuild:
tm = [tm_re; tm_pulse];
Um2 = [Um2_rest; Um2_pulse];
Im = [Im_re; Im_pulse];
DoDm=[DoD_re; DoD_pulse];

%Resort
[tm,Instants_sorted] = sort(tm);
Um2 = Um2(Instants_sorted);
Im = Im(Instants_sorted);
DoDm=DoDm(Instants_sorted);


% Remove remaining spikes
diff_Um2=diff(Um2);
diff_Im=diff(Im);
diff_tm=diff(tm);
diff_DoDm=diff(DoDm);

Instant_rest = tm-p_RC(phase_RC).tIni<0;% negative = rest


end
function [A_clean,B_clean,C_clean,D_clean]=clean_data(Reference_A,Reference_B,Additional_C,Additional_D)

X = Reference_A.^2+Reference_B.^2;
distance = abs(X-mode(X));
[distance_sorted,Instants_sorted] = sort(distance);
nb = floor(0.95*length(distance));
Instants_sorted = Instants_sorted(1:nb);
A_clean = Reference_A(Instants_sorted);
B_clean = Reference_B(Instants_sorted);
C_clean = Additional_C(Instants_sorted);
D_clean = Additional_D(Instants_sorted);

end


