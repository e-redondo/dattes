function [impedance] = ident_cpe(datetime,U,I,dod_ah,config,phases,options)
% ident_cpe impedance analysis of a R+RC+CPE topology
%
% [impedance] = ident_cpe(datetime,U,I,dod_ah,config,phases,options)
% Read the config and phases structure and performe several calculations
% regarding impedance analysis.  Results are returned in the structure impedance analysis 
%
% Usage:
% [impedance] = ident_cpe(datetime,U,I,dod_ah,config,phases,options)
% Inputs:
% - datetime [nx1 double]: datetime in seconds
% - U [nx1 double]: cell voltage in V
% - dod_ah [nx1 double]: depth of discharge in AmpHours
% - config [1x1 struct]: config struct from configurator
% - phases [1x1 struct]: phases struct from decompose_phases
% - options [string] containing:
%   - 'v': verbose, tell what you do
%   - 'g' : show figures
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
%See also dattes, calcul_cpe_pulse, configurator, extract_profiles
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.



if ~exist('options','var')
    options = '';
end
if ismember('v',options)
    fprintf('ident_cpe:...');
end

%% check inputs:
impedance=struct([]);

if nargin<6 || nargin>8
    fprintf('ident_cpe: wrong number of parameters, found %d\n',nargin);
    return;
end
if ~isstruct(config) || ~ischar(options) || ~isnumeric(datetime) || ~isstruct(phases)   || ~isnumeric(U) || ~isnumeric(I) || ~isnumeric(dod_ah)
    fprintf('ident_cpe: wrong type of parametres\n');
    return;
end
if ~isfield(config,'impedance')
    fprintf('ident_cpe: config struct incomplete\n');
    return;
end
if ~isfield(config.impedance,'pulse_min_duration') || ...
       ~isfield(config.impedance,'pulse_max_duration') || ...
       ~isfield(config.impedance,'rest_min_duration') || ...
       ~isfield(config.impedance,'fixed_params') || ...
       ~isfield(config.impedance,'initial_params')   
    fprintf('ident_cpe: config struct incomplete\n');
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
rest_before_after_phase = [rest_duration_before_pulse 0];
phases_identify_cpe=phases(config.impedance.pZ);

%% 3-q and alpha are identified for each of these phases
for phase_k = 1:length(indices_cpe)
    [datetime_phase,voltage_phase,current_phase,dod_phase] = extract_phase2(phases(indices_cpe(phase_k)),rest_before_after_phase,datetime,U,I,dod_ah);

        % Step time is reduced to maximize the identification accuracy
    time_step = 0.1;
    tmi = (datetime_phase(1):time_step:datetime_phase(end))';
    voltage_phase = interp1(datetime_phase,voltage_phase,tmi);
    current_phase = interp1(datetime_phase,current_phase,tmi);
    datetime_phase = tmi;
    
    
    
    %Ohmic polarization is extracted
    [resistance_phase, crate_phase] = calcul_r(datetime_phase,voltage_phase,current_phase,dod_phase,phases(indices_cpe(phase_k)).datetime_ini,9,config.impedance.rest_min_duration,0);
    polarization_resistance = zeros(size(voltage_phase));
    polarization_resistance = current_phase*resistance_phase(1);
    voltage_phase = voltage_phase-polarization_resistance;
    
    
    
       %Relaxation voltage is extracted
    open_circuit_voltage = voltage_phase(1);
    voltage_phase  = voltage_phase-open_circuit_voltage; 

    
    
    
    if ~config.impedance.fixed_params
        [q_phase, alpha_phase ~, crate_phase] = calcul_cpe_pulse(datetime_phase,voltage_phase,current_phase);
    else
        [q_phase, alpha_phase, ~, crate_phase] = calcul_cpe_pulse(datetime_phase,voltage_phase,current_phase,'a',config.impedance.fixed_params);
    end
    
    q=[q q_phase];
    alpha=[alpha alpha_phase];
    crate=[crate crate_phase];

    datetime_cpe = [datetime_cpe datetime_phase(1)];
    dod = [dod dod_phase(1)];
    resistance=[resistance resistance_phase(1)];
end
crate = crate/config.test.capacity;

if ismember('v',options)
    fprintf('OK\n');
end


if ismember('g',options)
    show_result(datetime,U,I,dod_ah,q, alpha, dod, crate,datetime);
end

    
impedance(1).topology = 'R0 + CPE';
impedance.q = q;
impedance.alpha = alpha;
impedance.r0 = resistance;
impedance.dod = dod;
impedance.crate = crate;
impedance.datetime = datetime_cpe;

end

function show_result(t,U,I,dod_ah,q, alpha, dod, crate,time)

hf = figure('name','ident_cpe');
subplot(3,2, [1 2]),plot(t,U,'b'),hold on,xlabel('time (s)'),ylabel('voltage (V)')

current_phase = ismember(t,time);
subplot(3,2, [1 2]),plot(t(current_phase),U(current_phase),'ro')
current_phase = ismember(t,time(isnan(q)));
subplot(3,2, [1 2]),plot(t(current_phase),U(current_phase),'rx')


subplot(323),plot(dod,q,'ro'),xlabel('DoD(Ah)')
subplot(324),plot(crate,q,'ro'),xlabel('Current(C)')
subplot(325),plot(dod,alpha,'ro'),xlabel('DoD(Ah)')
subplot(326),plot(crate,alpha,'ro'),xlabel('Current(C)')

%Look for all axis handles and ignore legends
ha = findobj(hf,'type','axes','tag','');
% printLegTag(ha,'eastoutside');
prettyAxes(ha);
% linkaxes(ha, 'x' );
changeLine(ha,2,15);
end
