function [Capa, Regime, UCV, dCV, CapaCV] = ident_capacity(config,phases,options)
%ident_capacity capacity identification
% [Capa, Regime, UCV, dCV, CapaCV] = ident_capacity(config,phases,options)
%
% INPUTS:
% t (mx1) time vector (seconds)
% U (mx1) voltage vector (Volts)
% phases (1xn) phases array structure from decompose_bench
% config (1x1) configuraiton structure from configurator
% options (string) containing:
%   - 'v': verbose, tell what you do
%
% OUTPUTS:
% Capa (1xk) double: CC capacity measurements
% Regime (1xk) double: C-Rate of each CC capacity measurement
% UCV (1xj) double: voltage of each CV phase
% dCV (1xj) double: duration of each CV phase
% CapaCV (1xj) double: reisdual capacity of each CV phase
%
% See also dattes, decompose_bench, configurator, plot_capacity

%TODO: 'g' option
%TODO: process separately charge and discharge phases
%TODO: restructure: Qccdis, Qcvdis, Qdis=Qccdis+Qcvdis, etc.
if ~exist('options','var')
    options='';
end
if ismember('v',options)
    fprintf('ident_capacity:...');
end
Capa = [];
Regime = [];
%gestion d'erreurs:
if nargin<2 || nargin>3
    fprintf('ident_capacity:nombre incorrect de parametres, trouves %d\n',nargin);
    return;
end
if ~isstruct(phases) || ~isstruct(config) || ~ischar(options)
    fprintf('ident_CapaCV:type de parametres, incorrect\n');
    return;
end
if ~isfield(config,'pCapaD') || ~isfield(config,'pCapaC') || ~isfield(config,'pCapaDV') || ~isfield(config,'pCapaCV')
    fprintf('ident_Capa2:structure config incomplete, refaire config: RPT(''cs'')\n');
    return;
end
if ~isfield(phases,'capacity') || ~isfield(phases,'duration') || ~isfield(phases,'Iavg') || ~isfield(phases,'Uavg')
    fprintf('ident_Capa2:structure phases incomplete, refaire decoupe: RPT(''ps'')\n');
    return;
end

%CC part
Capa = abs([phases(config.pCapaD | config.pCapaC).capacity]);
Regime = [phases(config.pCapaD | config.pCapaC).Iavg]./config.Capa;

%CV part
phasesCV = phases(config.pCapaDV | config.pCapaCV);
CapaCV = abs([phases(config.pCapaDV | config.pCapaCV).capacity]);
dCV = [phasesCV.duration];
UCV = [phasesCV.Uavg];
% for ind = 1:length(phasesCV)
%     [tp,Up] = get_phase(phasesCV(ind),t,U);
%     
%     UCV(ind) = mean(Up);%TODO en realite il fallait faire trapz(tp,Up)/range(tp);
% end

if ismember('v',options)
    fprintf('OK\n');
end
end