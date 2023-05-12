function hf = plot_r(resistance,title_str)
% plot_r plot resistance graphs
%
% Use resistance structure to plot resistance graphs
%
% Usage:
% hf = plot_r(resistance)
% Inputs:
% - resistance [(1x1) struct] with fields:
%     - R [(qx1) double]: resistance value (Ohms)
%     - dod [(qx1) double]: depth of discharge (Ah)
%     - crate [(qx1) double]: current rate (C)
%     - time [(qx1) double]: time of measurement (s)
%     - delta_time [(qx1) double]: time from pulse start (s)
% - title_str: [string] title string
% Output:
% - hf [1x1 figure handler]: handler for created figure
%
%See also dattes, dattes_plot, configurator, extract_profiles
%
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.


if ~exist('options','var')
    options = '';
end
if ~exist('title_str','var')
    title_str = '';
end

Idis = resistance.crate<0;
Icha = resistance.crate>0;
dt = unique(resistance.delta_time);

c = lines(length(dt));

if isempty(title_str)
hf = figure('name','DATTES Resistance');
else
hf = figure('name',sprintf('DATTES Resistance: %s',title_str));
end

for ind = 1:length(dt)
    Is = resistance.delta_time == dt(ind);
    
    tagC = sprintf('%g seconds charge',dt(ind));
    tagD = sprintf('%g seconds discharge',dt(ind));
    
    subplot(221),hold on
    plot(resistance.dod(Idis & Is),resistance.R(Idis & Is),'v','color',c(ind,:),'DisplayName',tagD)
    plot(resistance.dod(Icha & Is),resistance.R(Icha & Is),'^','color',c(ind,:),'DisplayName',tagC)
    title('Resistance vs. DoD')
    xlabel('DoD (Ah)','interpreter','tex')
    ylabel('R (Ohm)','interpreter','tex')
%     title(title_str,'interpreter','none')

    subplot(222),hold on
    plot(resistance.crate(Idis & Is),resistance.R(Idis & Is),'v','color',c(ind,:),'DisplayName',tagD)
    plot(resistance.crate(Icha & Is),resistance.R(Icha & Is),'^','color',c(ind,:),'DisplayName',tagC)
    title('Resistance vs. C-rate')
    xlabel('C-rate (C)','interpreter','tex')
    ylabel('R (Ohm)','interpreter','tex')
    
    subplot(2,2,[3 4]),hold on
    plot(resistance.datetime(Idis & Is),resistance.R(Idis & Is),'v','color',c(ind,:),'DisplayName',tagD)
    plot(resistance.datetime(Icha & Is),resistance.R(Icha & Is),'^','color',c(ind,:),'DisplayName',tagC)
    title('Resistance vs. time')
    xlabel('time (s)','interpreter','tex')
    ylabel('R (Ohm)','interpreter','tex')
    
    
end
subplot(2,2,[3 4]),legend('location','best')
%Look for all axis handles and ignore legends
ha = findobj(hf,'type','axes','tag','');
prettyAxes(ha);
changeLine(ha,2,15);
end
