function hf = plot_phases(profiles,phases,title_str,options)
%plot_phases visualize phases of a test
%
% Make a figure with two subplots: U vs. t et I vs. t. with identified
% phases by split_phases function (CC, CV, rest, etc.). If more than 100
% phases, only longer 100 phases will be ploted (color and number).
%
% Usage:
% hf = plot_phases(t,U,I,phases,title_str,options)
% Inputs:
% - profiles [1x1 struct] with fields
%     - t [nx1 double]: time in seconds
%     - U [nx1 double]: voltage in V
%     - I [nx1 double]: current in A
% - phases [(1x1) struct] with fields:
%     - duration [1x1 double]: phase duration in seconds
% - title: [string] title string
% Output:
% - hf [1x1 figure handler]: handler for created figure
%
%
% See also dattes, split_phases, which_mode
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
U = profiles.U;
I = profiles.I;


if isempty(title_str)
    hf = figure('name','DATTES phases');
else
    hf = figure('name',sprintf('DATTES phases: %s',title_str));
end

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
subplot(211),plot(t1,U,'k')
hold on,xlabel(x_lab),ylabel('Voltage [V]')
subplot(212),plot(t1,I,'k')
hold on,xlabel(x_lab),ylabel('Current [A]')
        
c = lines(length(phases));

if length(phases)>100
    [p_duration] = sort([phases.duration],'descend');
    minDuree = p_duration(100);
else
    minDuree = 0;
end

to = 0;
for ind = 1:length(phases)
    [tp,timep,Up,Ip] = extract_phase(phases(ind),date_time,t1,U,I);

    tX = mean(timep);
    tY1 = mean(Up);
    tY2 = mean(Ip);
    
    if phases(ind).duration>minDuree || ind==1 || ind==length(phases)
        subplot(211),plot(timep,Up,'color',c(ind,:),'tag',num2str(ind))
        subplot(212),plot(timep,Ip,'color',c(ind,:),'tag',num2str(ind))
 
        subplot(211),text(tX,tY1,num2str(ind),'edgecolor',c(ind,:),'BackgroundColor','w');
        subplot(212),text(tX,tY2,num2str(ind),'edgecolor',c(ind,:),'BackgroundColor','w');
    end
end


%Look for all axis handles and ignore legends
ha = findobj(hf,'type','axes','tag','');

prettyAxes(ha);
linkaxes(ha, 'x' );
changeLine(ha,1,5);
end
