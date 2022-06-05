function plot_ocv_by_points(t,U,DoDAh, ocv_by_points)
% plot_ocv_by_points plot ocv by points graphs
%
% plot_ocv_by_points(t,U,DoDAh, ocv_by_points)
% Use t, U, DoDAh and ocv_by_points structure to plot  ocv by points graphs
%
% Usage:
% plot_ocv_by_points(t,U,DoDAh, ocv_by_points)
% Inputs:
% - t [nx1 double]: time in seconds
% - U [nx1 double]: voltage in V
% - DoDAh [nx1 double]: depth of discharge in AmpHours
% - ocv_by_points [(1x1) struct] with fields:
%     - ocv [(px1) double]: ocv measurements
%     - dod [(px1) double]: depth of discharge
%     - sign [(px1) double]: current sign before rest
%     - time [(px1) double]: time of measurement
%
%
%
%See also dattes, dattes_plot, configurator, extract_profiles
%
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.



hf = figure('name','ident_ocv_by_points');

subplot(211),plot(t,U),hold on,ylabel('voltage [V]'),xlabel('time [s]')
subplot(212),plot(DoDAh,U),hold on,ylabel('voltage [V]'),xlabel('DoDAh [Ah]')

index_charge = ocv_by_points.sign>0;
index_discharge = ocv_by_points.sign<0;

subplot(211),plot(ocv_by_points.time(index_charge),ocv_by_points.ocv(index_charge),'r^')
subplot(212),plot(ocv_by_points.dod(index_charge),ocv_by_points.ocv(index_charge),'r^')
subplot(211),plot(ocv_by_points.time(index_discharge),ocv_by_points.ocv(index_discharge),'rv')
subplot(212),plot(ocv_by_points.dod(index_discharge),ocv_by_points.ocv(index_discharge),'rv')

%Look for all axis handles and ignore legends
ha = findobj(hf,'type','axes','tag','');
prettyAxes(ha);
changeLine(ha,2,15);

end