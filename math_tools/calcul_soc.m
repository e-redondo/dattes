function [DoDAh, SOC] = calcul_soc(t,I,config,options)
% calcul_soc calculation of SoC and depth of discharge in Amp-hour (DoDAh)
%
%[DoDAh, SOC] = calcul_soc(t,I,config,options)
%
% INPUTS
% - t(nx1 double): time in seconds
% - I(nx1 double): current in Amps
% - config(structure): from configurator
% - options (string):
%   - 'g' : graphics, show results
%   - 'v' : verbose, tell what you do
%
% OUTPUTS
% - DoDAh (nx1 double): discharge in Amp-hour
% - SOC (nx1 double): SOC [%]
%
% See also calcul_amphour
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.


if ~exist('options','var')
    options = '';
end
if ismember('v',options)
    fprintf('calcul_soc:...');
end
DoDAh = [];
SOC = [];
%gestion d'erreurs:
if nargin<3 || nargin>4
    fprintf('calcul_soc: wrong number of parameters, found %d\n',nargin);
    return;
end
if ~isstruct(config) || ~isnumeric(t) || ~isnumeric(I) || ~ischar(options)
    fprintf('calcul_soc: wrong type of parameters\n');
    return;
end
if ~isfield(config,'soc') || ~isfield(config,'test')
    fprintf('calcul_soc: incomplete structure config, redo configurator: dattes(''cs'')\n');
    return;
end
if ~isfield(config.soc,'soc100_time')
    fprintf('calcul_soc: incomplete structure config, redo configurator: dattes(''cs'')\n');
    return;
end
if ~isfield(config.test,'capacity')
    fprintf('calcul_soc: incomplete structure config, redo configurator: dattes(''cs'')\n');
    return;
end
Q = calcul_amphour(t,I); %calcul capacity
%Logical array indicate the instant where SoC reach 100%
I100 = ismember(t,config.soc.soc100_time);
    
if ~isempty(config.soc.soc100_time)
    
   
    for ind = 1:length(config.soc.soc100_time)
        Q(t>config.soc.soc100_time(ind)) = Q(t>config.soc.soc100_time(ind)) - Q(t==config.soc.soc100_time(ind));
    end

    Q(t<=config.soc.soc100_time(1)) = Q(t<=config.soc.soc100_time(1))-Q(t==config.soc.soc100_time(1));
else
    if ~isempty(config.soc.dod_ah_ini)
        Q = Q-Q(1)-config.soc.dod_ah_ini;
    elseif ~isempty(config.soc.dod_ah_fin)
        Q = Q-Q(end)-config.soc.dod_ah_fin;
    else
        if ismember('v',options)
            fprintf('calcul_soc: No SoC references, check config.Umin and config.Umax\n');
        end
        return;
    end
end
SOC = 100*(1+Q/config.test.capacity);
DoDAh = -Q;

if ismember('v',options)
    fprintf('OK\n');
end
if ismember('g',options)
        plot_soc(t, I, DoDAh, SOC, config,'','h');
end

end

