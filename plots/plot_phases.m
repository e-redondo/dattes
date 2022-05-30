function hf = plot_phases(t,U,I,phases,title_str,options)
%plot_phases visualize phases of a test
%
% hf = plot_phases(t,U,I,phases,title_str,options)
%
% Make a figure with two subplots: U vs. t et I vs. t. with identified
% phases by decompose_bench function (CC, CV, rest, etc.). If more than 100
% phases, only longer 100 phases will be ploted (color and number).
%
% TODO: option plot complet pas de duration min
%
% See also dattes, decompose_bench, mode_bench2

if ~exist('options','var')
    options = '';
end

hf = figure('name','plot_phases');

if ismember('D',options)%plot time in dates
    t1 = datetime(datestr(e2mdate(t),'yyyy-mm-dd HH:MM'));
    x_lab = 'date/time';
else
    if ismember('h',options)%plot time in hours since start_time
        t1 = (t-t(1))/3600;
        x_lab = 'time (hours)';
    elseif ismember('d',options)%plot time in days since start_time
        t1 = (t-t(1))/86400;
        x_lab = 'time (days)';
    else
        t1 = t-t(1);%enlever le debut
        x_lab = 'time (seconds)';
    end
end
subplot(211),plot(t1,U,'k')
hold on,xlabel(x_lab),ylabel('voltage')
subplot(212),plot(t1,I,'k')
hold on,xlabel(x_lab),ylabel('current')
        
c = lines(length(phases));

if length(phases)>100
    [p_duration] = sort([phases.duration],'descend');
    minDuree = p_duration(100);
else
    minDuree = 0;
end

to = 0;
for ind = 1:length(phases)
    [tp,timep,Up,Ip] = extract_phase(phases(ind),t,t1,U,I);
%     tp = tcell{ind};
%     Up = Ucell{ind};
%     Ip = Icell{ind};
    
%     tp = tp-tp(1)+to;%ajout du cumul de temps
%     to = tp(end);%mise a jour du cumul de temps pour l'iteration suivante
%     if ismember('h',options)
%         tp = tp/3600;
%     elseif ismember('j',options)
%         tp = tp/86400;
%     end
    tX = mean(timep);
    tY1 = mean(Up);
    tY2 = mean(Ip);
    
    if phases(ind).duration>minDuree
        subplot(211),plot(timep,Up,'color',c(ind,:),'tag',num2str(ind))
%         hold on,xlabel('time'),ylabel('voltage')
        subplot(212),plot(timep,Ip,'color',c(ind,:),'tag',num2str(ind))
%         hold on,xlabel('time'),ylabel('current')
 
        subplot(211),text(tX,tY1,num2str(ind),'edgecolor',c(ind,:),'BackgroundColor','w');
        subplot(212),text(tX,tY2,num2str(ind),'edgecolor',c(ind,:),'BackgroundColor','w');
    end
end
subplot(211),title(title_str,'interpreter','none')
%cherche tout les handles du type axe et ignore les legendes
ha = findobj(hf,'type','axes','tag','');

prettyAxes(ha);
linkaxes(ha, 'x' );
changeLine(ha,2,15);
end