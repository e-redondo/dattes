function plot_eff(pDoD, pEff)
%plot an efficiency plot (pseudoOCV tests)

hf = figure('name','ident pOCV(Effi)');hold on
for ind = 1:length(pEff)
plot(pDoD,pEff{ind},'k-','tag','efficiency')
end
ylabel('efficiency [p.u.]'),xlabel('DoD [Ah]')

%cherche tout les handles du type axe et ignore les legendes
ha = findobj(hf,'type','axes','tag','');
prettyAxes(ha);
changeLine(ha,2,15);
end