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

if  ~exist('config','var')
    config = struct;
end

if ~isstruct(config)
    error('cfg_default: input parameter must be a struct');
end
%check inputs (minimal info from config):
% if ~isfield(config,'test')
%     err_msg = sprintf(['cfg_default: missing minimal info in config\n'...
%                'missing config.test.max_voltage, '...
%                'config.test.min_voltage, config.test.capacity']);
% elseif ~isfield(config.test,'max_voltage')
%     err_msg = sprintf(['cfg_default: missing minimal info in config\n'...
%                'missing config.test.max_voltage']);
% elseif ~isfield(config.test,'min_voltage')
%     err_msg = sprintf(['cfg_default: missing minimal info in config\n'...
%                'missing config.test.min_voltage']);   
% elseif ~isfield(config.test,'capacity')
%     err_msg = sprintf(['cfg_default: missing minimal info in config\n'...
%                'missing config.test.capacity']); 
% else
%     err_msg = '';
% end
% 
% if ~isempty(err_msg)
%     error(err_msg);
% end
 
% soc ('S' action):
config.soc.crate_cv_end = 1/20;

%ident_R
% config.resistance.delta_time = [0 5 10 30 60]; % config.instant_calcul_R %Instant du pulse auquel on mesure R (par défaut 0 secondes)
config.resistance.delta_time = [2 10]; % config.instant_calcul_R %Instant du pulse auquel on mesure R (par défaut 0 secondes)
config.resistance.pulse_min_duration = 9; %config.minimal_duration_pulse = 9;%duree min d'un pulse pour resistance
config.resistance.pulse_max_duration = 600;% maximal pulse 600sec
config.resistance.rest_min_duration = 9; % config.minimal_duration_rest_before_pulse =9;%duree min repos avant
config.resistance.filter_phase_nr = [];
% impedance ('Z' action):
config.impedance.pulse_min_duration = 59;% minimal pulse 60sec
config.impedance.pulse_max_duration = 600;% maximal pulse 600sec
config.impedance.rest_min_duration = 9;% minimal rest before 300sec
config.impedance.ident_fcn = @ident_cpe;% use ident_cpe
% config.impedance.ident_fcn = @ident_rrc;% use ident_rrc
config.impedance.fixed_params = false;% not fixed params
% config.impedance.fixed_params = 0.5;% ident_cpe 2nd param fixed to 0.5
config.impedance.initial_params = [1000, 0.5];% ident_cpe: Q0 = 1000, alpha0 = 0.5
% config.impedance.initial_params = [1e-3, 150, 1e-2, 400];% ident_rrc R1ini, C1ini, R2ini, C2ini
% config.impedance.min_params = [1e-4, 50, 1e-4, 50];% ident_rrc
% config.impedance.max_params = [5e-2, 800, 5e-2, 800];% ident_rrc
config.impedance.dod = [];
config.impedance.ocv = [];
config.impedance.filter_phase_nr = [];


% config.Rmin=1e-4;
% config.Cmin=50;
% config.Rmax=5e-2;
% config.Cmax=800;

%ident_OCVr
config.ocv_points.rest_min_duration = 35;% (tminOCVr) minimal duration for a constant current phase to be used for OCV measurement
config.ocv_points.max_delta_dod_ah = 0.3;% (dodmaxOCVr) maximal dod variation to be taken into account for OCV measurement (p.u., 0.5 = 50% soc)
config.ocv_points.min_delta_dod_ah = 0.01;% (dodminOCVr) minimal dod variation to be taken into account for OCV measurement (p.u., 0.5 = 50% soc)

%ICA
if isfield(config,'test')
    if isfield(config.test,'capacity')
        % (dQ) for ICA test
        config.ica.capacity_resolution = config.test.capacity/100;
    end
    if isfield(config.test,'max_voltage') && isfield(config.test,'min_voltage')
        % (dU) for ICA test
        config.ica.voltage_resolution = (config.test.max_voltage-config.test.min_voltage)/100;
    end
end
config.ica.max_crate = 0.2;% (regimeICAmax) maximal current rate for ICA
config.ica.filter_type = 'A';%filter type (N: no filter,G: gaussian filter,A: mean filter,B: butter filter)
config.ica.filter_order = 100;%for gaussian (see essaiICA2); change ident_ICA
config.ica.filter_cut = 1;%for gaussian (see essaiICA2); change ident_ICA

% These parameters work well sometimes:
% config.ica.filter_type = 'G';%filter type (N: no filter,G: gaussian filter,A: mean filter,B: butter filter)
% config.ica.filter_order = 30;%for gaussian (see essaiICA2); change ident_ICA
% config.ica.filter_cut = 10;%for gaussian (see essaiICA2); change ident_ICA



%pseudoOCV
config.pseudo_ocv.max_crate = 1.05;% (regimeOCVmax) maximal current rate for pseudoOCV (1C + 5%)
config.pseudo_ocv.min_crate = 0;% (regimeOCVmin) minimal current rate forpseudoOCV (0)
if isfield(config,'test')
    if isfield(config.test,'capacity')
        % (dQOCV) for pseudoOCV
        config.pseudo_ocv.capacity_resolution = config.test.capacity/100;
    end
end

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

end
