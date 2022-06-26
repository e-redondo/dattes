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
%     - cc_time (1xk) double: time of each CC capacity measurement
%     - cc_duration (1xj) double: duration of each CC phase
%     - cv_capacity (1xj) double: residual capacity of each CV phase
%     - cv_voltage (1xj) double: voltage of each CV phase
%     - cv_time (1xj) double: time of each CV phase
%     - cv_duration (1xj) double: duration of each CV phase
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
cc_capacity = [];
cc_crate = [];

cc_cv_capacity=[];
cc_cv_duration=[];
cc_cv_time=[];

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
cv_time = [phases_cv.t_ini];
cv_duration = [phases_cv.duration];

%CC+CV

%Look for cc capacity phases followed by cv capacity phases
phases_cc_cv=config.capacity.pCapaC |config.capacity.pCapaCV| config.capacity.pCapaD  | config.capacity.pCapaDV ;
sequence=[1 1];

%Store position of cc phases which are followed by cv phases
Index_cc_cv=strfind(phases_cc_cv, sequence);

%Calculate full capacity at these positions 
capacities=[phases.capacity];
durations=[phases.duration];
times=[phases.t_fin];

ah_cc_in_cc_cv=[];
ah_cv_in_cc_cv=[];

duration_cc_in_cc_cv=[];
duration_cv_in_cc_cv=[];

for indice=1:length(Index_cc_cv)
    cc_cv_time=[cc_cv_time times(Index_cc_cv(1,indice))];
    cc_cv_capacity=[cc_cv_capacity capacities(Index_cc_cv(1,indice))+capacities(Index_cc_cv(1,indice)+1)];
    
    cc_cv_duration=[cc_cv_duration durations(Index_cc_cv(1,indice))+durations(Index_cc_cv(1,indice)+1)];


    ah_cc_in_cc_cv=[ah_cc_in_cc_cv capacities(Index_cc_cv(1,indice))];
    ah_cv_in_cc_cv=[ah_cv_in_cc_cv capacities(Index_cc_cv(1,indice)+1)];
    
    
    
    duration_cc_in_cc_cv=[duration_cc_in_cc_cv durations(Index_cc_cv(1,indice))];
    duration_cv_in_cc_cv=[duration_cv_in_cc_cv durations(Index_cc_cv(1,indice)+1)];  
end

ratio_ah=[];
ratio_duration=[];

for indice_k=1:length(ah_cc_in_cc_cv)
    ratio_ah=[ratio_ah ; ah_cc_in_cc_cv(indice_k) ah_cv_in_cc_cv(indice_k) ];
    ratio_duration=[ratio_duration ; duration_cc_in_cc_cv(indice_k) duration_cv_in_cc_cv(indice_k)];
end   
    
%     bar(ratio_ah,'stacked')
%     title('Ratio Ah in CC and CV')
%     legend('CC Ah','CV Ah')
%     ylabel('Capacity (Ah)')
%     
%     
%     figure
%     
%     bar(ratio_duration/60,'stacked')
%         title('Ratio duration in CC and CV')
%     legend('CC duration','CV duration')
%     ylabel('Duration (mn)')
    
%put into output structure:
capacity(1).cc_capacity = cc_capacity;
capacity.cc_crate = cc_crate;
capacity.cc_time = cc_time;
capacity.cc_duration = cc_duration;
capacity.cv_capacity = cv_capacity;
capacity.cv_voltage = cv_voltage;
capacity.cv_time = cv_time;
capacity.cv_duration = cv_duration;

capacity.cc_cv_time=cc_cv_time;
capacity.cc_cv_capacity=cc_cv_capacity;
capacity.cc_cv_duration=cc_cv_duration;

capacity.ratio_ah=ratio_ah;
capacity.ratio_duration=ratio_duration;


if ismember('v',options)
    fprintf('OK\n');
end
end
