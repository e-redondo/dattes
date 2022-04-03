function hf = plot_soc(t, I, DoDAh, SOC, config,title_str,options)

if ~exist('options','var')
    options = '';
end
%abcise: tc au lieu de tabs,en heures ou en jours si options 'h' ou 'd':
tc = t-t(1);
if ismember('h',options)
    tc = tc/3600;
    tunit = 'h';
elseif ismember('d',options)
    tc = tc/86400;
    tunit = 'd';
else
    tunit = 's';
end
I100 = ismember(t,config.t100);
hf = figure('name','plot_soc');

subplot(311),plot(tc,I),hold on,ylabel('current [A]'),xlabel(sprintf('time [%s]',tunit)),grid on
subplot(311),plot(tc(I100),I(I100),'ro')
if ~isempty(DoDAh)
    subplot(312),plot(tc,DoDAh),hold on,ylabel('DoDAh [Ah]'),xlabel(sprintf('time [%s]',tunit)), grid on
    subplot(312),plot(tc(I100),DoDAh(I100),'ro'),ylim([min(0,min(DoDAh)) max(config.Capa,max(DoDAh))])
    subplot(313),plot(tc(I100),SOC(I100),'ro'),ylim([min(0,min(SOC)) max(100,max(SOC))])
    subplot(313),plot(tc,SOC),hold on,ylabel('SOC [%]'),xlabel(sprintf('time [%s]',tunit)), grid on
end

subplot(311),title(title_str,'interpreter','none')
ha = findobj( hf, 'type', 'axes', 'tag', '' );
prettyAxes(ha);
linkaxes(ha, 'x' );
changeLine(ha,2,15);

end