function plot_ica(ica)
% plot_ica plot incremental capacity analysis graphs
%
% plot_ica(ica)
% Use ica structure to plot incremental capacity analysis graphs
%
% Usage:
% plot_ica(ica)
% Inputs:
% - ica [mx1 struct] with fields:
%   - dqdu [px1 double]: voltage derivative of capacity
%   - dudq [px1 double]: capacity derivative of voltage
%   - q [px1 double]: capacity vector for dudq
%   - u [px1 double]: voltage vector for dqdu
%   - crate [1x1 double]: charge or discharge C-rate
%   - time [1x1 double]: time of measurement
% - title_str: [string] title string
%
% See also dattes, dattes_plot, configurator, extract_profiles
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.


    figure;
    for ind = 1:length(ica)
        qf = ica(ind).q;
        uf = ica(ind).u;
        dqdu = ica(ind).dqdu;
        dudq = ica(ind).dudq;
        crate = ica(ind).crate;
        test_date = datestr(e2mdate(ica(ind).time),'yyyy-mm-dd');
        
        disp_name = sprintf('C-rate=%.3fC, date=%s',crate, test_date);
        subplot(221),plot(qf,uf,'DisplayName',disp_name),xlabel('Ah'),ylabel('V'),hold on
        subplot(222),plot(dqdu,uf),title('ICA plot'),xlabel('Ah/V'),ylabel('V'),hold on
        subplot(223),plot(qf,dudq),title('DVA plot'),xlabel('Ah'),ylabel('V/Ah'),hold on
    end
    subplot(221),legend show;
    legend('location','southwest')
end