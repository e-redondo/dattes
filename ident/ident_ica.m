function [ica] = ident_ica(t,U,DoDAh,config,phases,options)
% ident_ICA incremental capacity analisys
% Usage:
% [ica] = ident_ica(t,U,DoDAh,config,phases,options)
%
% Inputs:
% - t [nx1 double]: time in seconds
% - U [nx1 double]: cell voltage
% - DoDAh [nx1 double]: depth of discharge in AmpHours
% - config [1x1 struct]: config struct from configurator
% - phases [1x1 struct]: phases struct from decompose_phases
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

if ~exist('options','var')
    options = '';
end

% phasesICAC = phases(config.pICAC);
% phasesICAD = phases(config.pICAD);

%both charge and discharge phases:
phasesICA = phases(config.pICAC | config.pICAD);
%charge
ica = struct;

%filter params:
N = config.n_filter;%30
wn = config.wn_filter;%0.1
f_type = config.filter_type;%'G'

for ind = 1:length(phasesICA)
    [tp,Up,DoDAhp] = extract_phase(phasesICA(ind),t,U,DoDAh);
    
    [ica(ind).dqdu, ica(ind).dudq, ica(ind).q, ica(ind).u] = calcul_ica(tp,DoDAhp,Up,N,wn,f_type);
    ica(ind).crate = phasesICA(ind).Iavg/config.test.capacity;
    ica(ind).time = phasesICA(ind).t_fin;
end

end