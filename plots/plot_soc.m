function hf = plot_soc(profiles, config,title_str,options)
% plot_soc plot state of charge graphs
%
% Use t, I, DoDAh and SOC to plot state of charge graphs
%
% Usage:
% hf = plot_soc(t, I, DoDAh, SOC, config,title_str,options)
% Inputs:
% - profiles [1x1 struct] with fields
%     - t [nx1 double]: time in seconds
%     - I [nx1 double]: current in A
%     - DoDAh [nx1 double]: depth of discharge in AmpHours
%     - SOC [nx1 double]: state of charge in %
% - config [1x1 struct]: config struct from configurator
% - title [string]: phases struct from decompose_phases
% - options [string] containing:
%   - 'v': verbose, tell what you do
%   - 'g' : show figures
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

%get t,U,I,m:
date_time = profiles.datetime;
t = profiles.t;
I = profiles.I;
DoDAh = profiles.dod_ah;
SOC = profiles.soc;


%x-axis: tc instead of tabs,in hours od days if options 'h' or 'd':
if ismember('h',options)
    tc = t/3600;
    t_unit = 'h';
elseif ismember('d',options)
    tc = t/86400;
    t_unit = 'd';
elseif ismember('D',options)
    tc = datetime(datestr(e2mdate(date_time),'yyyy-mm-dd HH:MM'));
    t_unit = 's';
else
    tc = t;
    t_unit = 's';
end

I100 = [];
if isfield(config.soc,'soc100_datetime')
    I100 = ismember(date_time,config.soc.soc100_datetime);
end

if isempty(title_str)
hf = figure('name','DATTES SoC/DoD');
else
hf = figure('name',sprintf('DATTES SoC/DoD: %s',title_str));
end

subplot(311),hold on,ylabel('current [A]'),xlabel(sprintf('time [%s]',t_unit))
subplot(312),hold on,ylabel('DoDAh [Ah]'),xlabel(sprintf('time [%s]',t_unit))
subplot(313),hold on,ylabel('SOC [%]'),xlabel(sprintf('time [%s]',t_unit))


subplot(311),plot(tc,I,'k')
subplot(311),plot(tc(I100),I(I100),'ro')
if ~isempty(DoDAh)
    subplot(312),plot(tc,DoDAh,'k')
    subplot(312),plot(tc(I100),DoDAh(I100),'ro'),ylim([min(0,min(DoDAh)) max(config.test.capacity,max(DoDAh))])
    subplot(313),plot(tc,SOC,'k')
    subplot(313),plot(tc(I100),SOC(I100),'ro'),ylim([min(0,min(SOC)) max(100,max(SOC))])
else%'plot nans = plot nothing, but avoid error in linkaxes
    subplot(312),plot(tc,nan(size(tc)),'k')
    subplot(313),plot(tc,nan(size(tc)),'k')
end

% subplot(311),title(title_str,'interpreter','none')
ha = findobj( hf, 'type', 'axes', 'tag', '' );
prettyAxes(ha);
if length(ha)>1
  linkaxes(ha, 'x' );
end
changeLine(ha,1,5);

end
