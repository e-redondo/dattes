function hf = plot_ica(ica,title_str)
% plot_ica plot incremental capacity analysis graphs
%
% plot_ica(ica)
% Use ica structure to plot incremental capacity analysis graphs
%
% Usage:
% hf = plot_ica(ica)
% Inputs:
% - ica [mx1 struct] with fields:
%   - dqdu [px1 double]: voltage derivative of capacity
%   - dudq [px1 double]: capacity derivative of voltage
%   - q [px1 double]: capacity vector for dudq
%   - u [px1 double]: voltage vector for dqdu
%   - crate [1x1 double]: charge or discharge C-rate
%   - time [1x1 double]: time of measurement
% - title_str: [string] title string
% Output:
% - hf [1x1 figure handler]: handler for created figure
%
% See also dattes, dattes_plot, configurator, extract_profiles
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.


if isempty(title_str)
    hf = figure('name','DATTES Incremental Capacity Analysis');
else
    hf = figure('name',sprintf('DATTES Incremental Capacity Analysis: %s',title_str));
end

for ind = 1:length(ica)
    qf = ica(ind).q;
    uf = ica(ind).u;
    dqdu = ica(ind).dqdu;
    dudq = ica(ind).dudq;
    crate = ica(ind).crate;

    disp_name = sprintf('C-rate=%.3fC',crate);

    subplot(221),plot(qf,uf,'DisplayName',disp_name),title('Voltage vs. capacity'),xlabel('DoD [Ah]'),ylabel('Voltage [V]'),hold on
    subplot(222),plot(dqdu,uf),title('ICA plot'),xlabel('dQ/dU [Ah/V]'),ylabel('Voltage [V]'),hold on
    subplot(223),plot(qf,dudq),title('DVA plot'),xlabel('DoD [Ah]'),ylabel('dU/dQ [V/Ah]'),hold on
end
subplot(221),legend show;
legend('location','southwest')


    %Look for all axis handles and ignore legends
ha = findobj(hf,'type','axes','tag','');
prettyAxes(ha);
changeLine(ha,1,5);
end
