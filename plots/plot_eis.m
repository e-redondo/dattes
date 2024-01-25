function hf = plot_eis(eis,title_str,options)
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
for ind = 1:length(eis.ReZ)
    tag = sprintf('EIS nr:%d',ind);
    if isfield(eis,'soc')
        soc = mean(eis.soc{ind});
        if ~isnan(soc)
            tag = sprintf('%s,SoC = %.1f%%',tag,soc);
        end
    end
    if isfield(eis,'Iavg')
        Iavg = mean(eis.Iavg{ind});
        if ~isnan(Iavg)
            tag = sprintf('%s, avg I = %.3gA',tag,Iavg);
        end
    end
    if isfield(eis,'Iamp')
        Iamp = mean(eis.Iamp{ind});
        if ~isnan(Iamp)
            tag = sprintf('%s, I amplitude = %.3gA',tag,mean(eis.Iamp{ind}));
        end
    end
    if isfield(eis,'Uamp')
        Uamp = mean(eis.Uamp{ind});
        if ~isnan(Uamp)
            tag = sprintf('%s, U amplitude = %.3gV',tag,mean(eis.Uamp{ind}));
        end
    end
    
    plot(eis.ReZ{ind},eis.ImZ{ind},'.-','displayname',tag),hold on
end
set(gca,'DataAspectRatio',[1 1 1],'PlotBoxAspectRatio',[1 1 1])
title(title_str,'interpreter','none')

end
