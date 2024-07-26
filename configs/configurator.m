function config = configurator(datetime,I,U,m,config,phases,options)
%configurator configuration for DATTES
%
% Usage:
% config = configurator(datetime,U,I,m,config,phases,options)
%
% Inputs:
% - datetime,I,U,m [(nx1) double] from extract_profiles
% - config [(1x1) struct] containing minimal info (see cfg_default)
% - phases [(mx1) struct] from split_phases
% - options [(1xp) string] some options ('v').
%
% Outputs:
% config [(1x1) struct] with fields:
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
% See also dattes, extract_profiles, split_phases, cfg_default, plot_config
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab:
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

% check inputs:
%t,U,I,m: double vectors of same length
if ~isnumeric(datetime) || ~isnumeric(U) ||~isnumeric(I) ||~isnumeric(m)
    error('t,U,I,m must be numeric');
end
if ~isvector(datetime) || ~isvector(U) ||~isvector(I) ||~isvector(m)
   error('t,U,I,m must be vectors');
end
if length(datetime)<2 
   error('t must have at least to elements');
end
if length(datetime)~=length(U) ||  length(datetime)~=length(I) || length(datetime)~=length(m)
   error('t,U,I,m must have same length');
end
% config: 1x1 struct with fields:
if ~isstruct(config) || numel(config)~=1
    error('config must 1x1 struct');
end
if ~isfield(config,'test') || ~isfield(config,'resistance') || ...
        ~isfield(config,'impedance') || ~isfield(config,'ocv_points') || ...
        ~isfield(config,'pseudo_ocv') || ~isfield(config,'ica')
    error('not a valid config struct');
end
% phases: 1xp struct with fields:
if ~isstruct(phases) || ~isvector(phases)
    error('phases must 1xp struct');
end
if ~isfield(phases,'datetime_ini') || ~isfield(phases,'datetime_fin') || ...
        ~isfield(phases,'duration') || ~isfield(phases,'Iavg') 
    error('not a valid phases struct');
end

if ~exist('options','var')
    options = '';
end

tInis = [phases.datetime_ini];
tFins = [phases.datetime_fin];
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
% Imax = Ur==config.test.max_voltage;%FIX: sinon: Imax = Ur>=config.test.max_voltage-.02;
% %instant a Umin
% Imin = Ur==config.test.min_voltage;%FIX: sinon: Imin = Ur>=config.test.min_voltage+.02;

%ca marche avec  Bitrode LYP, verifier avec Mobicus
Imin = U<=(config.test.min_voltage+0.02);
Imax = U>=config.test.max_voltage-0.02;%BRICOLE essai 20171211_1609 HONORAT
%instants a SoC100 (ou presque I100cc: fin de charge CC)
I100cc = Ifincc & Imax;%ca marche pas pour LYP
Regime = I/config.test.capacity;
Ic20 = Regime<=0.05*1.1; % typiquement 0.05
% I100 = Ifincv & Imax;
I100 = (Ifincv & Imax) | (I100cc & Ic20);
%instants a SoC0 (ou presque I0cc: fin de decharge CC)
I0 = (Ifincv & Imin) | (I100cc & Ic20);
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
pRepos100 = ismember(tInis,datetime(I100r | I100ccr));
%phases de repos a SOC0
pRepos0 = ismember(tInis,datetime(I0r | I0ccr));

%1) phases capa decharge (CC):
%1.1. Iavg<0
%1.2.- finissent a SoC0 (I0cc)
%1.3.- sont precedes par une phase de repos a SoC100 (I100r ou I100ccr)
pCapaD = [phases.Iavg]<0 & ismember(tFins,datetime(I0cc));% & [0 pRepos100(1:end-1)];
%2) phases capa charge (CC):
%2.1.- Iavg>0
%2.2.- finissent a SoC100 (I100cc)
%2.3.- sont precedes par une phase de repos a SoC0 (I0r ou I0ccr)
pCapaC = [phases.Iavg]>0 & ismember(tFins,datetime(I100cc));% & [0 pRepos0(1:end-1)];
% pCapaC = [phases.Iavg]>0 & [0 pRepos0(1:end-1)];%LYP, BRICOLE
%3) phases de decharge residuelle
%1.1.- Iavg<0
%1.2.- finissent a SoC0 (I0)
%1.3.- sont precedes par une phase pCapaD
pCapaDV = [phases.Iavg]<0 & ismember(tFins,datetime(I0)) & [0 pCapaD(1:end-1)];
%4) phases de charge residuelle
%1.1.- Iavg>0
%1.2.- finissent a SoC100 (I100)
%1.3.- sont precedes par une phase pCapaC
pCapaCV = [phases.Iavg]>0 & ismember(tFins,datetime(I100)) & [0 pCapaC(1:end-1)];

%5) phases de mesure d'impedance
%5.0- detection de pulses:
Ipulse = m==1 & [0; m(1:end-1)]==3;

%5.1.- mode CC et dernier point avant en repos (3)
pR = ismember(tInis,datetime(Ipulse))& durees<=config.resistance.pulse_max_duration;
pZ = ismember(tInis,datetime(Ipulse))& durees<=config.impedance.pulse_max_duration;

%5.2.- duree minimale pour pR, tminR (10secondes); pour pW, tminW (300sec)
pR = pR & durees>=config.resistance.pulse_min_duration;
pZ = pZ & durees>=config.impedance.pulse_min_duration;
%5.3- duree minimale du repos avant?
pR = pR & [0 durees(1:end-1)]>=config.resistance.rest_min_duration;
pZ = pZ & [0 durees(1:end-1)]>=config.impedance.rest_min_duration;
%5.4- duree maximale du pulse pour l'identification d'un RC
% pRC=pR & durees<=config.impedance.pulse_max_duration ;
%5.5- duree maximale du pulse pour l'identification d'un CPE
% pCPE=pZ & durees<=config.impedance.pulse_max_duration ;
%TODO: 5.6.-verification echantillonnage pour eviter warnings calculR
%nb points repos > 3
%...
%repos immediatememnt anterieurs
pRr = [pR(2:end) false];
pZr = [pZ(2:end) false];
% pRCr = [pRC(2:end) false];
% pCPEr = [pCPE(2:end) false];



%ident_capacity
config.capacity.pCapaD = pCapaD;
config.capacity.pCapaC = pCapaC;

%ident_capacity
config.capacity.pCapaDV = pCapaDV;
config.capacity.pCapaCV = pCapaCV;

%filter by phase number:
if isfield(config.capacity, 'filter_phase_nr')
    if ~isempty(config.capacity.filter_phase_nr)
        ind_filter_phase_nr = ismember(1:length(phases),config.capacity.filter_phase_nr);
        config.capacity.pCapaD = config.capacity.pCapaD & ind_filter_phase_nr;
        config.capacity.pCapaC = config.capacity.pCapaC & ind_filter_phase_nr;
        config.capacity.pCapaDV = config.capacity.pCapaDV & ind_filter_phase_nr;
        config.capacity.pCapaCV = config.capacity.pCapaCV & ind_filter_phase_nr;
    end
end

%ident_r
%filter by phase number:
if isfield(config.resistance, 'filter_phase_nr')
    if ~isempty(config.resistance.filter_phase_nr)
        ind_filter_phase_nr = ismember(1:length(phases),config.resistance.filter_phase_nr);
        pR = pR & ind_filter_phase_nr;
        pRr = [pR(2:end) false];
    end
end
%TODO: filter by time

config.resistance.pR = pR;
config.resistance.instant_end_rest = tFins(pRr);%temps de fins de repos immediatememnt anterieur

%ident_z
%filter by phase number:
if isfield(config.impedance, 'filter_phase_nr')
    if ~isempty(config.impedance.filter_phase_nr)
        ind_filter_phase_nr = ismember(1:length(phases),config.impedance.filter_phase_nr);
        pZ = pZ & ind_filter_phase_nr;
    end
end
%TODO: filter by time
config.impedance.pZ = pZ;
config.impedance.instant_end_rest = tFins(pZr);%temps de fins de repos immediatememnt anterieur




%ident_ocv_by_points (par points)
config.ocv_points.pOCVr = durees>=config.ocv_points.rest_min_duration & ismember(tInis,datetime(IiniRepos));
config.ocv_points.pOCVr(1) = false; % repos initial jamais retenu pour OCV
%filter by phase number:
if isfield(config.ocv_points, 'filter_phase_nr')
    if ~isempty(config.ocv_points.filter_phase_nr)
        ind_filter_phase_nr = ismember(1:length(phases),config.ocv_points.filter_phase_nr);
        config.ocv_points.pOCVr = config.ocv_points.pOCVr & ind_filter_phase_nr;
    end
end


%ident_pseudo_ocv (pseudoOCV)
Regime = [phases.Iavg]./config.test.capacity;
config.pseudo_ocv.pOCVpC = config.capacity.pCapaC & abs(Regime)<config.pseudo_ocv.max_crate & abs(Regime)>config.pseudo_ocv.min_crate;
config.pseudo_ocv.pOCVpD = config.capacity.pCapaD & abs(Regime)<config.pseudo_ocv.max_crate & abs(Regime)>config.pseudo_ocv.min_crate;
%filter by phase number:
if isfield(config.pseudo_ocv, 'filter_phase_nr')
    if ~isempty(config.pseudo_ocv.filter_phase_nr)
        ind_filter_phase_nr = ismember(1:length(phases),config.pseudo_ocv.filter_phase_nr);
        config.pseudo_ocv.pOCVpC = config.pseudo_ocv.pOCVpC & ind_filter_phase_nr;
        config.pseudo_ocv.pOCVpD = config.pseudo_ocv.pOCVpD & ind_filter_phase_nr;
    end
end


%calcul_ica
config.ica.pICA = (config.capacity.pCapaC | config.capacity.pCapaD) & abs(Regime)<config.ica.max_crate;
% config.pICAC = config.pCapaC & abs(Regime)<config.regimeICAmax;
% config.pICAD = config.pCapaD & abs(Regime)<config.regimeICAmax;
%filter by phase number:
if isfield(config.ica, 'filter_phase_nr')
    if ~isempty(config.ica.filter_phase_nr)
        ind_filter_phase_nr = ismember(1:length(phases),config.ica.filter_phase_nr);
        config.ica.pICA = config.ica.pICA & ind_filter_phase_nr;
    end
end


if ismember('v',options)
    fprintf('OK\n');
end

end
