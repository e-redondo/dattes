function plot_pseudo_ocv(pseudo_ocv)
% plot_pseudo_ocv plot pseudo ocv graphs
%
% plot_pseudo_ocv(pseudo_ocv)
% Use pseudo_ocv structure to plot pseudo ocv graphs
%
% Usage:
% plot_pseudo_ocv(pseudo_ocv)
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
%
% See also dattes, dattes_plot, configurator, extract_profiles
%
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

hf = figure('name','ident pOCV');hold on
for ind = 1:length(pseudo_ocv)
plot(pseudo_ocv(ind).dod,pseudo_ocv(ind).u_charge,'b-','tag','charge (points)')
plot(pseudo_ocv(ind).dod,pseudo_ocv(ind).u_discharge,'r-','tag','discharge (points)')
plot(pseudo_ocv(ind).dod,pseudo_ocv(ind).ocv,'k-','tag','pseudoOCV')
end
ylabel('voltage [V]'),xlabel('DoD [Ah]')

%Look for all axis handles and ignore legends
ha = findobj(hf,'type','axes','tag','');
prettyAxes(ha);
changeLine(ha,2,15);
end