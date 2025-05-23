function [resistance] = ident_r(profiles,config,phases,options)
%ident_r resistance identification 
%
% Usage:
% [resistance] = ident_r(profiles,config,phases,options)
% Read the config and phases structure and performe several calculations
% regarding resistance.  Results are returned in the structure resistance 
%
% Inputs:
% - profiles [(1x1) struct] with fields:
%     - datetime, U, I, dod_ah [(nx1) double]
% - config [(1x1) struct] from configurator
% - phases [(mx1) struct] from split_phases
% - options [(1xp) string] execution options:
%     - 'v': verbose
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
if nargin<3 || nargin>4
    fprintf('ident_r: wrong number of parameters, found %d\n',nargin);
    return;
end
if ~isstruct(profiles) || ~isstruct(config) || ~ischar(options)
    fprintf('ident_r: wrong type of parameters\n');
    return;
end
if ~isfield(config,'resistance')
    fprintf('ident_r: incomplete structure config, redo dattes_configure\n');
    return;
end
if ~isfield(config.resistance,'pR') || ~isfield(config.resistance,'rest_min_duration') || ~isfield(config.resistance,'pulse_min_duration') || ~isfield(config.resistance,'delta_time') || ~isfield(config.resistance,'instant_end_rest')
    fprintf('ident_r: incomplete structure config, redo dattes_configure\n');
    return;
end


datetime = profiles.datetime;
t = profiles.t;
U = profiles.U;
I = profiles.I;
dod_ah = profiles.dod_ah;

pulse_min_duration = config.resistance.pulse_min_duration;
rest_min_duration = config.resistance.rest_min_duration;
delta_time_cfg = config.resistance.delta_time;

%%
indices_phases_r = find(config.resistance.pR);
time_before_after_phase = [rest_min_duration 0];


R = [];
crate = [];
datetime_r = [];
t_r = [];
dod = [];
delta_time = [];
U_sim = [];
err_U = [];



for ind = 1:length(indices_phases_r)


    [tp,Up,Ip,DoDp] = extract_phase2(phases(indices_phases_r(ind)),time_before_after_phase,datetime,U,I,dod_ah);%FIX (BRICOLE) la même mais avec getPhases 2
    %Is = tp-tp(1)<rest_min_duration+pulse_min_duration+3;%FIX (BRICOLE) la même mais avec getPhases 2
    Is = tp-tp(1)<rest_min_duration+max(delta_time_cfg)+3;
    tp = tp(Is);
    Up = Up(Is);
    Ip = Ip(Is);
    DoDp = DoDp(Is);
    % [Rp, R_I,Rt,RDoD,Rdt,U_sim,err_U,err] = calcul_r(t,U,I,DoDAh,instant_end_rest,duration_pulse,duration_rest,delta_time)
    [thisR, this_crate, this_datetime, this_dod,this_delta_time,this_U_sim,this_err_U, err] = calcul_r(tp,Up,Ip,DoDp,config.resistance.instant_end_rest(ind),rest_min_duration ,delta_time_cfg);
    
    if ~isempty(thisR)
        ind_s = ismember(profiles.datetime,this_datetime);
        this_time = profiles.t(ind_s);
        R = [R thisR];
        crate = [crate this_crate];
        datetime_r = [datetime_r this_datetime];
        dod = [dod this_dod];
        delta_time = [delta_time this_delta_time];
        U_sim = [U_sim this_U_sim];
        err_U = [err_U this_err_U];
        t_r  = [t_r this_time*ones(size(this_delta_time))];
    end
end
crate = crate/config.test.capacity;

%put all in output struct:
resistance(1).R = R;
resistance.dod = dod;
resistance.crate = crate;
resistance.datetime = datetime_r;

resistance.t = t_r;
resistance.delta_time = delta_time;
resistance.U_sim = U_sim;
resistance.err_U = err_U;

if ismember('v',options)
    fprintf('OK\n');
end

end
