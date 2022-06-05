function plot_efficiency(pDoD, pEff)
% plot_efficiency plot efficiency graphs
%
% plot_ocv_by_points(t,U,DoDAh, ocv_by_points)
% Use pDoD and pEff structure to plot efficiency graphs
%
% Usage:
% plot_efficiency(pDoD, pEff)
% Inputs:
% - pDoD [nx1 double]: Depth of discharge
% - pEff [nx1 double]: Efficiency
%
%See also dattes, dattes_plot, configurator, extract_profiles
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.


hf = figure('name','ident pOCV(Effi)');hold on
for ind = 1:length(pEff)
plot(pDoD,pEff{ind},'k-','tag','efficiency')
end
ylabel('efficiency [p.u.]'),xlabel('DoD [Ah]')

%Look for all axis handles and ignore legends
ha = findobj(hf,'type','axes','tag','');
prettyAxes(ha);
changeLine(ha,2,15);
end