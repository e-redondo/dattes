function [R, Q, alpha, err_rel, Ip] = calcul_rcpe_pulse(tm,Um,Im,options,alpha0)
% calcul_cpe_pulse Calculation of parametres of R+CPE impedance
%
%
% Usage:
% [R, Q, alpha, err_rel, Ip] = calcul_cpe_pulse(tm,Um,Im,options,alpha0)
% Inputs:
% - tm, Um, Im (nx1 double): time, voltage, current vectors
% - options (string):
%    - 'g': graphics (plot results)
%    - 'a': fixed alpha parameter (alpha0)
% - alpha0 (1x1 double): initial (or fixed) value for alpha
% Outputs:
% - Q, alpha (1x1 double): identified Q, alpha parammeter of CPE
% - err_rel (1x1 double): average absolute relative error
% - Ip (1x1 double): pulse amplitude (A)
%
% See also ident_rcpe, response_rcpe_pulse
%
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab:
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.


if ~exist('options','var')
    options='';
end
if ~exist('alpha0','var')
    alpha0=0.5;
end
%pulse parameters (amplitude, start time, final time, sample time)
[Ip,td,tf,Ts] = param_pulse(tm,Im);

%initial guess of R:
[R0] = calcul_r0(tm,Um,Im,10, 10);


if ~ismember('a',options)
    %two parameters
    monCaller = @(x) error_rcpe_pulse(x(1),x(2),x(3),Ip,td,tf,tm,Um);
    x0 = [R0;1000; alpha0];
else
    %one parameter
%     alpha = alpha0;%alpha fixe (p.ex.:0.5)
    monCaller = @(x) error_rcpe_pulse(x(1),x(2),alpha0,Ip,td,tf,tm,Um);
    x0 = [R0;1000];
end
%looking for minimum

%  opts = optimset('Display','iter','TolX',1e-2,'TolFun',1e-2);
 opts = optimset('TolX',1e-2,'TolFun',1e-2);
 [x,fval,exitflag,output] = fminsearch(monCaller,x0,opts);

if exitflag<1
    R = nan;
    Q = nan;
    alpha = nan;
    err_rel = nan;
    return
end

R = x(1);
Q = x(2);
if ismember('a',options)%fixed alpha,two parameters
    alpha = alpha0;
else%not fixed alpha 3 parameters
    alpha = x(3);
end

Us = response_rcpe_pulse(R,Q,alpha,Ip,td,tf,tm);
Is = Im;
ts = tm;
err_rel = mean(abs(error_relative(Um,Us)));

if ismember('g',options)
        show_result(tm,Im,Um,ts,Is,Us,err_rel);
end

end


function erreur = error_rcpe_pulse(R,Q,alpha,Ip,td,tf,tm,Um)
%error_cpe_pulse simule un R+CPE (Q,alpha) et compare le resultat avec des mesures
%La simulation est faite en utilisant la fonction response_cpe_pulse.
%erreur = erreurCPE(Q,alpha,Ip,td,tf,tm,Um)
% -R,Q,alpha [1x1 double]: parametres du R+CPE
% -Ip, td, tf [1x1 double]: parametres du pulse
% -tm,Um [nx1 double]: vecteurs temps et tension (mesures)
%
if ~isnumeric(R) ||  ~isnumeric(Q) ||  ~isnumeric(alpha) ||...
        ~isnumeric(Ip) ||  ~isnumeric(td) ||  ~isnumeric(tf) ||...
        ~isnumeric(tm) ||  ~isnumeric(Um)
    erreur = [];
    fprintf('error_cpe_pulse: ERROR, all inputs must be numeric\n');
    return
end
if numel(R) ~= 1 || numel(Q) ~= 1 || numel(alpha) ~= 1
    erreur = [];
    fprintf('error_cpe_pulse:ERROR, Q and alpha must be scalars (1x1)\n');
    return
end
if numel(Ip) ~= 1 || numel(td) ~= 1 || numel(tf) ~= 1
    erreur = [];
    fprintf('error_cpe_pulse:ERROR, Ip, td and tf must be scalars (1x1)\n');
    return
end
if ~isequal(size(tm),size(Um)) || size(tm,1)~=length(tm)
    erreur = [];
    fprintf('error_cpe_pulse:ERROR, tm and Um must be vectors with same size (nx1)\n');
    return
end

U = response_rcpe_pulse(R,Q,alpha,Ip,td,tf,tm);
U = U(:);
Um = Um(:);

% With relative error fminsearch do not reach the minimum, using absolute
% instead
% erreur = mean(error_relative(Um,U));
erreur = mean(error_absolute(Um,U));
% quadratic error work not very well with fast impedances (high Q values)
% erreur = mean(error_quadratic(Um,U));

end

function [Ip,td,tf,Ts] = param_pulse(t,I)
%param_pulse valeurs caracteristiques d'un  pulse de courant
%
%[Ip,td,tf,Ts] = param_pulse(t,I) avec deux vecteurs t (temps) et
%I(courant), calcule la valeur moyenne du courant (Ip), les instants de
% temps de debut (td) et de fin (tf) de pulse, temps d'echantillonnage
% moyen (Ts).
%
% See also calcul_cpe_pulse


%TODO: use function which_mode or vector m in 3rd input.

%trier les points de Im en deux classes
Is = sort(abs(I));
Ip = mean(Is(floor(0.9*length(Is)):end));%moyenne des 90% plus grands
Iseuil = 0.1*Ip;
Isynth = I;%profil synthetique
Isynth(abs(Isynth)<Iseuil)=0;
Ip = mean(Isynth(Isynth~=0));%moyenne des points non nuls
Isynth(abs(Isynth)>=Iseuil)=Ip;%arrondi du pulse a la moyenne

% plot(t,I,t,Isynth,'r'),legend('mesure','synthetique')

%trouver le debut et la fin du pulse
dI = diff(Isynth);
ind_debut = find(dI,1,'first')+1;
ind_fin = find(dI,1,'last');
if isempty(ind_debut)
    ind_debut = 1;
    ind_fin = length(I);
end
if ind_fin<= ind_debut
ind_fin = length(t);
end
td = t(ind_debut);
tf = t(ind_fin);

Ts = mean(diff(t));
end

function show_result(tm,Im,Um,ts,Is,Us,err_rel)
figure,
subplot(211),plot(tm,Im,'.-',ts,Is,'r.-')
subplot(212),plot(tm,Um,'.-',ts,Us,'r.-',tm,Us-Um,'g.')
legend('measurement','simulation',sprintf('relative error: %f',err_rel),'location','best')
end

