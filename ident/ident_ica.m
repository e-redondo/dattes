function [ica] = ident_ica(t,U,DoDAh,config,phases,options)
%ident_ICA interface entre RPT et essaiICA
% See also RPT, essaiICA, configurator2
if ~exist('options','var')
    options = '';
end

%TODO check inputs
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
    [tp,Up,DoDAhp] = get_phase(phasesICA(ind),t,U,DoDAh);
    
    [ica(ind).dqdu, ica(ind).dudq, ica(ind).q, ica(ind).u] = calcul_ica(tp,DoDAhp,Up,N,wn,f_type);
    ica(ind).crate = phasesICA(ind).Iavg/config.Capa;
    ica(ind).time = phasesICA(ind).t_fin;
end

end