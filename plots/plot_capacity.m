function hf = plot_capacity(capacity,title_str)
% plot_capacity plot capacity graphs
%
% plot_capacity(cc_capacity, cc_crate)
% Use cc_capacity and cc_crate to plot CC capacity graphs
%
% Usage:
% hf = plot_capacity(cc_capacity, cc_crate)
% Inputs:
% - capacity [(1x1) struct] with fields:
%  - cc_capacity: [nx1] Capacity during CC phase in Ah
%  - cc_crate: [nx1] C-rate during CC phase in Ah
% - title_str: [string] title string
% Output:
% - hf [1x1 figure handler]: handler for created figure
%
% See also dattes, dattes_plot, configurator, extract_profiles
%
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab:
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.


if isempty(title_str)
hf = figure('name','DATTES Capacity');
else
hf = figure('name',sprintf('DATTES Capacity: %s',title_str));
end

subplot(221), title('Capacity versus C-rate')
plot(-capacity.cccv_crate(capacity.cccv_crate<0),capacity.cccv_capacity(capacity.cccv_crate<0),...
    'v m','MarkerSize',8, 'DisplayName','CC-CV discharge')
hold on
plot(-capacity.cc_crate(capacity.cc_crate<0),capacity.cc_capacity(capacity.cc_crate<0),...
    'v r','MarkerSize',8, 'DisplayName','CC discharge')
plot(capacity.cccv_crate(capacity.cccv_crate>0),capacity.cccv_capacity(capacity.cccv_crate>0),...
    '^ g','MarkerSize',8, 'DisplayName','CC-CV charge')
plot(capacity.cc_crate(capacity.cc_crate>0),capacity.cc_capacity(capacity.cc_crate>0),...
    '^ b','MarkerSize',8, 'DisplayName','CC charge')


xlabel('C-rate [p.u.]','interpreter','tex')
ylabel('Capacity [Ah]','interpreter','tex')
legend('location','best')
grid on;

ah_ratio_cc=capacity.cccv_ratio_cc_ah;
ah_ratio_cv=1-capacity.cccv_ratio_cc_ah;
duration_ratio_cc=capacity.cccv_ratio_cc_duration;
duration_ratio_cv=1-capacity.cccv_ratio_cc_duration;


subplot(222), title('Amp-hour ratio')
plot(capacity.cccv_datetime(capacity.cccv_crate<0),ah_ratio_cc(capacity.cccv_crate<0),...
    'v r','MarkerSize',8, 'DisplayName','CC discharge')
hold on
plot(capacity.cccv_datetime(capacity.cccv_crate<0),ah_ratio_cv(capacity.cccv_crate<0),...
    'v m','MarkerSize',8, 'DisplayName','CV discharge')
plot(capacity.cccv_datetime(capacity.cccv_crate>0),ah_ratio_cc(capacity.cccv_crate>0),...
    '^ b','MarkerSize',8, 'DisplayName','CC charge')
plot(capacity.cccv_datetime(capacity.cccv_crate>0),ah_ratio_cv(capacity.cccv_crate>0),...
    '^ g','MarkerSize',8, 'DisplayName','CV charge')


ylim([0 1])
xlabel('datetime [s]','interpreter','tex')
ylabel('Ah ratio [p.u.]','interpreter','tex')
legend('location','best')

grid on;


subplot(223), title('Capacity versus time')
plot(capacity.cccv_datetime(capacity.cccv_crate<0),capacity.cccv_capacity(capacity.cccv_crate<0),...
    'v m','MarkerSize',8, 'DisplayName','CC-CV discharge')
hold on
plot(capacity.cc_datetime(capacity.cc_crate<0),capacity.cc_capacity(capacity.cc_crate<0),...
    'v r','MarkerSize',8, 'DisplayName','CC discharge')
plot(capacity.cccv_datetime(capacity.cccv_crate>0),capacity.cccv_capacity(capacity.cccv_crate>0),...
    '^ g','MarkerSize',8, 'DisplayName','CC-CV charge')
plot(capacity.cc_datetime(capacity.cc_crate>0),capacity.cc_capacity(capacity.cc_crate>0),...
    '^ b','MarkerSize',8, 'DisplayName','CC charge')


xlabel('datetime [s]','interpreter','tex')
ylabel('Capacity [Ah]','interpreter','tex')
legend('location','best')

grid on;



subplot(224), title('Duration ratio')
plot(capacity.cccv_datetime(capacity.cccv_crate<0),duration_ratio_cc(capacity.cccv_crate<0),...
    'v r','MarkerSize',8, 'DisplayName','CC discharge')
hold on
plot(capacity.cccv_datetime(capacity.cccv_crate<0),duration_ratio_cv(capacity.cccv_crate<0),...
    'v m','MarkerSize',8, 'DisplayName','CV discharge')
plot(capacity.cccv_datetime(capacity.cccv_crate>0),duration_ratio_cc(capacity.cccv_crate>0),...
    '^ b','MarkerSize',8, 'DisplayName','CC charge')
plot(capacity.cccv_datetime(capacity.cccv_crate>0),duration_ratio_cv(capacity.cccv_crate>0),...
    '^ g','MarkerSize',8, 'DisplayName','CV charge')


ylim([0 1])
xlabel('datetime [s]','interpreter','tex')
ylabel('Duration ratio [p.u. of CCCV duration]','interpreter','tex')
legend('location','best')

grid on;


%Look for all axis handles and ignore legends
ha = findobj(hf,'type','axes','tag','');
prettyAxes(ha);
changeLine(ha,1,5);





end

