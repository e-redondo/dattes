function [ica] = ident_ica(t,U,dod_ah,config,phases,options)
% ident_ICA incremental capacity analisys
% Usage:
% [ica] = ident_ica(t,U,dod_ah,config,phases,options)
%
% Inputs:
% - t [nx1 double]: time in seconds
% - U [nx1 double]: cell voltage
% - dod_ah [nx1 double]: depth of discharge in AmpHours
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

% phases_ica_charge = phases(config.pICAC);
% phases_ica_discharge = phases(config.pICAD);

%both charge and discharge phases:
phases_ica = phases(config.ica.pICA);
%charge
ica = struct([]);

%filter params:
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
