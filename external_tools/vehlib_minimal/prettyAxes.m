function prettyAxes(ha,tickColor)
%si tickcolor pas fourni, il met [0.2 0.2 0.2] (gris fonce).
% pour charte IFSTTAR: tickColor = [0 0.32549 0.592157] fait bleu fonce
% exemple: ha =findobj('type','axes','tag','')
% prettyAxes(ha,[0.5 0.0 0.0])
%ca change tous les axes ouverts
if ~exist('tickColor','var')
    tickColor = [0.2 0.2 0.2];
end
set(ha, ...
'Box'         , 'off'     , ...
'TickDir'     , 'out'     , ...
'TickLength'  , [.02 .02] , ...
'XMinorTick'  , 'on'      , ...
'YMinorTick'  , 'on'      , ...
'YGrid'       , 'on'      , ...
'XColor'      , tickColor, ...
'YColor'      , tickColor, ...
'LineWidth'   , 0.5         );
set(ha,'ygrid','on','xgrid','on',...
    'yminorgrid','on','xminorgrid','on',...
    'GridLineStyle','-','MinorGridLineStyle',':');
end