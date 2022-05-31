function [impedance] = ident_cpe(t,U,I,dod_ah,config,phases,options)
%ident_cpe CPE (Constant phase element) impedance identification from a
% temporal profile (t,U,I,m).
%
% Usage:
% [impedance] = ident_cpe(t,U,I,dod_ah,config,options)
% - t,U,I,dod_ah (nx1 double) from extract_profiles
% - dod_ah (nx1 double) from calcul_soc
% - config (1x1 struct) from configurator
% - options (string)
%   - 'v': verbose, tell what you do
%
% See also calcul_cpe_pulse, dattes
if ~exist('options','var')
    options = '';
end
if ismember('v',options)
    fprintf('ident_cpe:...');
end

%% 0- Inputs management

if nargin<6 || nargin>8
    fprintf('ident_cpe: wrong number of parameters, found %d\n',nargin);
    return;
end
if ~isstruct(config) || ~ischar(options) || ~isnumeric(t) || ~isstruct(phases)   || ~isnumeric(U) || ~isnumeric(I) || ~isnumeric(dod_ah)
    fprintf('ident_cpe: wrong type of parametres\n');
    return;
end
if ~isfield(config,'tW') || ~isfield(config,'tminWr') || ~isfield(config,'tminW')
    fprintf('ident_cpe: config struct incomplete\n');
    return;
end
%% 1- Initialization
impedance=struct;
q = [];
alpha = [];
resistance = [];
dod = [];
crate = [];

%% 2- Determine the phases for which a CPE identification is relevant
indices_cpe = find(config.pCPE);
time_before_after_phase = [config.rest_duration_before_pulse 0];
% phases_identify_CPE=phases(config.pCPE);


%% 3-q and alpha are identified for each of these phases
for phase_k = 1:length(indices_cpe)
    [time_phase,voltage_phase,current_phase,dod_phase] = extract_phase2(phases(indices_cpe(phase_k)),time_before_after_phase,t,U,I,dod_ah);
%     for i=1:length(dod_phase)
%         if dod_phase(i)<0
%             dod_phase(i)=abs(dod_phase(i));
%         end
%     end

        
    
    %Ohmic polarization is extracted
    [R, crate] = calcul_r(time_phase,voltage_phase,current_phase,dod_phase,config.instant_end_rest(phase_k),config.minimal_duration_pulse,config.minimal_duration_rest_before_pulse ,config.instant_calcul_R);
    polarization_resistance = zeros(size(voltage_phase));
    polarization_resistance = current_phase*R(1);
    voltage_phase = voltage_phase-polarization_resistance;
    
       %Relaxation voltage is extracted
    open_circuit_voltage = voltage_phase(1);
    voltage_phase  = voltage_phase-open_circuit_voltage; 
    %TODO: comment transmettre 'g' a calculCPE? il genere beaucoup de
    %figures!!
    if ~config.CPEafixe
        [q(phase_k), alpha(phase_k), ~, crate(phase_k)] = calcul_cpe_pulse(time_phase,voltage_phase,current_phase);
    else
        [q(phase_k), alpha(phase_k), ~, crate(phase_k)] = calcul_cpe_pulse(time_phase,voltage_phase,current_phase,'a',config.CPEafixe);
    end
    time(phase_k) = t(t==config.tW(phase_k));
    dod(phase_k) = dod_ah(t==config.tW(phase_k));%TODO: DoD ini ou moyen?
    resistance(phase_k) = R(1);
end
crate = crate/config.Capa;

if ismember('v',options)
    fprintf('OK\n');
end


if ismember('g',options)
    show_result(t,U,I,dod_ah,q, alpha, dod, crate,time);
end

    
impedance.q = q;
impedance.alpha = alpha;
impedance.resistance = resistance;
impedance.dod = dod;
impedance.crate = crate;

end

function show_result(t,U,I,dod_ah,q, alpha, dod, crate,time)

hf = figure('name','ident_cpe');
subplot(3,2, [1 2]),plot(t,U,'b'),hold on,xlabel('time (s)'),ylabel('voltage (V)')

current_phase = ismember(t,time);
subplot(3,2, [1 2]),plot(t(current_phase),U(current_phase),'ro')
current_phase = ismember(t,time(isnan(q)));
subplot(3,2, [1 2]),plot(t(current_phase),U(current_phase),'rx')

% subplot(222),plot(t(current_phase),I(current_phase),'ro')
% subplot(223),plot(t(current_phase),dod_ah(current_phase),'ro')
% subplot(223),plot(time,q,'ro'),xlabel('time (s)')

subplot(323),plot(dod,q,'ro'),xlabel('DoD(Ah)')
subplot(324),plot(crate,q,'ro'),xlabel('Current(C)')
subplot(325),plot(dod,alpha,'ro'),xlabel('DoD(Ah)')
subplot(326),plot(crate,alpha,'ro'),xlabel('Current(C)')

%cherche tout les handles du type axe et ignore les legendes
ha = findobj(hf,'type','axes','tag','');
% printLegTag(ha,'eastoutside');
prettyAxes(ha);
% linkaxes(ha, 'x' );
changeLine(ha,2,15);
end