function h = plot_bench(t,U,I,m,titre,options)

if ~exist('options','var')
    options = '';
end

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


h = figure;
subplot(211),plot(t1,U,'b','displayname','test'),hold on,xlabel(x_lab),ylabel('voltage')

title(titre,'interpreter','none')
subplot(212),plot(t1,I,'b','displayname','test'),hold on,xlabel(x_lab),ylabel('current')

c = 'rgcmk';
tags = {'CC','CV','rest','EIS','profile'};
for ind = 1:5
    indices = m==ind;
    
    subplot(211),plot(t1(indices),U(indices),[c(ind) '.'],'displayname',tags{ind})
    subplot(212),plot(t1(indices),I(indices),[c(ind) '.'],'displayname',tags{ind})
end

%cherche tout les handles du type axe et ignore les legendes
ha = findobj(h, 'type', 'axes', 'tag', '' );
arrayfun(@(x) legend(x,'show','location','eastoutside'),ha);
% printLegTag(ha,'eastoutside');
linkaxes(ha, 'x' );
prettyAxes(ha);
end