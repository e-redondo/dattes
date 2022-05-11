function [dQdU, dUdQ, Qdva, Uica] = essaiICA(t,Q,U,config,options)
%essaiICA Incremental Capacity Analysis (ICA)
%Calcul de la ICA et la DVA d'un test (charge ou décharge)
%[dQdU, dUdQ, Q, U] = essaiICA(Q,U,dt)

dQ = config.dQ;
dU = config.dU;
Ts = config.TsICA;
Tc = config.TcICA;
nF = config.nFilterICA;

if ~exist('options','var')
    options='';
end

%0.- TODO filtrage du signal
%0.1-resample:
ti = t(1):Ts:t(end);
Ui = interp1(t,U,ti,'linear','extrap');
Qi = interp1(t,Q,ti,'linear','extrap');
%0.2-desing du filtre
fc = 1/Tc;%cut frequency
fs = 1/Ts;%sample frequency
% [b,a] = butter(nF,fc/(fs/2));
% Uf = filter(b,a,Ui);
 Uf = moyenneGlissante(ti,Ui,10*Ts);
%1.1.- on met dans l'ordre et on enleve les doublons
[Uu, Iu] = unique(Uf);
Qu = Qi(Iu);

%1.2.-interpolation pour avoir 'Ts' constant
% Uur = round(Uu/dU)*dU;%arrondi a dU
Ui2 = (min(Uu):dU:max(Uu))';
Qi2 = interp1(Uu,Qu,Ui2,'linear','extrap');
%1.3.-calcul de la derivee
[dQdU] = deriveGlissante(Ui2,Qi2,dU);
Uica = Ui2;
if ismember('g',options)
    showResults(Ui2,dQdU)
end

%2.- dUdQ
%2.1.- on met dans l'ordre et on enleve les doublons
[Qu, Iu] = unique(Qi);
Uu = Ui(Iu);

%2.2.-interpolation pour avoir 'Ts' constant
% Uur = round(Uu/dU)*dU;%arrondi a dU
Qi2 = (min(Qu):dQ:max(Qu))';
Ui2 = interp1(Qu,Uu,Qi2,'linear','extrap');
%2.3.-calcul de la derivee
[dUdQ] = deriveGlissante(Qi2,Ui2,dQ);
Qdva = Qi2;
if ismember('g',options')
    showResults(Qi2,dUdQ)
end
end
function showResults(x,dydx)

figure('name','essaiICA');
plot(x, dydx,'b')

end