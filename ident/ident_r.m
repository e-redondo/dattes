function [resistance] = ident_r(datetime,U,I,dod_ah,config,phases,options)
%ident_r resistance identification 
%
% Usage:
% [resistance] = ident_r(datetime,U,I,dod_ah,config,phases,options)
% Read the config and phases structure and performe several calculations
% regarding resistance.  Results are returned in the structure resistance 
%
% Inputs:
% - datetime, U, I, dod_ah [(nx1) double]: from extract_profiles
% - config [(1x1) struct] from configurator
% - phases [(mx1) struct] from split_phases
% - options [(1xp) string] execution options:
%     - 'v': verbose
%     - 'g': graphics
%
% Outputs:
% - resistance [(1x1) struct] with fields:
%     - R [(qx1) double]: resistance value (Ohms)
%     - dod [(qx1) double]: depth of discharge (Ah)
%     - crate [(qx1) double]: current rate (C)
%     - datetime [(qx1) double]: time of measurement (s)
%     - delta_time [(qx1) double]: time from pulse start (s)
%
% See also dattes, calcul_r
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

if ~exist('options','var')
    options = '';
end
if ismember('v',options)
    fprintf('ident_r:...');
end
resistance = struct([]);

%%
%gestion d'erreurs:
if nargin<6 || nargin>7
    fprintf('ident_r: wrong number of parameters, found %d\n',nargin);
    return;
end
if ~isstruct(config) || ~ischar(options) || ~isnumeric(datetime) ...
        || ~isnumeric(U) || ~isnumeric(I) || ~isnumeric(dod_ah)
    fprintf('ident_r: wrong type of parameters\n');
    return;
end
if ~isfield(config,'resistance')
    fprintf('ident_r: incomplete structure config, redo configurator: dattes(''cs'')\n');
    return;
end
if ~isfield(config.resistance,'pR') || ~isfield(config.resistance,'rest_min_duration') || ~isfield(config.resistance,'pulse_min_duration') || ~isfield(config.resistance,'delta_time') || ~isfield(config.resistance,'instant_end_rest')
    fprintf('ident_r: incomplete structure config, redo configurator: dattes(''cs'')\n');
    return;
end

pulse_min_duration = config.resistance.pulse_min_duration;
rest_min_duration = config.resistance.rest_min_duration;
delta_time_cfg = config.resistance.delta_time;

%%
indices_phases_r = find(config.resistance.pR);
time_before_after_phase = [rest_min_duration 0];


R = [];
crate = [];
datetime_r = [];
dod = [];
delta_time = [];



for ind = 1:length(indices_phases_r)


    [tp,Up,Ip,DoDp] = extract_phase2(phases(indices_phases_r(ind)),time_before_after_phase,datetime,U,I,dod_ah);%FIX (BRICOLE) la même mais avec getPhases 2
    %Is = tp-tp(1)<rest_min_duration+pulse_min_duration+3;%FIX (BRICOLE) la même mais avec getPhases 2
    Is = tp-tp(1)<rest_min_duration+max(delta_time_cfg)+3;
    tp = tp(Is);
    Up = Up(Is);
    Ip = Ip(Is);

    [thisR, this_crate, this_time, this_dod,this_delta_time, err] = calcul_r(tp,Up,Ip,DoDp,config.resistance.instant_end_rest(ind),pulse_min_duration,rest_min_duration ,delta_time_cfg);
   
    R = [R thisR];
    crate = [crate this_crate];
    datetime_r = [datetime_r this_time];
    dod = [dod this_dod];
    delta_time = [delta_time this_delta_time];
    

    
end
crate = crate/config.test.capacity;

%put all in output struct:
resistance(1).R = R;
resistance.dod = dod;
resistance.crate = crate;
resistance.datetime = datetime_r;
resistance.delta_time = delta_time;

if ismember('v',options)
    fprintf('OK\n');
end
if ismember('g',options)
    showResult(datetime,U,I,dod_ah,R,dod,crate,datetime_r);
end
end

function showResult(t,U,I,dod_ah,R,dod,crate,time)

hf = figure('name','ident_r');
subplot(221),plot(t,U,'b'),hold on,xlabel('time (s)'),ylabel('voltage (V)')


Ip = ismember(t,time);
subplot(221),plot(t(Ip),U(Ip),'ro')
Ip = ismember(t,time(isnan(R)));
subplot(221),plot(t(Ip),U(Ip),'rx')


subplot(223),plot(time,R,'ro'),xlabel('time (s)'),ylabel('resistance (Ohm)')
subplot(222),plot(dod,R,'ro'),xlabel('DoD(Ah)'),ylabel('resistance (Ohm)')
subplot(224),plot(crate,R,'ro'),xlabel('Current(C)'),ylabel('resistance (Ohm)')

%Look for all axis handles and ignore legends
ha = findobj(hf,'type','axes','tag','');
% printLegTag(ha,'eastoutside');
prettyAxes(ha);
% linkaxes(ha, 'x' );
changeLine(ha,2,15);
end
