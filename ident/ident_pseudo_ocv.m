function [pseudo_ocv] = ident_pseudo_ocv(t,U,DoDAh,config,phases,options)
%ident_pseudo_ocv pseudoOCV identification
%
% Usage:
% [pseudo_ocv] = ident_pseudo_ocv(t,U,DoDAh,config,phases,options)
%
% Inputs:
% - t,U,DoDAh [(nx1) double]: from extract_profiles and calcul_soc
% - config [(1x1) struct]: from configurator
% - phases [(mx1) struct]: from split_phases
% - options [(1xp) string]: execution options
%
% Outputs:
% - pseudo_ocv [(qx1) struct]: if found "q" pairs charge/discharge half
% cycles of equal C-rate, with fields:
%      - ocv [(kx1) double]: pseudo_ocv vector
%      - dod [(kx1) double]: depth of discharge vector
%      - polarization [(kx1) double]: difference between charge and discharge
%      - efficiency [(kx1) double]: u_charge over u_discharge
%      - u_charge [(kx1) double]: voltage during charging half cycle
%      - u_discharge [(kx1) double]: voltage during discharging half cycle
%      - crate [(1x1) double]: C-rate
%      - time [(1x1) double]: time of measurement
%
% See also dattes, configurator
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.


%% check inputs:
pseudo_ocv = struct([]);

if nargin<6 || nargin>7
    fprintf('ident_pseudo_ocv: wrong number of parameters, found %d\n',nargin);
    return;
end
if ~isstruct(phases) || ~isstruct(config) || ~ischar(options)
    fprintf('ident_pseudo_ocv: wrong type of parameters\n');
    return;
end
if ~isfield(config,'pseudo_ocv')
    fprintf('ident_pseudo_ocv: incomplete structure config, redo configurator: dattes(''cs'')\n');
    return;
end
if ~isfield(config.pseudo_ocv,'pOCVpC') || ~isfield(config.pseudo_ocv,'pOCVpD') || ~isfield(config.pseudo_ocv,'capacity_resolution') 
    fprintf('ident_pseudo_ocv: incomplete structure config, redo configurator: dattes(''cs'')\n');
    return;
end



if ~exist('options','var')
    options = '';
end
%si plus d'une phase en charge ou plus d'une phase en decharge > ERREUR

phases_ocv_charge = phases(config.pseudo_ocv.pOCVpC);
phases_ocv_discharge = phases(config.pseudo_ocv.pOCVpD);

%default values: empty arrays
ocv = [];
dod = [];
polarization = [];
efficiency = [];
u_charge = [];
u_discharge = [];
crate = [];
pTime = [];

%error management, if no pseudoOCV phases, return empty arrays
if isempty(phases_ocv_charge) || isempty(phases_ocv_discharge)
    fprintf('ident_pseudo_ocv: ERREUR nombre de phases incorrect\n');
    return
end

current_rate_charge = [phases_ocv_charge.Iavg]/config.test.capacity;
timeC = [phases_ocv_charge.t_fin];
[current_rate_charge sorting_index_current_rate_charge] = sort(current_rate_charge);%on met dans l'ordre
phases_ocv_charge = phases_ocv_charge(sorting_index_current_rate_charge);
timeC = timeC(sorting_index_current_rate_charge);

rapports = current_rate_charge(1:end-1)./current_rate_charge(2:end);%on calcule les rapports
filter_index_current_rate_charge = [true rapports<.99];% on filtre les doublons (99%)
current_rate_charge = current_rate_charge(filter_index_current_rate_charge);
phases_ocv_charge = phases_ocv_charge(filter_index_current_rate_charge);
timeC = timeC(filter_index_current_rate_charge);

current_rate_discharge = -[phases_ocv_discharge.Iavg]/config.test.capacity;
timeD = [phases_ocv_discharge.t_fin];
[current_rate_discharge sorting_index_current_rate_discharge] = sort(current_rate_discharge);%on met dans l'ordre
phases_ocv_discharge = phases_ocv_discharge(sorting_index_current_rate_discharge);
timeD = timeD(sorting_index_current_rate_discharge);

rapports = current_rate_discharge(1:end-1)./current_rate_discharge(2:end);%on calcule les rapports
filter_index_current_rate_discharge = [true rapports<.99];% on filtre les doublons (99%)
current_rate_discharge = current_rate_discharge(filter_index_current_rate_discharge);
phases_ocv_discharge = phases_ocv_discharge(filter_index_current_rate_discharge);
timeD = timeD(filter_index_current_rate_discharge);

for ind = 1:length(current_rate_discharge)
    this_crate_discharge = current_rate_discharge(ind);
    delta = abs(1-current_rate_charge/this_crate_discharge);
   %trouver le regime en charge le plus proche pour chaque decharge
   [~,index_sorting_charge(ind)] = min(delta);
end
%rearrange charges according to the discharges
phases_ocv_charge = phases_ocv_charge(index_sorting_charge);
timeC = timeC(index_sorting_charge);
crate = current_rate_discharge;

if length(unique(index_sorting_charge))<index_sorting_charge

    fprintf('ident_pseudo_ocv: ERREUR à gerer\n');
    return
end


voltage_charge = cell(size(phases_ocv_charge));
dod_ah_charge = cell(size(phases_ocv_charge));
voltage_discharge = cell(size(phases_ocv_discharge));
dod_ah_discharge = cell(size(phases_ocv_discharge));

for ind =1:length(phases_ocv_charge)
    %extraire les phases
    [~,voltage_charge{ind},dod_ah_charge{ind}] = extract_phase(phases_ocv_charge(ind),t,U,DoDAh);
end

for ind =1:length(phases_ocv_discharge)
%extraire les phases
[~,voltage_discharge{ind},dod_ah_discharge{ind}] = extract_phase(phases_ocv_discharge(ind),t,U,DoDAh);
end

%mettre dans l'ordre (et enleve doublons) TODO: ameliorer

[dod_ah_charge_sorted, sorting_index_current_rate_charge] = cellfun(@unique,dod_ah_charge,'uniformoutput',false);
voltage_charge_sorted = cellfun(@(x,y) x(y),voltage_charge,sorting_index_current_rate_charge,'uniformoutput',false);

%mettre dans l'ordre (et enleve doublons) TODO: ameliorer
[dod_ah_discharge_sorted, sorting_index_current_rate_discharge] = cellfun(@unique,dod_ah_discharge,'uniformoutput',false);
voltage_discharge_sorted = cellfun(@(x,y) x(y),voltage_discharge,sorting_index_current_rate_discharge,'uniformoutput',false);


%TODO: aller jusqu'à la fin, ne pas rester a CapaNom
dod = (0:config.pseudo_ocv.capacity_resolution:config.test.capacity)';
% u_charge = interp1(dod_ah_charge_sorted,voltage_charge_sorted,dod);
% u_discharge = interp1(dod_ah_discharge_sorted,voltage_discharge_sorted,dod);

u_charge = cellfun(@(x,y) interp1(x,y,dod),dod_ah_charge_sorted,voltage_charge_sorted,'uniformoutput',false);
u_discharge = cellfun(@(x,y) interp1(x,y,dod),dod_ah_discharge_sorted,voltage_discharge_sorted,'uniformoutput',false);

%ancienne methode: moyenne entre plusieurs
% %TODO: traitement des NaN separement
% u_charge = mean(cell2mat(u_charge),2);
% u_discharge = mean(cell2mat(u_discharge),2);
% %TODO: ponderer en fonction du regime charge/decharge
% ocv = (u_charge+u_discharge)/2;
% polarization = u_charge-u_discharge;
%nouvelle methode un couple de courbes par regime
ocv = cellfun(@(x,y) (x+y)/2,u_charge,u_discharge,'uniformoutput',false);
polarization = cellfun(@(x,y) (x-y),u_charge,u_discharge,'uniformoutput',false);
efficiency = cellfun(@(x,y) (y./x),u_charge,u_discharge,'uniformoutput',false);
pTime = max(timeC,timeD);

if ismember('g',options)
    showResult(voltage_charge,dod_ah_charge,voltage_discharge,dod_ah_discharge,dod,u_charge,u_discharge,ocv);
end

%convert to pseudo_ocv struct:
for ind = 1:length(ocv)
    pseudo_ocv(ind).ocv = ocv{ind};
    pseudo_ocv(ind).dod = dod;
    pseudo_ocv(ind).polarization = polarization{ind};
    pseudo_ocv(ind).efficiency = efficiency{ind};
    pseudo_ocv(ind).u_charge = u_charge{ind};
    pseudo_ocv(ind).u_discharge = u_discharge{ind};
    pseudo_ocv(ind).crate = crate(ind);
    pseudo_ocv(ind).time = pTime(ind);
end
end

function showResult(voltage_charge,dod_ah_charge,voltage_discharge,dod_ah_discharge,dod,u_charge,u_discharge,ocv)

hf = figure('name','ident_pseudo_ocv');hold on
cellfun(@(x,y) plot(x,y,'b.-','tag','charge (mesure)'),dod_ah_charge,voltage_charge)
cellfun(@(x,y) plot(x,y,'r.-','tag','decharge (mesure)'),dod_ah_discharge,voltage_discharge)


cellfun(@(x,y) plot(dod,x,'b*','tag','charge (points)'),u_charge)
cellfun(@(x,y) plot(dod,x,'r*','tag','decharge (points)'),u_discharge)
cellfun(@(x,y) plot(dod,x,'k-','tag','pseudoOCV'),ocv)

ylabel('voltage [V]'),xlabel('DoD [Ah]')

%Look for all axis handles and ignore legends
ha = findobj(hf,'type','axes','tag','');
prettyAxes(ha);
changeLine(ha,2,15);
end
