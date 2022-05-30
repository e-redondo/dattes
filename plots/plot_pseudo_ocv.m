function plot_pseudo_ocv(pDoD, pOCV, UC, UD)


hf = figure('name','ident pOCV');hold on
for ind = 1:length(pOCV)
plot(pDoD,UC{ind},'b-','tag','charge (points)')
plot(pDoD,UD{ind},'r-','tag','decharge (points)')
plot(pDoD,pOCV{ind},'k-','tag','pseudoOCV')
end
ylabel('voltage [V]'),xlabel('DoD [Ah]')

%cherche tout les handles du type axe et ignore les legendes
ha = findobj(hf,'type','axes','tag','');
prettyAxes(ha);
changeLine(ha,2,15);
end