function hf = plot_ocv_by_points(profiles, ocv_by_points,title_str,options)
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
% - options [string] containing:
%     - 'h': time in hours
%     - 'd': time in days
%     - 'D': datetime (seconds from 1/1/2000)
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

if ismember('h',options)
    t_name = 't';
    t_factor = 1/3600;
    t_label = 'time [h]';
elseif ismember('d',options)
    t_name = 't';
    t_factor = 1/86400;
    t_label = 'time [d]';
elseif ismember('D',options)%datetime
    t_name = 'datetime';
    t_factor = 1;
    t_label = 'datetime [s]';
else
    t_name = 't';
    t_factor = 1;
    t_label = 'time [s]';
end

%get t,U,I,m:
t = profiles.(t_name);
U = profiles.U;
DoDAh =  profiles.dod_ah;


if isempty(title_str)
    hf = figure('name','DATTES OCV by points');
else
    hf = figure('name',sprintf('DATTES OCV by points: %s',title_str));
end


subplot(121),plot(t*t_factor,U),hold on,ylabel('Voltage [V]'),xlabel(t_label),
title('Voltage vs. time')

subplot(122),plot(DoDAh,U),hold on,ylabel('Voltage [V]'),xlabel('DoD [Ah]')
title('Voltage vs. DoD')

index_charge = ocv_by_points.sign>0;
index_discharge = ocv_by_points.sign<0;

t_ocv = ocv_by_points.(t_name);
t_ocv_c = t_ocv(index_charge);
t_ocv_d = t_ocv(index_discharge);
subplot(121),plot(t_ocv_c*t_factor,ocv_by_points.ocv(index_charge),'r^')
subplot(122),plot(ocv_by_points.dod(index_charge),ocv_by_points.ocv(index_charge),'r^')
subplot(121),plot(t_ocv_d*t_factor,ocv_by_points.ocv(index_discharge),'rv')
subplot(122),plot(ocv_by_points.dod(index_discharge),ocv_by_points.ocv(index_discharge),'rv')


hl = legend('voltage profile','OCV after partial charge','OCV after partial discharge');
hl.Location = 'southwest';
%Look for all axis handles and ignore legends
ha = findobj(hf,'type','axes','tag','');
prettyAxes(ha);
changeLine(ha,1,5);

end
