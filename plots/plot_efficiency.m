function hf = plot_efficiency(pseudo_ocv)
% plot_efficiency plot efficiency graphs
%
% plot_ocv_by_points(t,U,DoDAh, ocv_by_points)
% Use pDoD and pEff structure to plot efficiency graphs
%
% Usage:
% hf = plot_efficiency(pDoD, pEff)
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
%See also dattes, dattes_plot, configurator, extract_profiles
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.


hf = figure('name','ident pOCV(Effi)');hold on
for ind = 1:length(pseudo_ocv)
plot(pseudo_ocv(ind).dod,pseudo_ocv(ind).efficiency,'k-','tag','efficiency')
end
ylabel('efficiency [p.u.]'),xlabel('DoD [Ah]')

%Look for all axis handles and ignore legends
ha = findobj(hf,'type','axes','tag','');
prettyAxes(ha);
changeLine(ha,2,15);
end
