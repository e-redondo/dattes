function plot_pseudo_ocv(pseudo_ocv)


hf = figure('name','ident pOCV');hold on
for ind = 1:length(pseudo_ocv)
plot(pseudo_ocv(ind).dod,pseudo_ocv(ind).u_charge,'b-','tag','charge (points)')
plot(pseudo_ocv(ind).dod,pseudo_ocv(ind).u_discharge,'r-','tag','discharge (points)')
plot(pseudo_ocv(ind).dod,pseudo_ocv(ind).ocv,'k-','tag','pseudoOCV')
end
ylabel('voltage [V]'),xlabel('DoD [Ah]')

%cherche tout les handles du type axe et ignore les legendes
ha = findobj(hf,'type','axes','tag','');
prettyAxes(ha);
changeLine(ha,2,15);
end