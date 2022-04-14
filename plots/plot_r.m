function plotR(R, RDoD, RRegime)

Idis = RRegime<0;
Icha = RRegime>0;


hf = figure('name','ident R');
subplot(121),hold on
plot(RDoD(Idis),R(Idis),'v')
plot(RDoD(Icha),R(Icha),'^')
xlabel('DoD (Ah)','interpreter','tex')
ylabel('R (mOhms)','interpreter','tex')

subplot(122),hold on
plot(RRegime(Idis),R(Idis),'v')
plot(RRegime(Icha),R(Icha),'^')
xlabel('Regime (C)','interpreter','tex')
ylabel('R (mOhms)','interpreter','tex')



%cherche tout les handles du type axe et ignore les legendes
ha = findobj(hf,'type','axes','tag','');
prettyAxes(ha);
changeLine(ha,2,15);
end