function [Rs, R, C, err_rel, Ip] = calcul_rrc_pulse(tm,Um,Im,options,C0)
% calcul_rrc_pulse Calculation of parametres of Rs+RC impedance
%
%
% Usage:
% [Rs, R, C, err_rel, Ip] = calcul_rrc_pulse(tm,Um,Im,options,C0)
% Inputs:
% - tm, Um, Im (nx1 double): time, voltage, current vectors
% - options (string):
%    - 'g': graphics (plot results)
%    - 'c': fixed alpha parameter (C0)
% - alpha0 (1x1 double): initial (or fixed) value for alpha
% Outputs:
% - Rs, R, C (1x1 double): identified Rs, R, C parammeters
% - err_rel (1x1 double): average absolute relative error
% - Ip (1x1 double): pulse amplitude (A)
%
% See also ident_rrc_pulse, rrc_output
%
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab:
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.


if ~exist('options','var')
    options='';
end
if ~exist('C0','var')
    C0=1000;
end
%pulse parameters (amplitude, start time, final time, sample time)
[Ip,td,tf,Ts] = param_pulse(tm,Im);

%build 'interpolated vectors' (improve identification time, and robusness)
tmi = (tm(1):Ts:tm(end))';
Imi = zeros(size(tmi));
Imi(tmi>=td & tmi<tf) = Ip;
Umi = interp1(tm,Um,tmi);

%initial guess of Rs:
[R0] = calcul_r0(tmi,Umi,Imi,10, 10);


if ~ismember('c',options)
    %three parameters
    monCaller = @(x) error_rrc_pulse(x(1),x(2),x(3),tm,Im,Um);
    x0 = [R0;R0; C0];
else
    %two parameters (C = C0 fixed)
    monCaller = @(x) error_rrc_pulse(x(1),x(2),C0,tm,Im,Um);
    x0 = [R0;R0];
end
%looking for minimum

%  opts = optimset('Display','iter','TolX',1e-2,'TolFun',1e-2);
%  opts = optimset('TolX',1e-5,'TolFun',1e-5);
 opts = optimset('TolX',1e-5);
[x,fval,exitflag,output] = fminsearch(monCaller,x0,opts);

if exitflag<1
    Rs = nan;
    R = nan;
    C = nan;
    err_rel = nan;
    return
end

Rs = x(1);
R = x(2);
if ismember('c',options)%fixed C,two parameters
    C = C0;
else%not fixed C 3 parameters
    C = x(3);
end

Us = rrc_output(tm,Im,Rs,R,C);
Is = Im;
ts = tm;
err_rel = mean(abs(error_relative(Um,Us)));

if ismember('g',options)
        show_result(tm,Im,Um,ts,Is,Us,err_rel);
end

end


function erreur = error_rrc_pulse(Rs,R,C,tm,Im,Um)
%error_rrc_pulse simule un R+RC et compare le resultat avec des mesures
%La simulation est faite en utilisant la fonction rrc_output.
%
% -Rs,R,C [1x1 double]: parametres du R+RC
% -Ip, td, tf [1x1 double]: parametres du pulse
% -tm,Um [nx1 double]: vecteurs temps et tension (mesures)
%
if ~isnumeric(Rs) ||  ~isnumeric(R) ||  ~isnumeric(C) ||...
        ~isnumeric(tm) || ~isnumeric(tm) ||  ~isnumeric(Um)
    erreur = [];
    fprintf('error_rrc_pulse: ERROR, all inputs must be numeric\n');
    return
end
if numel(Rs) ~= 1 || numel(R) ~= 1 || numel(C) ~= 1
    erreur = [];
    fprintf('error_rrc_pulse:ERROR, Q and alpha must be scalars (1x1)\n');
    return
end
if ~isequal(size(tm),size(Im)) || ~isequal(size(tm),size(Um)) || size(tm,1)~=length(tm)
    erreur = [];
    fprintf('error_rrc_pulse:ERROR, tm and Um must be vectors with same size (nx1)\n');
    return
end

U = rrc_output(tm,Im,Rs,R,C);
U = U(:);
Um = Um(:);

% With relative error fminsearch do not reach the minimum, using absolute
% instead
% erreur = mean(error_relative(Um,U));
% erreur = mean(error_absolute(Um,U));
% quadratic error work not very well with fast impedances (high Q values)
erreur = mean(error_quadratic(Um,U));

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
tf = t(ind_fin);%.G

Ts = mean(diff(t));
end

function show_result(tm,Im,Um,ts,Is,Us,err_rel)
figure,
subplot(211),plot(tm,Im,'.-',ts,Is,'r.-')
subplot(212),plot(tm,Um,'.-',ts,Us,'r.-',tm,Us-Um,'g.')
legend('measurement','simulation',sprintf('relative error: %f',err_rel),'location','best')
end

