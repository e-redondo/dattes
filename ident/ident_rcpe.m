function [impedance] = ident_rcpe(datetime,U,I,dod_ah,config,phases,options)
% ident_rcpe impedance identification of a R+CPE topology
%
%
% Usage:
% [impedance] = ident_rcpe(datetime,U,I,dod_ah,config,phases,options)
% Read the config and phases structure and performe several calculations
% regarding impedance analysis.  Results are returned in the structure impedance analysis 
%
% Inputs:
% - datetime [nx1 double]: datetime in seconds
% - U [nx1 double]: cell voltage in V
% - I [nx1 double]: cell current in A
% - dod_ah [nx1 double]: depth of discharge in AmpHours
% - config [1x1 struct]: config struct from configurator
% - phases [1x1 struct]: phases struct from decompose_phases
% - options [string]
%   - 'v': verbose, tell what you do
%
% Output:
% - impedance [(1x1) struct] with fields:
%     - topology [string]: Impedance model topology
%     - r0 [kx1 double]: Ohmic resistance
%     - q [kx1 double]: CPEQ
%     - alpha [kx1 double]: CPEalpha
%     - crate [kx1 double]: C-Rate of each impedance measurement
%     - dod [kx1 double]: Depth of discharge of each impedance measurement
%     - datetime [kx1 double]: datetime of each impedance measurement
%
% See also dattes_analyse, calcul_rcpe_pulse, ident_cpe, ident_rrc
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.



if ~exist('options','var')
    options = '';
end
if ismember('v',options)
    fprintf('ident_rcpe:...');
end

%% check inputs:
impedance=struct([]);

if nargin<6 || nargin>8
    fprintf('ident_rcpe: wrong number of parameters, found %d\n',nargin);
    return;
end
if ~isstruct(config) || ~ischar(options) || ~isnumeric(datetime) || ~isstruct(phases)   || ~isnumeric(U) || ~isnumeric(I) || ~isnumeric(dod_ah)
    fprintf('ident_rcpe: wrong type of parametres\n');
    return;
end
if ~isfield(config,'impedance')
    fprintf('ident_rcpe: config struct incomplete\n');
    return;
end
if ~isfield(config.impedance,'pulse_min_duration') || ...
       ~isfield(config.impedance,'pulse_max_duration') || ...
       ~isfield(config.impedance,'rest_min_duration') || ...
       ~isfield(config.impedance,'fixed_params') || ...
       ~isfield(config.impedance,'initial_params')   
    fprintf('ident_rcpe: config struct incomplete\n');
    return;
end

%% 1- Initialization
q = [];
alpha = [];
resistance = [];
dod = [];
crate = [];
datetime_cpe = [];

%% 2- Determine the phases for which a CPE identification is relevant
indices_cpe = find(config.impedance.pZ);
rest_duration_before_pulse=config.impedance.rest_min_duration;
pulse_max_duration = config.impedance.pulse_max_duration;
rest_before_after_phase = [rest_duration_before_pulse 0];
phases_identify_cpe=phases(config.impedance.pZ);

%% 3-q and alpha are identified for each of these phases
for phase_k = 1:length(indices_cpe)
    [datetime_phase,voltage_phase,current_phase,dod_phase] = extract_phase2(phases(indices_cpe(phase_k)),rest_before_after_phase,datetime,U,I,dod_ah);

        %cut pulse to max duration if necessary:
    ind_pulse = datetime_phase<=datetime_phase(1)+rest_duration_before_pulse+pulse_max_duration;
    datetime_phase = datetime_phase(ind_pulse);
    voltage_phase =  voltage_phase(ind_pulse);
    current_phase =  current_phase(ind_pulse);
    dod_phase =  dod_phase(ind_pulse);

        % Step time is reduced to maximize the identification accuracy
    time_step = 0.1;
    tmi = (datetime_phase(1):time_step:datetime_phase(end))';
    voltage_phase = interp1(datetime_phase,voltage_phase,tmi);
    current_phase = interp1(datetime_phase,current_phase,tmi);
    dod_phase = interp1(datetime_phase,dod_phase,tmi);
    datetime_phase = tmi;
    
    
    % get ocv from dod_ah and previous tests (pseudo_ocv or ocv_points)
    ocv_phase = zeros(size(dod_phase));
    if isfield(config.impedance,'ocv')
        if isvector(config.impedance.ocv) && isequal(size(config.impedance.dod),size(config.impedance.ocv))
            ocv_phase = interp1(config.impedance.dod,config.impedance.ocv,dod_phase,'linear','extrap');
        end
    end
    %Remove OCV:
    voltage_phase = voltage_phase-ocv_phase;
    
    %Remove relaxation
    
    %Relaxation voltage is removed
    open_circuit_voltage = voltage_phase(1);
    voltage_phase  = voltage_phase-open_circuit_voltage; 

    if ~config.impedance.fixed_params
        [resistance_phase, q_phase, alpha_phase, ~, crate_phase] = calcul_rcpe_pulse(datetime_phase,voltage_phase,current_phase);
    else
        [resistance_phase, q_phase, alpha_phase, ~, crate_phase] = calcul_rcpe_pulse(datetime_phase,voltage_phase,current_phase,'a',config.impedance.fixed_params);
    end
    
    q=[q q_phase];
    alpha=[alpha alpha_phase];
    crate=[crate crate_phase];
    %TODO: datetime_cpe = [datetime_cpe this_phase.datetime_ini];
    datetime_cpe = [datetime_cpe datetime_phase(1)];
    dod = [dod dod_phase(1)];
    resistance=[resistance resistance_phase];
end
crate = crate/config.test.capacity;

if ismember('v',options)
    fprintf('OK\n');
end
    
impedance(1).topology = 'R0 + CPE';
impedance.q = q;
impedance.alpha = alpha;
impedance.r0 = resistance;
impedance.dod = dod;
impedance.crate = crate;
impedance.datetime = datetime_cpe;

end