function [eis] = ident_eis(eis_measure,options)

%circuit
%TODO in future releases allow different topologies
% circuit = 'rrc';
% circuit = 'rrcq';
% circuit = 'rrcrq';
% circuit = 'randles';

%for each EIS measurement
for ind = 1:length(eis_measure)
    %TODO: convention: ImZ<0 = inductive (-ImZ) fix this in dattes_structure
    Zmeas = eis_measure(ind).ReZ-eis_measure(ind).ImZ*1i;
    f = eis_measure(ind).f;

    Zparams = calcul_eis(Zmeas,f);
    Zsim = circuit_rrcq(Zparams,f);

    %compile results
    eis(ind).Zparams = Zparams;
    eis(ind).Zsim = Zsim;
    eis(ind).Zmeas = Zmeas;
    eis(ind).f = f;
    eis(ind).topology = 'rrcq';
    eis(ind).datetime = eis_measure(ind).datetime;
    eis(ind).soc = eis_measure(ind).soc;
    eis(ind).dod_ah = eis_measure(ind).dod_ah;

end

end
