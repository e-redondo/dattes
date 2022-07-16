function hf = plot_capacity(capacity)
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

hf = figure('name','ident capacity');hold on
plot(capacity.cc_crate,capacity.cc_capacity,'o')
xlabel('Current Rate (C)','interpreter','tex')
ylabel('Capacity (Ah)','interpreter','tex')


%Look for all axis handles and ignore legends
ha = findobj(hf,'type','axes','tag','');
prettyAxes(ha);
changeLine(ha,2,15);



figure;
subplot(211)
title("CC-CV capacity in charge")
plot(capacity.cc_cv_time(capacity.cc_cv_capacity>0),capacity.cc_cv_capacity(capacity.cc_cv_capacity>0),'o','MarkerSize',10)
ylim([min(capacity.cc_cv_capacity(capacity.cc_cv_capacity>0))*0.99 max(capacity.cc_cv_capacity(capacity.cc_cv_capacity>0))*1.01])
xlabel('Time(s)','interpreter','tex')
ylabel('Capacity (Ah)','interpreter','tex')
legend('CC-CV capacity in charge (Ah)')
    grid on;

subplot(212)
title("CC-CV capacity in discharge")
plot(capacity.cc_cv_time(capacity.cc_cv_capacity<0),capacity.cc_cv_capacity(capacity.cc_cv_capacity<0),'o','MarkerSize',10)
ylim([max(capacity.cc_cv_capacity(capacity.cc_cv_capacity<0))*1.01 min(capacity.cc_cv_capacity(capacity.cc_cv_capacity<0))*0.99])
xlabel('Time(s)','interpreter','tex')
ylabel('Capacity (Ah)','interpreter','tex')
legend('CC-CV capacity in discharge (Ah)')

    grid on;

figure;
    bar(capacity.ratio_ah,'stacked')
    title('Ratio Ah in CC and CV')
    legend('CC Ah','CV Ah')
    ylabel('Capacity (Ah)')
        grid on;

    
hf=figure;
    
    bar(capacity.ratio_duration,'stacked')
        title('Ratio duration in CC and CV')
    legend('CC duration','CV duration')
    ylabel('Duration (s)')
    grid on;



%Look for all axis handles and ignore legends
ha = findobj(hf,'type','axes','tag','');
prettyAxes(ha);
changeLine(ha,2,15);

end
