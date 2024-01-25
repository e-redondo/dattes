function hf = plot_eis(eis,title_str,options)
% plot_eis plot eis graphs
%
% plot_eis(eis,titre,options)
% Use result.eis structure from DATTES to plot eis graphs.
%
% Usage:
% plot_eis(eis,titre,options)
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
    tag = sprintf('EIS nr:%d',ind);
    if isfield(eis(ind),'soc')
        soc = mean(eis(ind).soc);
        if ~isnan(soc)
            tag = sprintf('%s,SoC = %.1f%%',tag,soc);
        end
    end
    if isfield(eis(ind),'Iavg')
        Iavg = mean(eis(ind).Iavg);
        if ~isnan(Iavg)
            tag = sprintf('%s, avg I = %.3gA',tag,Iavg);
        end
    end
    if isfield(eis(ind),'Iamp')
        Iamp = mean(eis(ind).Iamp);
        if ~isnan(Iamp)
            tag = sprintf('%s, I amplitude = %.3gA',tag,Iamp);
        end
    end
    if isfield(eis(ind),'Uamp')
        Uamp = mean(eis(ind).Uamp);
        if ~isnan(Uamp)
            tag = sprintf('%s, U amplitude = %.3gV',tag,Uamp);
        end
    end
    
    plot(eis(ind).ReZ,eis(ind).ImZ,'.-','displayname',tag),hold on
end
set(gca,'DataAspectRatio',[1 1 1],'PlotBoxAspectRatio',[1 1 1])
title(title_str,'interpreter','none')

end
