function plot_eis(eis,title,options)
% plot_eis plot eis graphs
%
% plot_eis(eis,titre,options)
% Use eis structure to plot eis graphs
%
% Usage:
% plot_eis(eis,titre,options)
% Inputs:
% - eis [mx1 struct] with fields:
%   - ReZ [px1 double]: Real part of impedance 
%   - ImZ [px1 double]: Imaginary part of impedance 
% - title: [string] title string
%
% See also dattes, dattes_plot, configurator, extract_profiles
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

if ~exist('options','var')
    options = '';
end

hf = figure;
for ind = 1:length(eis.ReZ)
    plot(eis.ReZ{ind},eis.ImZ{ind},'.-'),hold on
end
title(title,'interpreter','none')

end