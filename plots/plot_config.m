function hf = plot_config(t,U,config,phases,title_str,options)
%plot_config visualize configuration of a test
%
% plot_config(t,U,config,phases,title_str,options)
% Make a figure with two subplots: U vs. t et I vs. t. with identified
% phases by split_phases function (CC, CV, rest, etc.). If more than 100
% phases, only longer 100 phases will be ploted (color and number).
%
% Usage:
% hf = plot_config(t,U,config,phases,title_str,options)
% Inputs:
% - t [nx1 double]: time in seconds
% - U [nx1 double]: voltage in V
% - config [nx1 struct]: configuration structure
% - phases [nx1 struct]] phases structure
% - title: [string] title string
% Output:
% - hf [1x1 figure handler]: handler for created figure
%
% See also dattes, dattes_plot, configurator, extract_profiles
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.


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

I100 = ismember(t,config.soc.soc100_datetime);
I0 = ismember(t,config.soc.soc0_datetime);

plot(tc(I100),U(I100),'ro','displayname','t100')
plot(tc(I0),U(I0),'rd','displayname','t0')

% plot(t(Iinicv),U(Iinicv),'r+','tag','debutCV')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%figure2: Capacity
% Phases of capacity analysis
tD = [];UD = [];tC = [];UC = [];tDV= [];UDV = [];tCV = [];UCV = [];
for ind = 1:length(phases)
    Ip = t>=phases(ind).datetime_ini & t<=phases(ind).datetime_fin;
    if config.capacity.pCapaD(ind)
        tD = [tD;tc(Ip)];
        UD = [UD;U(Ip)];
    end
    if config.capacity.pCapaC(ind)
        tC = [tC;tc(Ip)];
        UC = [UC;U(Ip)];
    end
    if config.capacity.pCapaDV(ind)
        tDV = [tDV;tc(Ip)];
        UDV = [UDV;U(Ip)];
    end
    if config.capacity.pCapaCV(ind)
        tCV = [tCV;tc(Ip)];
        UCV = [UCV;U(Ip)];
    end
end
subplot(312),title('calcul Capa');
plot(tc,U,'k','displayname','test'),hold on
plot(tD,UD,'r.','displayname','capaD')
plot(tC,UC,'b.','displayname','capaC')
plot(tDV,UDV,'m.','displayname','capaDV')
plot(tCV,UCV,'c.','displayname','capaCV'),xlabel(sprintf('time [%s]',tunit))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%figure3: Impedances
tR = [];UR = [];tW = [];UW = [];tRr = [];URr = [];tWr = [];UWr = [];

%resistance (ident_r):config.pR
phases_r = phases(config.resistance.pR);
time_before_after_phase = [config.resistance.rest_min_duration 0];
for ind = 1:length(phases_r)
    [tpRabs,tpR,UpR] = extract_phase2(phases_r(ind),time_before_after_phase,t,tc,U);
    Ip = tpRabs>=phases_r(ind).datetime_ini;
    Ir = tpRabs<phases_r(ind).datetime_ini;
    tR = [tR;tpR(Ip)];
    tRr = [tRr;tpR(Ir)];
    UR = [UR;UpR(Ip)];
    URr = [URr;UpR(Ir)];
    
end
%impedance (iden_z): TODO new method like ident_r

%resistance and impedance (old method):
for ind = 1:length(phases)

    if config.impedance.pZ(ind)
        Ip = t>=phases(ind).datetime_ini & t<=phases(ind).datetime_ini+config.impedance.pulse_min_duration;
        Ir = t>=phases(ind-1).datetime_fin-config.impedance.rest_min_duration & t<=phases(ind-1).datetime_fin;
        tW = [tW;tc(Ip)];
        UW = [UW;U(Ip)];
        tWr = [tWr;tc(Ir)];
        UWr = [UWr;U(Ir)];
        
    end
end

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
