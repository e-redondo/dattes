function hf = plot_config(profiles,config,phases,title_str,options)
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
% - profiles [1x1 struct] with fields
%     - t [nx1 double]: time in seconds
%     - U [nx1 double]: voltage in V
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
if ~exist('title_str','var')
    title_str = '';
end

%abcise: tc au lieu de tabs,en heures ou en jours si options 'h' ou 'j':
if ismember('h',options)
    t_name = 't';
    t_factor = 1/3600;
    tunit = 'h';
elseif ismember('d',options)
    t_name = 't';
    t_factor = 1/86400;
    tunit = 'd';
elseif ismember('D',options)%datetime
    t_name = 'datetime';
    t_factor = 1;
    tunit = 's';
else
    t_name = 't';
    t_factor = 1;
    tunit = 's';
end

datetime = profiles.datetime;
U = profiles.U;
tc = profiles.(t_name);

if isempty(title_str)
hf = figure('name','DATTES configuration');
else
hf = figure('name',sprintf('DATTES configuration: %s',title_str));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%figure1: SoC configuration
I100 = ismember(datetime,config.soc.soc100_datetime);
I0 = ismember(datetime,config.soc.soc0_datetime);

subplot(321),title('SoC configuration'),xlabel(sprintf('time [%s]',tunit)),hold on
plot(tc*t_factor,U,'k','displayname','test')


plot(tc(I100)*t_factor,U(I100),'ro','displayname','SoC100 point')
plot(tc(I0)*t_factor,U(I0),'rd','displayname','SoC0 point')

% plot(t(Iinicv),U(Iinicv),'r+','tag','debutCV')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%figure2: Capacity
% Phases of capacity analysis
tD = [];UD = [];tC = [];UC = [];tDV= [];UDV = [];tCV = [];UCV = [];
for ind = 1:length(phases)
    Ip = datetime>=phases(ind).datetime_ini & datetime<=phases(ind).datetime_fin;
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
subplot(322),title('Capacity configuration'),xlabel(sprintf('time [%s]',tunit)),hold on
plot(tc*t_factor,U,'k','displayname','test')
plot(tD*t_factor,UD,'r.','displayname','discharge')
plot(tC*t_factor,UC,'b.','displayname','charge')
plot(tDV*t_factor,UDV,'m.','displayname','discharge (CV phase)')
plot(tCV*t_factor,UCV,'c.','displayname','charge (CV phase)')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%figure3: Impedances
tR = [];UR = [];tW = [];UW = [];tRr = [];URr = [];tWr = [];UWr = [];

%resistance (ident_r):config.pR
phases_r = phases(config.resistance.pR);
time_before_after_phase = [config.resistance.rest_min_duration 0];
for ind = 1:length(phases_r)
    [tpRabs,tpR,UpR] = extract_phase2(phases_r(ind),time_before_after_phase,datetime,tc,U);
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
        Ip = datetime>=phases(ind).datetime_ini & datetime<=phases(ind).datetime_ini+config.impedance.pulse_min_duration;
        Ir = datetime>=phases(ind-1).datetime_fin-config.impedance.rest_min_duration & datetime<=phases(ind-1).datetime_fin;
        tW = [tW;tc(Ip)];
        UW = [UW;U(Ip)];
        tWr = [tWr;tc(Ir)];
        UWr = [UWr;U(Ir)];
        
    end
end


subplot(325),title('Resistance configuration'),xlabel(sprintf('time [%s]',tunit)),hold on
plot(tc*t_factor,U,'k','displayname','test')
plot(tR*t_factor,UR,'r.','displayname','pulse resistance')
plot(tRr*t_factor,URr,'b.','displayname','rest resistance')

subplot(326),title('Impedance configuration'),xlabel(sprintf('time [%s]',tunit)),hold on
plot(tc*t_factor,U,'k','displayname','test')
plot(tW*t_factor,UW,'r.','displayname','pulse impedance')
plot(tWr*t_factor,UWr,'b.','displayname','rest impedance')

%pOCV configuration
phases_pocv_c = phases(config.pseudo_ocv.pOCVpC);
phases_pocv_d = phases(config.pseudo_ocv.pOCVpD);
t_ocv_c = [];
U_ocv_c = [];
t_ocv_d = [];
U_ocv_d = [];
for ind = 1:length(phases_pocv_c)
    pro_ocv_c = extract_phase2(phases_pocv_c(ind), [0 0], profiles);
    t_ocv_c = [t_ocv_c; pro_ocv_c.(t_name)];
    U_ocv_c = [U_ocv_c; pro_ocv_c.U];
end
for ind = 1:length(phases_pocv_d)
    pro_ocv_d = extract_phase2(phases_pocv_d(ind), [0 0], profiles);
    t_ocv_d = [t_ocv_d; pro_ocv_d.(t_name)];
    U_ocv_d = [U_ocv_d; pro_ocv_d.U];
end

subplot(323),title('pseudo OCV configuration'),xlabel(sprintf('time [%s]',tunit)),hold on
plot(tc*t_factor,U,'k','displayname','test')
plot(t_ocv_d*t_factor,U_ocv_d,'r.','displayname','pseudo OCV (discharge)')
plot(t_ocv_c*t_factor,U_ocv_c,'b.','displayname','pseudo OCV (charge)')


%ICA configuration

phases_ica = phases(config.ica.pICA);
t_ica = [];
U_ica = [];
for ind = 1:length(phases_ica)
    pro_ica = extract_phase2(phases_ica(ind), [0 0], profiles);
    t_ica = [t_ica; pro_ica.(t_name)];
    U_ica = [U_ica; pro_ica.U];
end

subplot(324),title('ICA configuration'),xlabel(sprintf('time [%s]',tunit)),hold on
plot(tc*t_factor,U,'k','displayname','test')
plot(t_ica*t_factor,U_ica,'r.','displayname','ICA')


ha = findobj(hf, 'type','axes','tag','');
arrayfun(@(x) legend(x,'show','location','best'),ha);
% printLegTag(ha,'eastoutside');
prettyAxes(ha);
% linkaxes(ha, 'xy' );
changeLine(ha,1,5);
end
