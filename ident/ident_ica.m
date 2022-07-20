function [ica] = ident_ica(t,U,dod_ah,config,phases,options)
% ident_ica incremental capacity analysis
%
% [ica] = ident_ica(t,U,dod_ah,config,phases,options)
% Read the config and phases structure and performe several calculations
% regarding incremental capacity analysis.  Results are returned in the structure incremental capacity analysis 
%
% Usage:
% [ica] = ident_ica(t,U,dod_ah,config,phases,options)
% Inputs:
% - t [nx1 double]: time in seconds
% - U [nx1 double]: cell voltage in V
% - dod_ah [nx1 double]: depth of discharge in AmpHours
% - config [1x1 struct]: config struct from configurator
% - phases [1x1 struct]: phases struct from decompose_phases
% - options [string] containing:
%   - 'v': verbose, tell what you do
%   - 'g' : show figures
%
% Output:
% - ica [mx1 struct] with fields:
%   - dqdu [px1 double]: voltage derivative of capacity
%   - dudq [px1 double]: capacity derivative of voltage
%   - q [px1 double]: capacity vector for dudq
%   - u [px1 double]: voltage vector for dqdu
%   - crate [1x1 double]: charge or discharge C-rate
%   - time [1x1 double]: time of measurement
%
% See also dattes, calcul_ica, configurator
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

if ~exist('options','var')
    options = '';
end
ica = struct([]);

%% check inputs:
if nargin<5 || nargin>6
    fprintf('ident_ica : wrong number of parameters, found %d\n',nargin);
    return;
end

if ~isstruct(config) || ~isstruct(phases) || ~ischar(options) || ~isnumeric(t) ...
        || ~isnumeric(U) ||  ~isnumeric(dod_ah)
    fprintf('ident_ica: wrong type of parameters\n');
    return;
end

if ~isfield(config,'ica')
    fprintf('ident_ica: incomplete structure config, redo configurator: dattes(''cs'')\n');
    return;
end

if ~isfield(config.ica,'pICA') || ~isfield(config.ica,'filter_order') || ~isfield(config.ica,'filter_cut') || ~isfield(config.ica,'filter_type')
    fprintf('ident_ica: incomplete structure config, redo configurator: dattes(''cs'')\n');
    return;
end


%both charge and discharge phases:
phases_ica = phases(config.ica.pICA);

%filter parameters:
N = config.ica.filter_order;%30
wn = config.ica.filter_cut;%0.1
f_type = config.ica.filter_type;%'G'

for ind = 1:length(phases_ica)
    [tp,Up,dod_ah_phase] = extract_phase(phases_ica(ind),t,U,dod_ah);
    
    [ica(ind).dqdu, ica(ind).dudq, ica(ind).q, ica(ind).u] = calcul_ica(tp,dod_ah_phase,Up,N,wn,f_type);
    ica(ind).crate = phases_ica(ind).Iavg/config.test.capacity;
    ica(ind).time = phases_ica(ind).t_fin;
end

end
