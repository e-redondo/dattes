function hf = plot_impedance_eis(eis,title_str,options)
% plot_impedance_eis plot eis impedance identification results
%
% plot_impedance_eis(eis,titre,options)
% Use result.analyse.eis structure from DATTES.
%
% Usage:
% plot_impedance_eis(eis,titre,options)
% Inputs:
% - eis [mx1 struct] with fields:
%   - ReZ [px1 double]: Real part of impedance 
%   - ImZ [px1 double]: Imaginary part of impedance 
% - title: [string] title string
% Output:
% - hf [1x1 figure handler]: handler for created figure
%
% See also dattes, dattes_plot, configurator, extract_profiles
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

if ~exist('options','var')
    options = '';
end

%TODO check eis struct

hf = figure;
for ind = 1:length(eis)
    tag_m = sprintf('EIS measure nr:%d',ind);
    tag_sim = sprintf('EIS simulation nr:%d',ind);
    %plot measure
    hl = plot(conj(eis(ind).Zmeas),'o','displayname',tag_m);hold on
    %plot simulation
    plot(conj(eis(ind).Zsim),'-','color',hl.Color,'displayname',tag_sim)
end
set(gca,'DataAspectRatio',[1 1 1],'PlotBoxAspectRatio',[1 1 1])
title(title_str,'interpreter','none')
legend show
end
