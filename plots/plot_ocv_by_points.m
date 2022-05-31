function plot_ocv_by_points(t,U,DoDAh, ocv_by_points)

hf = figure('name','ident_ocv_by_points');

subplot(211),plot(t,U),hold on,ylabel('voltage [V]'),xlabel('time [s]')
subplot(212),plot(DoDAh,U),hold on,ylabel('voltage [V]'),xlabel('DoDAh [Ah]')

index_charge = ocv_by_points.sign>0;
index_discharge = ocv_by_points.sign<0;

subplot(211),plot(ocv_by_points.time(index_charge),ocv_by_points.ocv(index_charge),'r^')
subplot(212),plot(ocv_by_points.dod(index_charge),ocv_by_points.ocv(index_charge),'r^')
subplot(211),plot(ocv_by_points.time(index_discharge),ocv_by_points.ocv(index_discharge),'rv')
subplot(212),plot(ocv_by_points.dod(index_discharge),ocv_by_points.ocv(index_discharge),'rv')

%cherche tout les handles du type axe et ignore les legendes
ha = findobj(hf,'type','axes','tag','');
prettyAxes(ha);
changeLine(ha,2,15);

end