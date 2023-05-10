function hf = plot_ocv_by_points(profiles, ocv_by_points,title_str)
% plot_ocv_by_points plot ocv by points graphs
%
% Use t, U, DoDAh and ocv_by_points structure to plot  ocv by points graphs
%
% Usage:
% hf = plot_ocv_by_points(t,U,DoDAh, ocv_by_points)
% Inputs:
% - profiles [1x1 struct] with fields
%     - t [nx1 double]: time in seconds
%     - U [nx1 double]: voltage in V
%     - DoDAh [nx1 double]: depth of discharge in AmpHours
% - ocv_by_points [(1x1) struct] with fields:
%     - ocv [(px1) double]: ocv measurements
%     - dod [(px1) double]: depth of discharge
%     - sign [(px1) double]: current sign before rest
%     - time [(px1) double]: time of measurement
% - title_str: [string] title string
% Output:
% - hf [1x1 figure handler]: handler for created figure
%
%
%
%See also dattes, dattes_plot, configurator, extract_profiles
%
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.


if ~exist('options','var')
    options = '';
end
if ~exist('title_str','var')
    title_str = '';
end

%get t,U,I,m:
t = profiles.datetime;
U = profiles.U;
DoDAh =  profiles.dod_ah;


hf = figure('name','ident_ocv_by_points');

subplot(121),plot(t,U),hold on,ylabel('voltage [V]'),xlabel('time [s]'),
title(title_str,'interpreter','none')

subplot(122),plot(DoDAh,U),hold on,ylabel('voltage [V]'),xlabel('DoDAh [Ah]')

index_charge = ocv_by_points.sign>0;
index_discharge = ocv_by_points.sign<0;

subplot(121),plot(ocv_by_points.datetime(index_charge),ocv_by_points.ocv(index_charge),'r^')
subplot(122),plot(ocv_by_points.dod(index_charge),ocv_by_points.ocv(index_charge),'r^')
subplot(121),plot(ocv_by_points.datetime(index_discharge),ocv_by_points.ocv(index_discharge),'rv')
subplot(122),plot(ocv_by_points.dod(index_discharge),ocv_by_points.ocv(index_discharge),'rv')


%Look for all axis handles and ignore legends
ha = findobj(hf,'type','axes','tag','');
prettyAxes(ha);
changeLine(ha,2,15);

end
