function plot_cpe(CPEQ, CPEalpha, CPEDoD, CPERegime)


hf = figure('name','ident CPE');hold on
subplot(221),plot(CPEDoD,CPEQ,'o')
xlabel('DoD (Ah)','interpreter','tex')
ylabel('Q (1/Ohm)','interpreter','tex')

subplot(222),plot(CPERegime,CPEQ,'o')
xlabel('C-rate (C)','interpreter','tex')
ylabel('Q (1/Ohm)','interpreter','tex')


subplot(223),plot(CPEDoD,CPEalpha,'o')
xlabel('DoD (Ah)','interpreter','tex')
ylabel('\alpha','interpreter','tex')

subplot(224),plot(CPERegime,CPEalpha,'o')
xlabel('C-rate (C)','interpreter','tex')
ylabel('\alpha','interpreter','tex')

%cherche tout les handles du type axe et ignore les legendes
ha = findobj(hf,'type','axes','tag','');
prettyAxes(ha);
changeLine(ha,2,15);
end