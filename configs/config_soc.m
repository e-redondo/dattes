function config = config_soc(t,I,U,m,config,options)
%config_soc configuration for DATTES calcul_soc
%
% Usage:
% config = config_soc(t,U,I,m,config,phases,options)
%
% Inputs:
% - t,U,I,m [(nx1) double] from profiles
% - config [(1x1) struct] containing minimal info (see cfg_default)
% - phases [(mx1) struct] from split_phases
% - options [(1xp) string] some options ('v', 'g').
%
% Outputs:
% config [(1x1) struct] with fields:
%     - t100: moments at SoC100 SOC calculation
%     - DoDAhIni: initial DoD in Amphours
%     - DoDAhFin: final DoD in Amphours
%
%
% See also dattes_import, calcul_soc, calcul_soc_patch, configurator

% check inputs:
%t,U,I,m: double vectors of same length
if ~isnumeric(t) || ~isnumeric(U) ||~isnumeric(I) ||~isnumeric(m)
    error('t,U,I,m must be numeric');
end
if ~isvector(t) || ~isvector(U) ||~isvector(I) ||~isvector(m)
   error('t,U,I,m must be vectors');
end
if length(t)<2 
   error('t must have at least to elements');
end
if length(t)~=length(U) ||  length(t)~=length(U) || length(t)~=length(U)
   error('t,U,I,m must have same length');
end
% config: 1x1 struct with fields:
if ~isstruct(config) || numel(config)~=1
    error('config must 1x1 struct');
end
if ~isfield(config,'test') || ~isfield(config,'resistance') || ...
        ~isfield(config,'impedance') || ~isfield(config,'ocv_points') || ...
        ~isfield(config,'pseudo_ocv') || ~isfield(config,'ica')
    error('not a valid config struct');
end
% phases: 1xp struct with fields:
% if ~isstruct(phases) || ~isvector(phases)
%     error('phases must 1xp struct');
% end
% if ~isfield(phases,'t_ini') || ~isfield(phases,'t_fin') || ...
%         ~isfield(phases,'duration') || ~isfield(phases,'Iavg') 
%     error('not a valid phases struct');
% end

if ~exist('options','var')
    options = '';
end

if ismember('v',options)
    fprintf('config_soc:...');
end

%1.-end of CC phases
Ifincc = m==1 & [m(2:end);0]~=1;
%2.-end of CV phases
Ifincv = m==2 & [m(2:end);0]~=2;

%moments under min voltage
Imin = U<=(config.test.min_voltage+0.02);
%moments beyond max voltage
Imax = U>=config.test.max_voltage-0.02;
%instants a SoC100 (ou presque I100cc: fin de charge CC)
I100cc = Ifincc & Imax;%ca marche pas pour LYP
C_rate = I/config.test.capacity;
Ic20 = C_rate<=config.soc.crate_cv_end*1.1; % typically C/20
% I100 = Ifincv & Imax;
I100 = (Ifincv & Imax) | (I100cc & Ic20);
%instants a SoC0 (ou presque I0cc: fin de decharge CC)
I0 = (Ifincv & Imin) | (I100cc & Ic20);

%calcul_soc
config.soc.soc100_time = t(I100);%pour le calcul du SOC
config.soc.soc0_time = t(I0);%pour le calcul du SOC
%Note: retourne matrice vide s'il ne trouve pas de phase CCCV a Umax.
%Dans ces cas il faut trouver le test immediatement anterieur (ou
%posterieur), calculer le DoDAh et fixer DoDAhIni ou DoDAhFin pour pouvoir
%faire calcul_soc
if ~isfield(config.soc,'dod_ah_ini')
    config.soc.dod_ah_ini = [];
end
if ~isfield(config.soc,'dod_ah_fin')
    config.soc.dod_ah_fin = [];
end


if ismember('v',options)
    fprintf('OK\n');
end

if ismember('g',options)
  % TODO (or not?)
end
end
