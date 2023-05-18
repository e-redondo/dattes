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


Idis = impedance.crate<0;
Icha = impedance.crate>0;

for ind = 1:length(parameters)

    if isempty(title_str)
        fig_title = sprintf('DATTES impedance. Topology: %s, parameter: %s',...
                     impedance.topology,parameters{ind});
    else
         fig_title = sprintf('DATTES impedance (%s). Topology: %s, parameter: %s',...
                     title_str,impedance.topology,parameters{ind});       
    end
hf = figure('name',fig_title);hold on
subplot(221),hold on
xlabel('DoD [Ah]','interpreter','tex')
ylabel(parameters{ind},'interpreter','tex')
title(sprintf('%s vs DoD',parameters{ind}))
z = impedance.(parameters{ind});
z_cha = z(Icha);
z_dis = z(Idis);

plot(impedance.dod(Icha),z_cha,'^','displayname','charge')
plot(impedance.dod(Idis),z_dis,'v','displayname','discharge')

subplot(222),hold on
xlabel('C-rate [C]','interpreter','tex')
ylabel(parameters{ind},'interpreter','tex')
title(sprintf('%s vs C-rate',parameters{ind}))

plot(impedance.crate(Icha),z_cha,'^','displayname','charge')
plot(impedance.crate(Idis),z_dis,'v','displayname','discharge')


subplot(2,2,[3 4]),hold on
xlabel('datetime [s]','interpreter','tex')
ylabel(parameters{ind},'interpreter','tex')
title(sprintf('%s vs datetime',parameters{ind}))

plot(impedance.datetime(Icha),z_cha,'^','displayname','charge')
plot(impedance.datetime(Idis),z_dis,'v','displayname','discharge')

legend show;
legend('location','best')

%Look for all axis handles except legends
ha = findobj(hf,'type','axes','tag','');
prettyAxes(ha);
changeLine(ha,1,5);
end

end
