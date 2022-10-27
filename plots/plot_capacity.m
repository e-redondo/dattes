function hf = plot_capacity(capacity,title_str)
% plot_capacity plot capacity graphs
%
% plot_capacity(cc_capacity, cc_crate)
% Use cc_capacity and cc_crate to plot CC capacity graphs
%
% Usage:
% hf = plot_capacity(cc_capacity, cc_crate)
% Inputs:
%  - cc_capacity: [nx1] Capacity during CC phase in Ah
%  - cc_crate: [nx1] C-rate during CC phase in Ah
% Output:
% - hf [1x1 figure handler]: handler for created figure
%
% See also dattes, dattes_plot, configurator, extract_profiles
%
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab:
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.


hf=figure;
subplot(221)
plot(capacity.cc_cv_crate(capacity.cc_cv_crate<0),capacity.cc_cv_capacity(capacity.cc_cv_crate<0),...
    'v r','MarkerSize',8, 'DisplayName','CC-CV discharge')
hold on
plot(capacity.cc_crate(capacity.cc_crate<0),capacity.cc_capacity(capacity.cc_crate<0),...
    'v b','MarkerSize',8, 'DisplayName','CC discharge')
plot(capacity.cc_cv_crate(capacity.cc_cv_crate>0),capacity.cc_cv_capacity(capacity.cc_cv_crate>0),...
    '^ r','MarkerSize',8, 'DisplayName','CC-CV charge')
plot(capacity.cc_crate(capacity.cc_crate>0),capacity.cc_capacity(capacity.cc_crate>0),...
    '^ b','MarkerSize',8, 'DisplayName','CC charge')

title(title_str,'interpreter','none')
xlabel('C-rate(p.u.)','interpreter','tex')
ylabel('Capacity (Ah)','interpreter','tex')
legend('location','best')
grid on;

ah_ratio_cc=capacity.cccv_ratio_cc_ah(:,1);
ah_ratio_cv=capacity.cccv_ratio_cc_ah(:,2);
duration_ratio_cc=capacity.cccv_ratio_cc_duration(:,1);
duration_ratio_cv=capacity.cccv_ratio_cc_duration(:,2);


subplot(222)
plot(capacity.cc_cv_time(capacity.cc_cv_crate<0),ah_ratio_cc(capacity.cc_cv_crate<0),...
    'v b','MarkerSize',8, 'DisplayName','CC discharge')
hold on
plot(capacity.cc_cv_time(capacity.cc_cv_crate<0),ah_ratio_cv(capacity.cc_cv_crate<0),...
    'v r','MarkerSize',8, 'DisplayName','CV discharge')
plot(capacity.cc_cv_time(capacity.cc_cv_crate>0),ah_ratio_cc(capacity.cc_cv_crate>0),...
    '^ b','MarkerSize',8, 'DisplayName','CC charge')
plot(capacity.cc_cv_time(capacity.cc_cv_crate>0),ah_ratio_cv(capacity.cc_cv_crate>0),...
    '^ r','MarkerSize',8, 'DisplayName','CV charge')


title(title_str,'interpreter','none')
xlabel('Time (s)','interpreter','tex')
ylabel('Ah ratio (Ah)','interpreter','tex')
legend('location','best')

grid on;


subplot(223)
plot(capacity.cc_cv_time(capacity.cc_cv_crate<0),capacity.cc_cv_capacity(capacity.cc_cv_crate<0),...
    'v r','MarkerSize',8, 'DisplayName','CC-CV discharge')
hold on
plot(capacity.cc_time(capacity.cc_crate<0),capacity.cc_capacity(capacity.cc_crate<0),...
    'v b','MarkerSize',8, 'DisplayName','CC discharge')
plot(capacity.cc_cv_time(capacity.cc_cv_crate>0),capacity.cc_cv_capacity(capacity.cc_cv_crate>0),...
    '^ r','MarkerSize',8, 'DisplayName','CC-CV charge')
plot(capacity.cc_time(capacity.cc_crate>0),capacity.cc_capacity(capacity.cc_crate>0),...
    '^ b','MarkerSize',8, 'DisplayName','CC charge')

title(title_str,'interpreter','none')
xlabel('Time(s)','interpreter','tex')
ylabel('Capacity (Ah)','interpreter','tex')
legend('location','best')

grid on;



subplot(224)
plot(capacity.cc_cv_time(capacity.cc_cv_crate<0),duration_ratio_cc(capacity.cc_cv_crate<0),...
    'v b','MarkerSize',8, 'DisplayName','CC discharge')
hold on
plot(capacity.cc_cv_time(capacity.cc_cv_crate<0),duration_ratio_cv(capacity.cc_cv_crate<0),...
    'v r','MarkerSize',8, 'DisplayName','CV discharge')
plot(capacity.cc_cv_time(capacity.cc_cv_crate>0),duration_ratio_cc(capacity.cc_cv_crate>0),...
    '^ b','MarkerSize',8, 'DisplayName','CC charge')
plot(capacity.cc_cv_time(capacity.cc_cv_crate>0),duration_ratio_cv(capacity.cc_cv_crate>0),...
    '^ r','MarkerSize',8, 'DisplayName','CV charge')


title(title_str,'interpreter','none')
xlabel('Time (s)','interpreter','tex')
ylabel('Duration ratio (s)','interpreter','tex')
legend('location','best')

grid on;


%Look for all axis handles and ignore legends
ha = findobj(hf,'type','axes','tag','');
prettyAxes(ha);
changeLine(ha,2,15);





end

