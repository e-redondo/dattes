function plot_capacity(Capa, CapaRegime)

%TODO: plot charge and discharge in absolute values (different colors)
%TODO: plot Qcc, Qcv, Qtot for charge and discharge

hf = figure('name','ident capacity');hold on
plot(CapaRegime,Capa,'o')
xlabel('Current Rate (C)','interpreter','tex')
ylabel('Capacity (Ah)','interpreter','tex')


%cherche tout les handles du type axe et ignore les legendes
ha = findobj(hf,'type','axes','tag','');
prettyAxes(ha);
changeLine(ha,2,15);
end