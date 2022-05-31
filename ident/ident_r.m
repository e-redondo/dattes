function [resistance] = ident_r(t,U,I,dod_ah,config,phases,options)
%ident_r resistance identification from a profile t,U,I,m
%
% Usage:
% [resistance] = ident_r(t,U,I,dod_ah,config,phases,options)
%
% Inputs:
% - t, U, I, dod_ah [(nx1) double]: from extract_profiles
% - config [(1x1) struct] from configurator
% - phases [(mx1) struct] from split_phases
% - options [(1xp) string] execution options:
%     - 'v': verbose
%     - 'g': graphics
% Outputs:
% - resistance [(1x1) struct] with fields:
%     - R [(qx1) double]: resistance value (Ohms)
%     - dod [(qx1) double]: depth of discharge (Ah)
%     - crate [(qx1) double]: current rate (C)
%     - time [(qx1) double]: time of measurement (s)
%     - delta_time [(qx1) double]: time from pulse start (s)
%
%See also dattes, calcul_r
if ~exist('options','var')
    options = '';
end
if ismember('v',options)
    fprintf('ident_r:...');
end
R = [];
dod = [];
crate = [];
time = [];
delta_time = [];
%%
%gestion d'erreurs:
if nargin<6 || nargin>7
    fprintf('ident_r:nombre incorrect de parametres, trouves %d\n',nargin);
    return;
end
if ~isstruct(config) || ~ischar(options) || ~isnumeric(t) ...
        || ~isnumeric(U) || ~isnumeric(I) || ~isnumeric(dod_ah)
    fprintf('ident_r:type de parametres, incorrect\n');
    return;
end
if ~isfield(config,'resistance')
    fprintf('ident_r:structure config incomplete\n');
    return;
end
if ~isfield(config.resistance,'pR') || ~isfield(config.resistance,'rest_min_duration') || ~isfield(config.resistance,'pulse_min_duration') || ~isfield(config.resistance,'delta_time') || ~isfield(config.resistance,'instant_end_rest')
    fprintf('ident_r:structure config incomplete\n');
    return;
end

pulse_min_duration = config.resistance.pulse_min_duration;
rest_min_duration = config.resistance.rest_min_duration;
delta_time_cfg = config.resistance.delta_time;

%%
% tIniPulses = config.tR-config.tminRr-1;%FIX (BRICOLE) je met une seconde de plus (sinon warning dans calculR ligne69)
% tFinPulses = config.tR+config.tminR+1;%FIX (BRICOLE) je met une seconde de plus (sinon warning dans calculR ligne72)
indices_phases_r = find(config.resistance.pR);
time_before_after_phase = [rest_min_duration 0];

resistance = struct([]);
R = [];
crate = [];
time = [];
dod = [];
delta_time = [];



for ind = 1:length(indices_phases_r)
%     Ipulse = t>=tIniPulses(ind) & t<=tFinPulses(ind);
%     tp = t(Ipulse);
%     Up = U(Ipulse);
%     Ip = I(Ipulse);


    [tp,Up,Ip,DoDp] = extract_phase2(phases(indices_phases_r(ind)),time_before_after_phase,t,U,I,dod_ah);%FIX (BRICOLE) la même mais avec getPhases 2
    Is = tp-tp(1)<rest_min_duration+pulse_min_duration+3;%FIX (BRICOLE) la même mais avec getPhases 2
    tp = tp(Is);
    Up = Up(Is);
    Ip = Ip(Is);

    [thisR, this_crate, this_time, this_dod,this_delta_time, err] = calcul_r(tp,Up,Ip,DoDp,config.resistance.instant_end_rest(ind),pulse_min_duration,rest_min_duration ,delta_time_cfg);
   
    R = [R thisR];
    crate = [crate this_crate];
    time = [time this_time];
    dod = [dod this_dod];
    delta_time = [delta_time this_delta_time];
    

    
end
crate = crate/config.test.capacity;

%put all in output struct:
resistance(1).R = R;
resistance.dod = dod;
resistance.crate = crate;
resistance.time = time;
resistance.delta_time = delta_time;

if ismember('v',options)
    fprintf('OK\n');
end
if ismember('g',options)
    showResult(t,U,I,dod_ah,R,dod,crate,time);
end
end

function showResult(t,U,I,dod_ah,R,dod,crate,time)

hf = figure('name','ident_r');
subplot(221),plot(t,U,'b'),hold on,xlabel('time (s)'),ylabel('voltage (V)')
% subplot(222),plot(t,I,'b'),hold on,xlabel('time (s)'),ylabel('current (A)')
% subplot(223),plot(t,dod_ah,'b'),hold on,xlabel('time (s)'),ylabel('DoD (Ah)')

Ip = ismember(t,time);
subplot(221),plot(t(Ip),U(Ip),'ro')
Ip = ismember(t,time(isnan(R)));
subplot(221),plot(t(Ip),U(Ip),'rx')

% subplot(222),plot(t(Ip),I(Ip),'ro')
% subplot(223),plot(t(Ip),dod_ah(Ip),'ro')
subplot(223),plot(time,R,'ro'),xlabel('time (s)'),ylabel('resistance (Ohm)')
subplot(222),plot(dod,R,'ro'),xlabel('DoD(Ah)'),ylabel('resistance (Ohm)')
subplot(224),plot(crate,R,'ro'),xlabel('Current(C)'),ylabel('resistance (Ohm)')

%cherche tout les handles du type axe et ignore les legendes
ha = findobj(hf,'type','axes','tag','');
% printLegTag(ha,'eastoutside');
prettyAxes(ha);
% linkaxes(ha, 'x' );
changeLine(ha,2,15);
end
