function hf = plot_soc(t, I, DoDAh, SOC, config,title_str,options)
% plot_soc plot state of charge graphs
%
% hf = plot_soc(t, I, DoDAh, SOC, config,title_str,options)
% Use t, I, DoDAh and SOC to plot state of charge graphs
%
% Usage:
% hf = plot_soc(t, I, DoDAh, SOC, config,title_str,options)
% Inputs:
% - t [nx1 double]: time in seconds
% - I [nx1 double]: current in A
% - DoDAh [nx1 double]: depth of discharge in AmpHours
% - SOC [nx1 double]: state of charge in %
% - config [1x1 struct]: config struct from configurator
% - title [string]: phases struct from decompose_phases
% - options [string] containing:
%   - 'v': verbose, tell what you do
%   - 'g' : show figures
%
% Outputs : 
% - hf: [1x1 struct] figure handle
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

%x-axis: tc instead of tabs,in hours od days if options 'h' or 'd':
tc = t-t(1);
if ismember('h',options)
    tc = tc/3600;
    tunit = 'h';
elseif ismember('d',options)
    tc = tc/86400;
    tunit = 'd';
else
    tunit = 's';
end
I100 = ismember(t,config.soc.soc100_time);
hf = figure('name','plot_soc');

subplot(311),plot(tc,I),hold on,ylabel('current [A]'),xlabel(sprintf('time [%s]',tunit)),grid on
subplot(311),plot(tc(I100),I(I100),'ro')
if ~isempty(DoDAh)
    subplot(312),plot(tc,DoDAh),hold on,ylabel('DoDAh [Ah]'),xlabel(sprintf('time [%s]',tunit)), grid on
    subplot(312),plot(tc(I100),DoDAh(I100),'ro'),ylim([min(0,min(DoDAh)) max(config.test.capacity,max(DoDAh))])
    subplot(313),plot(tc(I100),SOC(I100),'ro'),ylim([min(0,min(SOC)) max(100,max(SOC))])
    subplot(313),plot(tc,SOC),hold on,ylabel('SOC [%]'),xlabel(sprintf('time [%s]',tunit)), grid on
end

subplot(311),title(title_str,'interpreter','none')
ha = findobj( hf, 'type', 'axes', 'tag', '' );
prettyAxes(ha);
linkaxes(ha, 'x' );
changeLine(ha,2,15);

end