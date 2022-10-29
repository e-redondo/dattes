function [capacity] = ident_capacity(config,phases,options)
%ident_capacity capacity identification
%
% [capacity] = ident_capacity(config,phases,options)
% Read the config and phases structure and performe several calculations
% regarding capacity.  Results are returned in the structure capacity 
%
% Usage:
% [capacity] = ident_capacity(config,phases,options)
% Inputs : 
% config (1x1 struct) configuration structure from configurator
% phases (1xn struct) phases array structure from split_phases
% options (string) containing:
%   - 'v': verbose, tell what you do
%   - 'g' : show figures
%
% Output:
% - capacity [(1x1) struct] with fields:
%     - cc_capacity (1xk) double: CC capacity measurements
%     - cc_crate (1xk) double: C-Rate of each CC capacity measurement
%     - cc_time (1xk) double: final time of each CC capacity measurement
%     - cc_duration (1xj) double: duration of each CC phase
%     - cv_capacity (1xj) double: residual capacity of each CV phase
%     - cv_voltage (1xj) double: voltage of each CV phase
%     - cv_time (1xj) double: final time of each CV phase
%     - cv_duration (1xj) double: duration of each CV phase
%     - cccv_time (1xn) double: final time of cc part of each CC-CV capacity measurement
%     - cccv_capacity (1xn) double: sum of CC and CV capacity measurements
%     - cccv_duration(1xn) double: sum of CC and CV capacity durations
%     - cccv_ratio_cc_ah (1xn) double : CC part of CCCV capacity measurements (p.u. of total capacity) 
%     - cccv_ratio_cc_duration (1xn) double : CC part of CCCV capacity measurements duration (p.u. of CCCV duration) 
%
% See also dattes, split_phases, configurator, plot_capacity
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

if ~exist('options','var')
    options='';
end
if ismember('v',options)
    fprintf('ident_capacity:...');
end

capacity = struct([]);




%% check inputs:
if nargin<2 || nargin>3
    fprintf('ident_capacity: wrong number of parameters, found %d\n',nargin);
    return;
end
if ~isstruct(phases) || ~isstruct(config) || ~ischar(options)
    fprintf('ident_capacity: wrong type of parameters\n');
    return;
end
if ~isfield(config,'capacity')
    fprintf('ident_capacity: incomplete structure config, redo configurator: dattes(''cs'')\n');
    return;
end
if ~isfield(config.capacity,'pCapaD') || ~isfield(config.capacity,'pCapaC') || ~isfield(config.capacity,'pCapaDV') || ~isfield(config.capacity,'pCapaCV')
    fprintf('ident_capacity: incomplete structure config, redo configurator: dattes(''cs'')\n');
    return;
end
if ~isfield(phases,'capacity') || ~isfield(phases,'duration') || ~isfield(phases,'Iavg') || ~isfield(phases,'Uavg')
    fprintf('ident_capacity: incomplete structure phases, redo decompose: dattes(''ps'')\n');
    return;
end

%CC part
phases_cc = phases(config.capacity.pCapaD | config.capacity.pCapaC);
cc_capacity = abs([phases_cc.capacity]);
cc_crate = [phases_cc.Iavg]./config.test.capacity;
cc_time = [phases_cc.t_fin];
cc_duration = [phases_cc.duration];

%CV part
phases_cv = phases(config.capacity.pCapaDV | config.capacity.pCapaCV);
cv_capacity = abs([phases_cv.capacity]);
cv_voltage = [phases_cv.Uavg];
cv_time = [phases_cv.t_fin];
cv_duration = [phases_cv.duration];

%CC+CV

[cccv_time,cccv_capacity,cccv_duration,cccv_crate,cccv_ratio_cc_ah,cccv_ratio_cc_duration]=append_cc_and_cv(config,phases);

%put into output structure:

capacity(1).cc_capacity = cc_capacity;
% capacity.cc_capacity = cc_capacity;
capacity.cc_crate = cc_crate;
capacity.cc_time = cc_time;
capacity.cc_duration = cc_duration;
capacity.cv_capacity = cv_capacity;
capacity.cv_voltage = cv_voltage;
capacity.cv_time = cv_time;
capacity.cv_duration = cv_duration;

capacity.cccv_time=cccv_time;
capacity.cccv_capacity=cccv_capacity;
capacity.cccv_duration=cccv_duration;
capacity.cccv_crate=cccv_crate;

capacity.cccv_ratio_cc_ah=cccv_ratio_cc_ah;
capacity.cccv_ratio_cc_duration=cccv_ratio_cc_duration;


if ismember('v',options)
    fprintf('OK\n');
end
end


function [cccv_time,cccv_capacity,cccv_duration, cccv_crate,cccv_ratio_cc_ah,cccv_ratio_cc_duration]=append_cc_and_cv(config,phases)





%Look for cc capacity phases followed by cv capacity phases
phases_cccv=config.capacity.pCapaC |config.capacity.pCapaCV| config.capacity.pCapaD  | config.capacity.pCapaDV ;
sequence=[1 1];

%Store position of cc phases which are followed by cv phases
Index_cccv=strfind(phases_cccv, sequence);

%Calculate full capacity at these positions 
capacities=[phases.capacity];
durations=[phases.duration];
times=[phases.t_fin];
crates = [phases.Iavg]./config.test.capacity;

%Store the (dis)charged Ah and duration in arrays for each CC-CV phases

cccv_capacity=nan(1,length(Index_cccv));
cccv_duration=nan(1,length(Index_cccv));
cccv_time=nan(1,length(Index_cccv));
ah_cc_in_cccv=nan(1,length(Index_cccv));
ah_cv_in_cccv=nan(1,length(Index_cccv));
duration_cc_in_cccv=nan(1,length(Index_cccv));
duration_cv_in_cccv=nan(1,length(Index_cccv));
cccv_crate=nan(1,length(Index_cccv));

for indice=1:length(Index_cccv)
    cccv_time(indice)=times(Index_cccv(1,indice));
    cccv_capacity(indice)= capacities(Index_cccv(1,indice))+capacities(Index_cccv(1,indice)+1);
    
    cccv_duration(indice)=durations(Index_cccv(1,indice))+durations(Index_cccv(1,indice)+1);
    cccv_crate(indice)=crates(Index_cccv(1,indice));
end


%Calculate and store the ratio of (dis)charged Ah and duration in CC and CV phases
%over (dis)charged Ah and duration during the CC-CV phases
    
for indice=1:length(Index_cccv)

    ah_cc_in_cccv(indice)=capacities(Index_cccv(1,indice));
    ah_cv_in_cccv(indice)=capacities(Index_cccv(1,indice)+1);
      
    
    duration_cc_in_cccv(indice)= durations(Index_cccv(1,indice));
    duration_cv_in_cccv(indice)= durations(Index_cccv(1,indice)+1);  
end

% 
% cccv_ratio_cc_ah=[ah_cc_in_cccv; ah_cv_in_cccv]';
% cccv_ratio_cc_duration=[duration_cc_in_cccv; duration_cv_in_cccv]';

cccv_ratio_cc_ah=ah_cc_in_cccv./cccv_capacity;
cccv_ratio_cc_duration=duration_cc_in_cccv./cccv_duration;

end
