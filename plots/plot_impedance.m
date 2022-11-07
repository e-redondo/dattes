function hf = plot_impedance(impedance,title_str)
% plot_impedance plot impedance graphs
%
% plot_impedance(impedance,title_str)
% Use impedance structure to plot impedance graphs
%
% Usage:
% hf = plot_impedance(impedance,title_str)
% Inputs:
% For CPE topology
% - impedance [(1x1) struct] with fields:
%     - topology [string]: Impedance model topology
%     - r0 [kx1 double]: Ohmic resistance
%     - q [kx1 double]: CPEQ
%     - alpha [kx1 double]: CPEalpha
%     - crate [kx1 double]: C-Rate of each impedance measurement
%     - dod [kx1 double]: Depth of discharge of each impedance measurement
%     - time [kx1 double]: time of each impedance measurement
% For RC topology
% - impedance [(1x1) struct] with fields:
%     - topology [string]: Impedance model topology
%     - r0 [kx1 double]: Ohmic resistance
%     - r1 [kx1 double]: R1 resistance
%     - C1 [kx1 double]: C1 capacity
%     - r2 [kx1 double]: R2 resistance
%     - C2 [kx1 double]: C2 capacity
%     - crate [kx1 double]: C-Rate of each impedance measurement
%     - dod [kx1 double]: Depth of discharge of each impedance measurement
%     - time [kx1 double]: time of each impedance measurement
% - title_str: [string] title string
% Output:
% - hf [1x1 figure handler]: handler for created figure
%
% See also dattes, dattes_plot, configurator, extract_profiles
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

if ~exist('title_str','var')
    title_str = '';
end
fieldlist = fieldnames(impedance);
[~, parameters] = regexpFiltre(fieldlist,'dod');
[~, parameters] = regexpFiltre(parameters,'time');
[~, parameters] = regexpFiltre(parameters,'crate');
[~, parameters] = regexpFiltre(parameters,'topology');

for ind = 1:length(parameters)
fig_title = sprintf('impedance topology: %s, parameter: %s',...
                     impedance.topology,parameters{ind});
hf = figure('name',fig_title);hold on
subplot(221),plot(impedance.dod,impedance.(parameters{ind}),'o')
xlabel('DoD (Ah)','interpreter','tex')
ylabel(parameters{ind},'interpreter','tex')
title(title_str,'interpreter','none')

subplot(222),plot(impedance.crate,impedance.(parameters{ind}),'o')
xlabel('C-rate (C)','interpreter','tex')
ylabel(parameters{ind},'interpreter','tex')

subplot(2,2,[3 4]),plot(impedance.datetime,impedance.(parameters{ind}),'o')
xlabel('time (s)','interpreter','tex')
ylabel(parameters{ind},'interpreter','tex')

%Look for all axis handles and ignore legends
ha = findobj(hf,'type','axes','tag','');
prettyAxes(ha);
changeLine(ha,2,15);
end

end
