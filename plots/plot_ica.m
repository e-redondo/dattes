function plot_ica(ica)
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