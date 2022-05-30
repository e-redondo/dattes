function [cc_capacity, cc_crate, cc_time, cc_duration, cv_capacity, cv_voltage, cv_time, cv_duration] = ident_capacity(config,phases,options)
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
% cc_capacity (1xk) double: CC capacity measurements
% cc_crate (1xk) double: C-Rate of each CC capacity measurement
% cc_time (1xk) double: time of each CC capacity measurement
% cv_voltage (1xj) double: voltage of each CV phase
% cv_duration (1xj) double: duration of each CV phase
% cv_capacity (1xj) double: residual capacity of each CV phase
% cv_time (1xj) double: time of each CV phase
%
% See also dattes, split_phases, configurator, plot_capacity

if ~exist('options','var')
    options='';
end
if ismember('v',options)
    fprintf('ident_capacity:...');
end
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
if ~isfield(config,'pCapaD') || ~isfield(config,'pCapaC') || ~isfield(config,'pCapaDV') || ~isfield(config,'pCapaCV')
    fprintf('ident_capacity: structure config incomplete, redo configurator: dattes(''cs'')\n');
    return;
end
if ~isfield(phases,'capacity') || ~isfield(phases,'duration') || ~isfield(phases,'Iavg') || ~isfield(phases,'Uavg')
    fprintf('ident_capacity: structure phases incomplete, redo decompose: dattes(''ps'')\n');
    return;
end

%CC part
phasesCC = phases(config.pCapaD | config.pCapaC);
cc_capacity = abs([phasesCC.capacity]);
cc_crate = [phasesCC.Iavg]./config.Capa;
cc_time = [phasesCC.t_ini];
cc_duration = [phasesCC.duration];

%CV part
phasesCV = phases(config.pCapaDV | config.pCapaCV);
cv_capacity = abs([phasesCV.capacity]);
cv_voltage = [phasesCV.Uavg];
cv_time = [phasesCV.t_ini];
cv_duration = [phasesCV.duration];


if ismember('v',options)
    fprintf('OK\n');
end
end