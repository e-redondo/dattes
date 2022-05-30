function plot_impedance(impedance,title_str)


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

subplot(2,2,[3 4]),plot(impedance.time,impedance.(parameters{ind}),'o')
xlabel('time (s)','interpreter','tex')
ylabel(parameters{ind},'interpreter','tex')

%cherche tout les handles du type axe et ignore les legendes
ha = findobj(hf,'type','axes','tag','');
prettyAxes(ha);
changeLine(ha,2,15);
end

end