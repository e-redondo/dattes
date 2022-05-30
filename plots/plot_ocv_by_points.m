function plot_ocv_by_points(t,U,DoDAh, tOCVp, OCVp, DoDp, Ipsign)

hf = figure('name','ident_ocv_by_points');

subplot(211),plot(t,U),hold on,ylabel('voltage [V]'),xlabel('temps [s]')
subplot(212),plot(DoDAh,U),hold on,ylabel('voltage [V]'),xlabel('DoDAh [Ah]')

subplot(211),plot(tOCVp(Ipsign>0),OCVp(Ipsign>0),'r^')
subplot(212),plot(DoDp(Ipsign>0),OCVp(Ipsign>0),'r^')
subplot(211),plot(tOCVp(Ipsign<0),OCVp(Ipsign<0),'rv')
subplot(212),plot(DoDp(Ipsign<0),OCVp(Ipsign<0),'rv')

%cherche tout les handles du type axe et ignore les legendes
ha = findobj(hf,'type','axes','tag','');
prettyAxes(ha);
changeLine(ha,2,15);

end