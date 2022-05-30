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

%--------------------------------------------------------------------------
%       PRINCIPAL
%--------------------------------------------------------------------------
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
    fprintf('calcul_soc:nombre incorrect de parametres, trouves %d\n',nargin);
    return;
end
if ~isstruct(config) || ~isnumeric(t) || ~isnumeric(I) || ~ischar(options)
    fprintf('calcul_soc:type de parametres, incorrect\n');
    return;
end
if ~isfield(config,'soc') || ~isfield(config,'test')
    fprintf('calcul_soc:structure config incomplete\n');
    return;
end
if ~isfield(config.soc,'soc100_time')
    fprintf('calcul_soc:structure config incomplete\n');
    return;
end
if ~isfield(config.test,'capacity')
    fprintf('calcul_soc:structure config incomplete\n');
    return;
end
Q = calcul_amphour(t,I); %calcule Q
%vecteur logique qu'indique les instants au le SOC atteint 100%
I100 = ismember(t,config.soc.soc100_time);
    
if ~isempty(config.soc.soc100_time)
    
    %pour chaque instant a SoC100 on enleve les Ah des points d'apres, si on
    %est a SOC max on ne peut decharger plus que la capacite nominale de la
    %batterie
    for ind = 1:length(config.soc.soc100_time)
        Q(t>config.soc.soc100_time(ind)) = Q(t>config.soc.soc100_time(ind)) - Q(t==config.soc.soc100_time(ind));
    end
    %on enleve aussi les Ah des points d'avant le premier instant (SoC initial
    %inconnu)
    Q(t<=config.soc.soc100_time(1)) = Q(t<=config.soc.soc100_time(1))-Q(t==config.soc.soc100_time(1));
else
    if ~isempty(config.soc.dod_ah_ini)
        Q = Q-Q(1)-config.soc.dod_ah_ini;
    elseif ~isempty(config.soc.dod_ah_fin)
        Q = Q-Q(end)-config.soc.dod_ah_fin;
    else
        if ismember('v',options)
            fprintf('calcul_soc:impossible de trouver une reference de SoC\n');
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

