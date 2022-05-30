function [result, config] = edit_result(result, config,Field,Values,options)
if ~exist('options','var')
    %par defaut juste charge les resultats precedents et les montre
    options='r';
end

%1.-modifier les resultats:
if ismember('r',options)
    result = setfieldArray(result,Field,Values);
end
%2bis modifier la config
if ismember('c',options)
    config = setfieldArray(config,Field,Values);
end

end

function S = setfieldArray(S,Field,Values)
%setfieldArray setfield of struct array
%
% S = setfieldArray(S,'field',V) sets the contents of the specified
%     field to the values V. S must be a m-by-n structure and V and m-by-n
%     array. This is equivalent to the following syntax:
% for ind = 1:length(S)
%   S(ind).('field') = V(ind);
% end
% The changed structure is returned.
%
% see also setfield, dattes
S = arrayfun(@(s,x) setfield(s,Field,x),S,Values);
end