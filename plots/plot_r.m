function hf = plot_r(resistance)
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
% Output:
% - hf [1x1 figure handler]: handler for created figure
%
%See also dattes, dattes_plot, configurator, extract_profiles
%
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.


Idis = resistance.crate<0;
Icha = resistance.crate>0;
dt = unique(resistance.delta_time);

c = lines(length(dt));

hf = figure('name','ident R');

for ind = 1:length(dt)
    Is = resistance.delta_time == dt(ind);
    
    tagC = sprintf('%g seconds charge',dt(ind));
    tagD = sprintf('%g seconds discharge',dt(ind));
    
    subplot(221),hold on
    plot(resistance.dod(Idis & Is),resistance.R(Idis & Is),'v','color',c(ind,:),'DisplayName',tagD)
    plot(resistance.dod(Icha & Is),resistance.R(Icha & Is),'^','color',c(ind,:),'DisplayName',tagC)
    xlabel('DoD (Ah)','interpreter','tex')
    ylabel('R (Ohm)','interpreter','tex')
    
    subplot(222),hold on
    plot(resistance.crate(Idis & Is),resistance.R(Idis & Is),'v','color',c(ind,:),'DisplayName',tagD)
    plot(resistance.crate(Icha & Is),resistance.R(Icha & Is),'^','color',c(ind,:),'DisplayName',tagC)
    xlabel('C-Rate (C)','interpreter','tex')
    ylabel('R (Ohm)','interpreter','tex')
    
    subplot(2,2,[3 4]),hold on
    plot(resistance.time(Idis & Is),resistance.R(Idis & Is),'v','color',c(ind,:),'DisplayName',tagD)
    plot(resistance.time(Icha & Is),resistance.R(Icha & Is),'^','color',c(ind,:),'DisplayName',tagC)
    xlabel('time (s)','interpreter','tex')
    ylabel('R (Ohm)','interpreter','tex')
    
    
end
subplot(2,2,[3 4]),legend('location','eastoutside')
%Look for all axis handles and ignore legends
ha = findobj(hf,'type','axes','tag','');
prettyAxes(ha);
changeLine(ha,2,15);
end
