function hf = plot_pseudo_ocv(pseudo_ocv,title_str)
% plot_pseudo_ocv plot pseudo ocv graphs
%
% Use pseudo_ocv structure to plot pseudo ocv graphs
%
% Usage:
% hf = plot_pseudo_ocv(pseudo_ocv)
% Inputs:
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
% Output:
% - hf [1x1 figure handler]: handler for created figure
%
% See also dattes, dattes_plot, configurator, extract_profiles
%
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

if isempty(title_str)
hf = figure('name','DATTES pseudo-OCV');
else
hf = figure('name',sprintf('DATTES pseudo-OCV: %s',title_str));
end

hold on

linestyles = {'-','--','-.'};
N = ceil(length(pseudo_ocv)/length(linestyles));
linestyles = repmat(linestyles,1,N);

for ind = 1:length(pseudo_ocv)

disp_name_c = sprintf('charge C-rate=%.2gC',pseudo_ocv(ind).crate);
disp_name_d = sprintf('discharge C-rate=%.2gC',pseudo_ocv(ind).crate);
disp_name_o = sprintf('pseudo OCV C-rate=%.2gC',pseudo_ocv(ind).crate);

plot(pseudo_ocv(ind).dod,pseudo_ocv(ind).u_charge,['b' linestyles{ind}],'displayname',disp_name_c)
plot(pseudo_ocv(ind).dod,pseudo_ocv(ind).u_discharge,['r' linestyles{ind}],'displayname',disp_name_d)
plot(pseudo_ocv(ind).dod,pseudo_ocv(ind).ocv,['k' linestyles{ind}],'displayname',disp_name_o)
end
ylabel('Voltage [V]'),xlabel('DoD [Ah]')
title('Voltage vs. DoD')
legend show;
legend('location','southwest')

%Look for all axis handles and ignore legends
ha = findobj(hf,'type','axes','tag','');
prettyAxes(ha);
changeLine(ha,1,5);
end
