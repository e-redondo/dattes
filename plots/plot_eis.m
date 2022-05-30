function h = plot_eis(eis,titre,options)

if ~exist('options','var')
    options = '';
end

% if ismember('D',options)%plot time in dates
%     t1 = datetime(datestr(e2mdate(t),'yyyy-mm-dd HH:MM'));
% else
%     if ismember('h',options)%plot time in hours since start_time
%         t = t/3600;
%     elseif ismember('j',options)%plot time in days since start_time
%         t = t/86400;
%     end
%         t1 = t-t(1);%enlever le debut
% end

h = figure;
for ind = 1:length(eis.ReZ)
    plot(eis.ReZ{ind},eis.ImZ{ind},'.-'),hold on
end
title(titre,'interpreter','none')

end