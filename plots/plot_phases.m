function hf = plot_phases(t,U,I,phases,titre,options)
%plot_phases visualiser les phases d'un essai.
%
%hf = plot_phases(t,U,I,phases,titre,options)
%
% Fait une figure avec deux plots: U vs. t et I vs. t. avec les phases
% identifiees selon le mode de fonctionnement avec decoupeBanc.
%
% TODO: option plot complet pas de duree min
%
% See also dattes, decompose_bench, mode_bench2

if ~exist('options','var')
    options = '';
end

hf = figure('name','plot_phases');

if ismember('h',options)
    time = t/3600;
elseif ismember('j',options)
    time = t/86400;
else
    time = t;
end
subplot(211),plot(time-time(1),U,'k')
hold on,xlabel('time'),ylabel('voltage')
subplot(212),plot(time-time(1),I,'k')
hold on,xlabel('time'),ylabel('current')
        
c = lines(length(phases));

if length(phases)>100
    [duree] = sort([phases.duree],'descend');
    minDuree = duree(100);
else
    minDuree = 0;
end

to = 0;
for ind = 1:length(phases)
    [tp,timep,Up,Ip] = get_phase(phases(ind),t,time-time(1),U,I);
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
    
    if phases(ind).duree>minDuree
        subplot(211),plot(timep,Up,'color',c(ind,:),'tag',num2str(ind))
%         hold on,xlabel('time'),ylabel('voltage')
        subplot(212),plot(timep,Ip,'color',c(ind,:),'tag',num2str(ind))
%         hold on,xlabel('time'),ylabel('current')
 
        subplot(211),text(tX,tY1,num2str(ind),'edgecolor',c(ind,:),'BackgroundColor','w');
        subplot(212),text(tX,tY2,num2str(ind),'edgecolor',c(ind,:),'BackgroundColor','w');
    end
end
subplot(211),title(titre,'interpreter','none')
%cherche tout les handles du type axe et ignore les legendes
ha = findobj(hf,'type','axes','tag','');

prettyAxes(ha);
linkaxes(ha, 'x' );
changeLine(ha,2,15);
end