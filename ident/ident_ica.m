function [ICAC, ICAD] = ident_ica(t,U,DoDAh,m,config,phases,options)
%ident_ICA interface entre RPT et essaiICA
% See also RPT, essaiICA, configurator2
if ~exist('options','var')
    options = '';
end

%TODO check inputs
phasesICAC = phases(config.pICAC);
phasesICAD = phases(config.pICAD);


%charge
ICAC = struct;
for ind = 1:length(phasesICAC)
    [tp,Up,DoDAhp] = get_phase(phasesICAC(ind),t,U,DoDAh);
    
    [xi,yi,yf,dydx] = calcul_ica(DoDAhp,Up,config.Capa/100,30,5,'Gg');
    [ICAC(ind).dQdU, ICAC(ind).dUdQ, ICAC(ind).Q, ICAC(ind).U] = essaiICA(tp,DoDAhp,Up,config,options);
end
%decharge
ICAD = struct;
for ind = 1:length(phasesICAD)
    [tp,Up,DoDAhp] = get_phase(phasesICAD(ind),t,U,DoDAh);
    
    [ICAD(ind).dQdU, ICAD(ind).dUdQ, ICAD(ind).Q, ICAD(ind).U] = essaiICA(tp,DoDAhp,Up,config,options);
end

end