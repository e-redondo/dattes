function [ocv, dod, polarization, efficiency,u_charge,u_discharge,crate] = ident_pseudo_ocv(t,U,DoDAh,config,phases,options)
%ident_pseudo_ocv pseudoOCV identification
%
% See also dattes, configurator

%si plus d'une phase en charge ou plus d'une phase en decharge > ERREUR

phases_ocv_charge = phases(config.pOCVpC);
phases_ocv_discharge = phases(config.pOCVpD);

%default values: empty arrays
    ocv = [];
    dod = [];
    polarization = [];
    efficiency = [];
    u_charge = [];
    u_discharge = [];
    crate = [];
    
%error management, if no pseudoOCV phases, return empty arrays
if isempty(phases_ocv_charge) || isempty(phases_ocv_discharge)
    fprintf('ident_pseudo_ocv: ERREUR nombre de phases incorrect\n');
    return
end

current_rate_charge = [phases_ocv_charge.Iavg]/config.Capa;
[current_rate_charge sorting_index_current_rate_charge] = sort(current_rate_charge);%on met dans l'ordre
phases_ocv_charge = phases_ocv_charge(sorting_index_current_rate_charge);
rapports = current_rate_charge(1:end-1)./current_rate_charge(2:end);%on calcule les rapports
filter_index_current_rate_charge = [true rapports<.99];% on filtre les doublons (99%)
current_rate_charge = current_rate_charge(filter_index_current_rate_charge);
phases_ocv_charge = phases_ocv_charge(filter_index_current_rate_charge);

current_rate_discharge = -[phases_ocv_discharge.Iavg]/config.Capa;
[current_rate_discharge sorting_index_current_rate_discharge] = sort(current_rate_discharge);%on met dans l'ordre
phases_ocv_discharge = phases_ocv_discharge(sorting_index_current_rate_discharge);
rapports = current_rate_discharge(1:end-1)./current_rate_discharge(2:end);%on calcule les rapports
filter_index_current_rate_discharge = [true rapports<.99];% on filtre les doublons (99%)
current_rate_discharge = current_rate_discharge(filter_index_current_rate_discharge);
phases_ocv_discharge = phases_ocv_discharge(filter_index_current_rate_discharge);

for ind = 1:length(current_rate_discharge)
    this_crate_discharge = current_rate_discharge(ind);
    delta = abs(1-current_rate_charge/this_crate_discharge);
   %trouver le regime en charge le plus proche pour chaque decharge
   [~,index_sorting_charge(ind)] = min(delta);
end
%rearrange charges according to the discharges
phases_ocv_charge = phases_ocv_charge(index_sorting_charge);
crate = current_rate_discharge;
if length(unique(index_sorting_charge))<index_sorting_charge
    fprintf('ident_pseudo_ocv: ERREUR à gerer\n');
    return
end

%BRICOLE pour SIMCAL KOKAM 12Ah
% if length(phases_ocv_charge)>3
%     phases_ocv_charge = phases_ocv_charge(1:3);
% end
% if length(phases_ocv_discharge)>2
%     phases_ocv_discharge = phases_ocv_discharge(1:2);
% end
% if length(phases_ocv_charge)~=1 || length(phases_ocv_discharge)~=1
%     ocv = [];
%     dod = [];
%     polarization = [];
%     fprintf('ident_pseudo_ocv: ERREUR nombre de phases incorrect\n');
%     return
% end
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
dod = (0:config.dQOCV:config.Capa)';
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

if ismember('g',options)
    showResult(voltage_charge,dod_ah_charge,voltage_discharge,dod_ah_discharge,dod,u_charge,u_discharge,ocv);
end
end

function showResult(voltage_charge,dod_ah_charge,voltage_discharge,dod_ah_discharge,dod,u_charge,u_discharge,ocv)

hf = figure('name','ident_pseudo_ocv');hold on
cellfun(@(x,y) plot(x,y,'b.-','tag','charge (mesure)'),dod_ah_charge,voltage_charge)
cellfun(@(x,y) plot(x,y,'r.-','tag','decharge (mesure)'),dod_ah_discharge,voltage_discharge)
% plot(dod,u_charge,'b*','tag','charge (points)')
% plot(dod,u_discharge,'r*','tag','decharge (points)')
% plot(dod,ocv,'k*-','tag','pseudoOCV')

cellfun(@(x,y) plot(dod,x,'b*','tag','charge (points)'),u_charge)
cellfun(@(x,y) plot(dod,x,'r*','tag','decharge (points)'),u_discharge)
cellfun(@(x,y) plot(dod,x,'k-','tag','pseudoOCV'),ocv)

ylabel('voltage [V]'),xlabel('DoD [Ah]')

%cherche tout les handles du type axe et ignore les legendes
ha = findobj(hf,'type','axes','tag','');
prettyAxes(ha);
changeLine(ha,2,15);
end