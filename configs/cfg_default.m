function config = cfg_default(config)
% cfg_default Create default configuration for dattes.
%
% Usage:
% config = cfg_default(config)
%
% Inputs:
% - config [(1x1) struct]: config struct from a cfg_file, with fields:
%         .test [(1x1) struct], with fields:
%              .max_voltage [(1x1) double]: cell max voltage
%              .min_voltage [(1x1) double]: cell min voltage
%              .capacity [(1x1) double]: cell nominal capacity (Ah)
%
% Outputs:
% - config [(1x1) struct]: config struct from a cfg_file, with fields:
%         .test [(1x1) struct], with fields:
%              .max_voltage [(1x1) double]: cell max voltage
%              .min_voltage [(1x1) double]: cell min voltage
%              .capacity [(1x1) double]: cell nominal capacity (Ah)
%
% See also configurator

%check inputs (minimal info from config):
if ~isfield(config,'test')
    err_msg = sprintf(['cfg_default: missing minimal info in config\n'...
               'missing config.test.max_voltage, '...
               'config.test.min_voltage, config.test.capacity']);
elseif ~isfield(config.test,'max_voltage')
    err_msg = sprintf(['cfg_default: missing minimal info in config\n'...
               'missing config.test.max_voltage']);
elseif ~isfield(config.test,'min_voltage')
    err_msg = sprintf(['cfg_default: missing minimal info in config\n'...
               'missing config.test.min_voltage']);   
elseif ~isfield(config.test,'capacity')
    err_msg = sprintf(['cfg_default: missing minimal info in config\n'...
               'missing config.test.capacity']); 
else
    err_msg = '';
end

if ~isempty(err_msg)
    error(err_msg);
end
 
% soc ('S' action):
config.soc.crate_cv_end = 1/20;

% impedance ('Z' action):
config.impedance.ident_fcn = @ident_cpe;% use ident_cpe
% config.impedance.ident_fcn = @ident_rrc;% use ident_rrc
config.impedance.pulse_min_duration = 299;% minimal pulse 300sec
config.impedance.pulse_max_duration = 599;% maximal pulse 600sec
config.impedance.rest_min_duration = 299;% minimal rest before 300sec
config.impedance.fixed_params = false;% not fixed params
% config.impedance.fixed_params = 0.5;% ident_cpe 2nd param fixed to 0.5
config.impedance.initial_params = [1000, 0.5];% Q0 = 1000, alpha0 = 0.5

%ident_R
config.instant_calcul_R=[0 4 9 29 59]; %Instant du pulse auquel on mesure R (par défaut 0 secondes)
config.minimal_duration_pulse = 9;%duree min d'un pulse pour resistance
config.minimal_duration_rest_before_pulse =9;%duree min repos avant

% ident_RC

config.maximal_duration_pulse = 600; % Durée maximale pour l'identification d'un RC
config.R1ini = 1e-3;
config.C1ini = 150;

config.R2ini = 1e-2;
config.C2ini = 400;

config.Rmin=1e-4;
config.Cmin=50;
config.Rmax=5e-2;
config.Cmax=800;


%ident_CPE2
% config.maximal_duration_pulse = 600; % Durée maximale pour l'identification d'un CPE


% config.minimal_duration_rest_before_pulse =59;
% config.instant_calcul_R=[0]; % Only one instant can be considered
% config.tminW = 59;%duree min d'un pulse pour diffusion
% config.tminWr = 299;%duree min repos avant
% config.CPEafixe = 0.5;%ident CPE2: valeur d'alpha du CPE (si = zero, alpha non fixe).
% config.ident_z = @ident_cpe;%fcn handler for impedance identification


%ident_OCVr
config.tminOCVr = 35;%duree min repos pour prise de point OCV
config.dodmaxOCVr = 0.3;%delta soc max prise de point OCV en p.u. (0.5 = 50% soc)
config.dodminOCVr = 0.01;%delta soc min prise de point OCV en p.u. (0.01 = 1% soc)

%ICA
config.dQ = config.test.capacity/100;%dQ pour essaiICA
config.dU = (config.test.max_voltage-config.test.min_voltage)/100;%dU pour essaiICA
config.regimeICAmax = 0.25;%regime max pour ICA
config.n_filter=3;%filter order
config.wn_filter=0.1;%filter cut frequency
config.filter_type='G';%filter type ('G' = gaussian)

%pseudoOCV
config.regimeOCVmax = 1;%regime max pour pseudoOCV (C/5)
config.regimeOCVmin = 0;%regime max pour pseudoOCV (C/5)
config.dQOCV = config.test.capacity/100;%dQ pour pseudoOCV

%bancs monovoies:
config.test.Uname = 'U';% default
%multichannel cyclers:
% config.test.Uname = 'U1';
% config.test.Uname = 'U2';
% config.test.Uname = 'U3';
%etc.
%temperature probes:
config.test.Tname = '';%default (no probe)
%multichannel cyclers:
% config.test.Tname = 'T1';
% config.test.Tname = 'T2';
% config.test.Tname = 'T3';
% etc.

%Graphics:
config.GdDureeMin=300;%duree min pour afficher la phase dans dattes(XML,'','Gd')
config.GdmaxPhases=100;%nombre de phases à partir duquel on doit appliquer GdDureeMin
end
