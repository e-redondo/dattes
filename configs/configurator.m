function config = configurator(t,U,I,m,config,phases,options)
%configurator configuration for dattes
% config = configurator(t,U,I,m,config,phases,options)
%
% INPUTS:
% - t,U,I,m (nx1 doubles) from extract_bench
% - config (1x1 struct) containing minimal info (see cfg_default)
% - phases (nx1 struct) from decompose_bench
% - options (1xn string) some options ('v', 'g').
%
% OUTPUTS:
% config (1x1 struct) with fields:
%     - pCapaD: phases of full CC discharge
%     - pCapaC: phases of full CC charge
%     - pCapaDV: phases of residual CV discharge
%     - pCapaCV: phases of rsidual CV charge
%     - pR: phases for resistance identification
%     - tR: moments for resistance identification
%     - pW: phases for impedance identification
%     - tW: moments for impedance identification
%     - t100: moments at SoC100 SOC calculation
%     - DoDAhIni: initial DoD in Amphours
%     - DoDAhFin: final DoD in Amphours
%
%
% See also dattes, extract_bench, decompose_bench, cfg_default, plot_config

if ~exist('options','var')
    options = '';
end

tInis = [phases.t_ini];
tFins = [phases.t_fin];
durees = [phases.duration];

if ismember('v',options)
    fprintf('configurator:...');
end

%phases CC
% %1.-debuts de decharge CC
% IiniccD = m==1 & I<0 & [0; m(1:end-1)]~=1;
% %2.- debuts de charge CC
% IiniccC = m==1 & I>0 & [0; m(1:end-1)]~=1;
% %3.-fins de decharge CC
% IfinccD = m==1 & I<0 & [m(2:end);0]~=1;
% %4.-fins de charge CC
% IfinccC = m==1 & I>0 & [m(2:end);0]~=1;
% %phases CV
% %1.-debuts de deccharge CV
% IinicvD = m==2 & I<0 & [0; m(1:end-1)]~=2;
% %2.- debuts de charge CV
% IinicvC = m==2 & I>0 & [0; m(1:end-1)]~=2;
% %3.-fins de decharge CV
% IfincvD = m==2 & I<0 & [m(2:end);0]~=2;
% %4.-fins de charge CV
% IfincvC = m==2 & I>0 & [m(2:end);0]~=2;
%1.-debuts et fins de CC
Iinicc = m==1 & [0; m(1:end-1)]~=1;
Ifincc = m==1 & [m(2:end);0]~=1;
%2.-debuts et fins de CV
Iinicv = m==2 & [0; m(1:end-1)]~=2;
Ifincv = m==2 & [m(2:end);0]~=2;
%3.-debuts et fins de repos
IiniRepos = m==3 & [0; m(1:end-1)]~=3;
IfinRepos = m==3 & [m(2:end);0]~=3;



%pour comparer aux Umax et Umin
% Ur = round(U*1000/10)*10/1000;%FIX: arrondi aux 20mV, besoin avec Bitrode LYP
% %instants a Umax
% Imax = Ur==config.Umax;%FIX: sinon: Imax = Ur>=config.Umax-.02;
% %instant a Umin
% Imin = Ur==config.Umin;%FIX: sinon: Imin = Ur>=config.Umin+.02;

%ca marche avec  Bitrode LYP, verifier avec Mobicus
Imin = U<=(config.Umin+0.02);
Imax = U>=config.Umax-0.02;%BRICOLE essai 20171211_1609 HONORAT
%instants a SoC100 (ou presque I100cc: fin de charge CC)
I100cc = Ifincc & Imax;%ca marche pas pour LYP
Regime = I/config.Capa;
Ic20 = Regime<=config.regimeOCVmax*1.1; % typiquement 0.05
% I100 = Ifincv & Imax;
I100 = (Ifincv & Imax) | (I100cc & Ic20);
%instants a SoC0 (ou presque I0cc: fin de decharge CC)
I0 = Ifincv & Imin;
%fin de decharge et touche Umin ou suivi de floating a Umin:
I0cc = Ifincc & (Imin | [Imin(2:end);0]);
%Note: normalement il aurait suffit (IfinccD & Imin), mais de fois les fins de
%decharge sont tellement rapide (chute de la tension) que le point a
%tension min n'est pas attribue a cette phase, mais a la suivante (cas de
%decharge CC-CV).
% Il a fallu ajouter le point suivant: [Imin(2:end);0].
%debut de repos a SoC100
I100r = [0; I100(1:end-1)] & m==3;
I100ccr = [0; I100cc(1:end-1)] & m==3;
%debut de repos a SoC0
I0r = [0; I0(1:end-1)] & m==3;
I0ccr = [0; I0cc(1:end-1)] & m==3;



%phases de repos a SOC100
pRepos100 = ismember(tInis,t(I100r | I100ccr));
%phases de repos a SOC0
pRepos0 = ismember(tInis,t(I0r | I0ccr));

%1) phases capa decharge (CC):
%1.1. Iavg<0
%1.2.- finissent a SoC0 (I0cc)
%1.3.- sont precedes par une phase de repos a SoC100 (I100r ou I100ccr)
pCapaD = [phases.Iavg]<0 & ismember(tFins,t(I0cc)) & [0 pRepos100(1:end-1)];
%2) phases capa charge (CC):
%2.1.- Iavg>0
%2.2.- finissent a SoC100 (I100cc)
%2.3.- sont precedes par une phase de repos a SoC0 (I0r ou I0ccr)
pCapaC = [phases.Iavg]>0 & ismember(tFins,t(I100cc)) & [0 pRepos0(1:end-1)];
pCapaC = [phases.Iavg]>0 & [0 pRepos0(1:end-1)];%LYP, BRICOLE
%3) phases de decharge residuelle
%1.1.- Iavg<0
%1.2.- finissent a SoC0 (I0)
%1.3.- sont precedes par une phase pCapaD
pCapaDV = [phases.Iavg]<0 & ismember(tFins,t(I0)) & [0 pCapaD(1:end-1)];
%4) phases de charge residuelle
%1.1.- Iavg>0
%1.2.- finissent a SoC100 (I100)
%1.3.- sont precedes par une phase pCapaC
pCapaCV = [phases.Iavg]>0 & ismember(tFins,t(I100)) & [0 pCapaC(1:end-1)];

%5) phases de mesure d'impedance
%5.0- detection de pulses:
Ipulse = m==1 & [0; m(1:end-1)]==3;

%5.1.- mode CC et dernier point avant en repos (3)
pR = ismember(tInis,t(Ipulse))& durees<=config.maximal_duration_pulse;
pW =pR;

%5.2.- duree minimale pour pR, tminR (10secondes); pour pW, tminW (300sec)
pR = pR & durees>=config.minimal_duration_pulse;
pW = pW & durees>=config.tminW;
%5.3- duree minimale du repos avant?
pR = pR & [0 durees(1:end-1)]>=config.minimal_duration_rest_before_pulse;
pW = pW & [0 durees(1:end-1)]>=config.tminWr;
%5.4- duree maximale du pulse pour l'identification d'un RC
pRC=pR & durees<=config.maximal_duration_pulse ;
%5.5- duree maximale du pulse pour l'identification d'un CPE
pCPE=pW & durees<=config.maximal_duration_pulse ;
%TODO: 5.6.-verification echantillonnage pour eviter warnings calculR
%nb points repos > 3
%...
%repos immediatememnt anterieurs
pRr = [pR(2:end) false];
pWr = [pW(2:end) false];
pRCr = [pRC(2:end) false];
pCPEr = [pCPE(2:end) false];

%ident_Capa2
config.pCapaD = pCapaD;
config.pCapaC = pCapaC;

%ident_CapaCV
config.pCapaDV = pCapaDV;
config.pCapaCV = pCapaCV;

%ident_r
config.pR = pR;
config.instant_end_rest = tFins(pRr);%temps de fins de repos immediatememnt anterieur

%ident_rrc
config.pRC=pRC;
config.instant_fin_repos_RC = tFins(pRCr);%temps de fins de repos immediatememnt anterieur



%ident_cpe
config.pCPE=pCPE;
config.instant_fin_repos_CPE = tFins(pCPEr);%temps de fins de repos immediatememnt anterieur
config.tW = tFins(pWr);%temps de fins de repos immediatememnt anterieur
config.pW = pW;


%calculSOC
config.t100 = t(I100);%pour le calcul du SOC
config.t0 = t(I0);%pour le calcul du SOC
%Note: retourne matrice vide s'il ne trouve pas de phase CCCV a Umax.
%Dans ces cas il faut trouver le test immediatement anterieur (ou
%posterieur), calculer le DoDAh et fixer DoDAhIni ou DoDAhFin pour pouvoir
%faire calculSOC
if ~isfield(config,'DoDAhIni')
    config.DoDAhIni = [];
end
if ~isfield(config,'DoDAhFin')
    config.DoDAhFin = [];
end
%ident_OCVr2 (par points)
config.pOCVr = durees>=config.tminOCVr & ismember(tInis,t(IiniRepos));
config.pOCVr(1) = false; % repos initial jamais retenu pour OCV
%ident_pOCV (pseudoOCV)
Regime = [phases.Iavg]./config.Capa;
config.pOCVpC = config.pCapaC & abs(Regime)<config.regimeOCVmax & abs(Regime)>config.regimeOCVmin;
config.pOCVpD = config.pCapaD & abs(Regime)<config.regimeOCVmax & abs(Regime)>config.regimeOCVmin;

%essaiICA
config.pICAC = config.pCapaC & abs(Regime)<config.regimeICAmax;
config.pICAD = config.pCapaD & abs(Regime)<config.regimeICAmax;




if ismember('v',options)
    fprintf('OK\n');
end

if ismember('g',options)
%     showResult(t,U,I100,Iinicv,config,phases);
    
    hf = plot_config(t,U,config,phases,'','h');
    set(hf,'name','configurator');
end
end
