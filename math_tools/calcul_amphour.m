function Q = calcul_amphour(t,I)
%calcul_amphour calculation of amp-hours by current integration
% Q = calcul_amphour(t,I)
%
% INPUTS: 
% t ([nx1] double): time in seconds
% I ([nx1] double): current in amps
% OUTPUT:
% Q ([nx1] double): amp-hours
%
% See also calcul_soc

if iscell(t)
    fprintf('essaye: Q = cellfun(@calcul_amphour,t,I,''UniformOutput'' , false\n');
    error('il faut mettre a jour le typage, vecteurs au lieu de cellules');
end
if ~isequal(size(t),size(I))
    error('taille de vecteurs incompatible')
end
if isempty(t)
    Q = [];return;
end
if length(t)==1
    Q = 0;return;
end
    Q = cumtrapz(t,I)/3600;     %integration numerique du type trapeizoidal du courant par rapport au temps
end