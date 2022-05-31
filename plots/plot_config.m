function hf = plot_config(t,U,config,phases,title_str,options)
%plot_config visualize configuration for dattes.
%
%hf = plot_config(t,U,config,phases,titre,options)
%
% Make a figure with three plots:
% 1) t vs U  with detected moments of SoC100 / SoC0
% 2) t vs U  with detected phases for capacity measurements
% 3) t vs U  with detected phases for impedance identification
%
% See also dattes, configurator


if ~exist('options','var')
    options = '';
end
tc = t-t(1);
%abcise: tc au lieu de tabs,en heures ou en jours si options 'h' ou 'j':
if ismember('h',options)
    tc = tc/3600;
    tunit = 'h';
elseif ismember('d',options)
    tc = tc/86400;
    tunit = 'd';
else
    tunit = 's';
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%figure1: t100, ini et fin CV
hf = figure('Name','plot_config');
subplot(311),title('calcul SOC');
plot(tc,U,'k','displayname','test'),hold on

I100 = ismember(t,config.soc.soc100_time);
plot(tc(I100),U(I100),'ro','displayname','t100')
% plot(t(Iinicv),U(Iinicv),'r+','tag','debutCV')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%figure2: capacites
%phases de mesure de capacite en decharge
tD = [];UD = [];tC = [];UC = [];tDV= [];UDV = [];tCV = [];UCV = [];
for ind = 1:length(phases)
    Ip = t>=phases(ind).t_ini & t<=phases(ind).t_fin;
    if config.pCapaD(ind)
        tD = [tD;tc(Ip)];
        UD = [UD;U(Ip)];
    end
    if config.pCapaC(ind)
        tC = [tC;tc(Ip)];
        UC = [UC;U(Ip)];
    end
    if config.pCapaDV(ind)
        tDV = [tDV;tc(Ip)];
        UDV = [UDV;U(Ip)];
    end
    if config.pCapaCV(ind)
        tCV = [tCV;tc(Ip)];
        UCV = [UCV;U(Ip)];
    end
end
% figure('Name','configurator: calculCapa');
subplot(312),title('calcul Capa');
plot(tc,U,'k','displayname','test'),hold on
plot(tD,UD,'r.','displayname','capaD')
plot(tC,UC,'b.','displayname','capaC')
plot(tDV,UDV,'m.','displayname','capaDV')
plot(tCV,UCV,'c.','displayname','capaCV'),xlabel(sprintf('time [%s]',tunit))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%figure3: impedances
tR = [];UR = [];tW = [];UW = [];tRr = [];URr = [];tWr = [];UWr = [];

%resistance (ident_r):config.pR
phases_r = phases(config.pR);
time_before_after_phase = [config.minimal_duration_rest_before_pulse 0];
for ind = 1:length(phases_r)
    [tpRabs,tpR,UpR] = extract_phase2(phases_r(ind),time_before_after_phase,t,tc,U);
    Ip = tpRabs>=phases_r(ind).t_ini;
    Ir = tpRabs<phases_r(ind).t_ini;
    tR = [tR;tpR(Ip)];
    tRr = [tRr;tpR(Ir)];
    UR = [UR;UpR(Ip)];
    URr = [URr;UpR(Ir)];
    
end
%impedance (iden_z): TODO new method like ident_r

%resistance and impedance (old method):
for ind = 1:length(phases)
    
%     if config.pR(ind)
%         Ip = t>=phases(ind).t_ini & t<=phases(ind).t_ini+config.tminR;
%         Ir = t>=phases(ind-1).t_fin-config.tminRr & t<=phases(ind-1).t_fin;
%         
%         tR = [tR;tc(Ip)];
%         UR = [UR;U(Ip)];
%         tRr = [tRr;tc(Ir)];
%         URr = [URr;U(Ir)];
%         
%     end
    if config.pW(ind)
        Ip = t>=phases(ind).t_ini & t<=phases(ind).t_ini+config.impedance.pulse_min_duration;
        Ir = t>=phases(ind-1).t_fin-config.impedance.rest_min_duration & t<=phases(ind-1).t_fin;
        tW = [tW;tc(Ip)];
        UW = [UW;U(Ip)];
        tWr = [tWr;tc(Ir)];
        UWr = [UWr;U(Ir)];
        
    end
end
% URr = U(ismember(t,config.tR));
% UWr = U(ismember(t,config.tW));

% figure('Name','configurator: calculZ');
subplot(313),title('calcul Z');
plot(tc,U,'k','displayname','test'),hold on
plot(tW,UW,'go','displayname','diffusion')
plot(tWr,UWr,'g.','displayname','rest diffusion')
plot(tR,UR,'co','displayname','resistance')
plot(tRr,URr,'c.','displayname','rest resistance'),xlabel(sprintf('time [%s]',tunit))

subplot(311),title(title_str,'interpreter','none'),xlabel(sprintf('time [%s]',tunit))
ha = findobj(hf, 'type','axes','tag','');
arrayfun(@(x) legend(x,'show','location','eastoutside'),ha);
% printLegTag(ha,'eastoutside');
prettyAxes(ha);
linkaxes(ha, 'x' );
changeLine(ha,2,15);
end