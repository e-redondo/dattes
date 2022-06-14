function Q = calcul_amphour(t,I)
%calcul_amphour calculation of amp-hours by current integration
%
% Usage :
% Q = calcul_amphour(t,I)
% Inputs: 
% t ([nx1] double): time in seconds
% I ([nx1] double): current in amps
% Output:
% Q ([nx1] double): amp-hours
%
% See also calcul_soc
%
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

if iscell(t)
    fprintf('essaye: Q = cellfun(@calcul_amphour,t,I,''UniformOutput'' , false\n');
    error('calcul_amphour: il faut mettre a jour le typage, vecteurs au lieu de cellules');
end
if ~isequal(size(t),size(I))
    error('calcul_amphour: vectors size not compatible')
end
if isempty(t)
    Q = [];return;
end
if length(t)==1
    Q = 0;return;
end
    Q = cumtrapz(t,I)/3600;     %integration numerique du type trapeizoidal du courant par rapport au temps
end