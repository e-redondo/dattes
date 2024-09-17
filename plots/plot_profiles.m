function hf = plot_profiles(profiles,title_str,options)
%plot_profiles visualize profiles of a test
%
% plot_profiles(t,U,I,m,title,options)
% Make a figure with two subplots: U vs. t et I vs. t.
%
% Usage:
% hf = plot_profiles(t,U,I,m,title,options)
% Inputs:
% - profiles [1x1 struct] with fields
%     - t [nx1 double]: time in seconds
%     - U [nx1 double]: voltage in V
%     - I [nx1 double]: current in A
%     - mode [nx1 double]] cycler mode
% - title_str: [string] title string
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
if ~exist('title_str','var')
    title_str = '';
end

%TODO check profiles struct

%get t,U,I,m:
date_time = profiles.datetime;
t = profiles.t;
U = profiles.U;
I = profiles.I;
m = profiles.mode;
T = profiles.T;
ah = profiles.ah;

if ismember('D',options)%plot time in dates
    t1 = datetime(datestr(e2mdate(date_time),'yyyy-mm-dd HH:MM'));
    x_lab = 'datetime';
else
    if ismember('h',options)%plot time in hours since start_time
        t1 = (t-t(1))/3600;
        x_lab = 'time [h]';
    elseif ismember('d',options)%plot time in days since start_time
        t1 = (t-t(1))/86400;
        x_lab = 'time [d]';
    else
        t1 = t-t(1);% Remove first instant
        x_lab = 'time [s]';
    end
end


if isempty(title_str)
hf = figure('name','DATTES profiles and mode');
else
hf = figure('name',sprintf('DATTES profiles and mode: %s',title_str));
end

subplot(221),plot(t1,U,'k','displayname','test'),hold on,xlabel(x_lab),ylabel('Voltage [V]')
subplot(223),plot(t1,I,'k','displayname','test'),hold on,xlabel(x_lab),ylabel('Current [A]')

if ~isempty(T)
    subplot(222),plot(t1,T,'k','displayname','test'),hold on,xlabel(x_lab),ylabel('Temperature [C]')
end
if ~isempty(ah)
    subplot(224),plot(t1,ah,'k','displayname','test'),hold on,xlabel(x_lab),ylabel('Amp-Hours [Ah]')
end
c = lines(5);
tags = {'CC','CV','rest','EIS','profile'};
for ind = 1:5
    indices = m==ind;

    subplot(221),plot(t1(indices),U(indices),'.','color',c(ind,:),'displayname',tags{ind})
    subplot(223),plot(t1(indices),I(indices),'.','color',c(ind,:),'displayname',tags{ind})
    if ~isempty(T)
        subplot(222),plot(t1(indices),T(indices),'.','color',c(ind,:),'displayname',tags{ind})
    end
    if ~isempty(ah)
        subplot(224),plot(t1(indices),ah(indices),'.','color',c(ind,:),'displayname',tags{ind})
    end
end

%Look for all axis handles and ignore legends
ha = findobj(hf, 'type', 'axes', 'tag', '' );
arrayfun(@(x) legend(x,'location','best'),ha);
% printLegTag(ha,'eastoutside');
linkaxes(ha, 'x' );
prettyAxes(ha);
changeLine(ha,1,5);
end
