function [capacity] = ident_capacity(config,phases,options)
%ident_capacity capacity identification
% [capacity, capacity_rate, capa_time, cv_voltage, cv_duration, cv_capacity, cv_time] = ident_capacity(config,phases,options)
%
% INPUTS:
% config (1x1) configuration structure from configurator
% phases (1xn) phases array structure from split_phases
% options (string) containing:
%   - 'v': verbose, tell what you do
%
% OUTPUTS:
% - capacity [(1x1) struct] with fields:
%     - cc_capacity (1xk) double: CC capacity measurements
%     - cc_crate (1xk) double: C-Rate of each CC capacity measurement
%     - cc_time (1xk) double: time of each CC capacity measurement
%     - cc_duration (1xj) double: duration of each CC phase
%     - cv_capacity (1xj) double: residual capacity of each CV phase
%     - cv_voltage (1xj) double: voltage of each CV phase
%     - cv_time (1xj) double: time of each CV phase
%     - cv_duration (1xj) double: duration of each CV phase
%
% See also dattes, split_phases, configurator, plot_capacity

if ~exist('options','var')
    options='';
end
if ismember('v',options)
    fprintf('ident_capacity:...');
end

capacity = struct([]);
cc_capacity = [];
cc_crate = [];

%gestion d'erreurs:
if nargin<2 || nargin>3
    fprintf('ident_capacity: wrong number of parametres, found %d\n',nargin);
    return;
end
if ~isstruct(phases) || ~isstruct(config) || ~ischar(options)
    fprintf('ident_capacity: wrong type of parametres\n');
    return;
end
if ~isfield(config,'capacity')
    fprintf('ident_capacity: structure config incomplete, redo configurator: dattes(''cs'')\n');
    return;
end
if ~isfield(config.capacity,'pCapaD') || ~isfield(config.capacity,'pCapaC') || ~isfield(config.capacity,'pCapaDV') || ~isfield(config.capacity,'pCapaCV')
    fprintf('ident_capacity: structure config incomplete, redo configurator: dattes(''cs'')\n');
    return;
end
if ~isfield(phases,'capacity') || ~isfield(phases,'duration') || ~isfield(phases,'Iavg') || ~isfield(phases,'Uavg')
    fprintf('ident_capacity: structure phases incomplete, redo decompose: dattes(''ps'')\n');
    return;
end

%CC part
phases_cc = phases(config.capacity.pCapaD | config.capacity.pCapaC);
cc_capacity = abs([phases_cc.capacity]);
cc_crate = [phases_cc.Iavg]./config.test.capacity;
cc_time = [phases_cc.t_ini];
cc_duration = [phases_cc.duration];

%CV part
phases_cv = phases(config.capacity.pCapaDV | config.capacity.pCapaCV);
cv_capacity = abs([phases_cv.capacity]);
cv_voltage = [phases_cv.Uavg];
cv_time = [phases_cv.t_ini];
cv_duration = [phases_cv.duration];


%put into output structure:
capacity(1).cc_capacity = cc_capacity;
capacity.cc_crate = cc_crate;
capacity.cc_time = cc_time;
capacity.cc_duration = cc_duration;
capacity.cv_capacity = cv_capacity;
capacity.cv_voltage = cv_voltage;
capacity.cv_time = cv_time;
capacity.cv_duration = cv_duration;
    
if ismember('v',options)
    fprintf('OK\n');
end
end
