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
if ~isfield(config,'t100') || ~isfield(config,'test')
    fprintf('calcul_soc:structure config incomplete\n');
    return;
end
if ~isfield(config.test,'capacity')
    fprintf('calcul_soc:structure config incomplete\n');
    return;
end
Q = calcul_amphour(t,I); %calcule Q
%vecteur logique qu'indique les instants au le SOC atteint 100%
I100 = ismember(t,config.t100);
    
if ~isempty(config.t100)
    
    %pour chaque instant a SoC100 on enleve les Ah des points d'apres, si on
    %est a SOC max on ne peut decharger plus que la capacite nominale de la
    %batterie
    for ind = 1:length(config.t100)
        Q(t>config.t100(ind)) = Q(t>config.t100(ind)) - Q(t==config.t100(ind));
    end
    %on enleve aussi les Ah des points d'avant le premier instant (SoC initial
    %inconnu)
    Q(t<=config.t100(1)) = Q(t<=config.t100(1))-Q(t==config.t100(1));
else
    if ~isempty(config.DoDAhIni)
        Q = Q-Q(1)-config.DoDAhIni;
    elseif ~isempty(config.DoDAhFin)
        Q = Q-Q(end)-config.DoDAhFin;
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

