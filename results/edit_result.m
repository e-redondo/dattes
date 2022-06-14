function [result, config] = edit_result(result, config,Field,Values,options)
%edit_result edit the result and/or config structure
%
% [result, config] = edit_result(result, config,Field,Values,options)
% edit the result and/or config structure of DATTES analysis
%
% Usage:
% [result, config] = edit_result(result, config,Field,Values,options)
% Inputs : 
% - result: [1x1 struct] structure containing analysis results to edit
% - config:  [1x1 struct] structure containing analysis config to edit
% - Field: [1x1 struct] Field to modify in the structure
% - Values [1x1 array] New value of the field
% - options [string] : 
%    - 'r' edit result structure
%    - 'c' edit config structure
% Outputs : 
% - result: [1x1 struct] Modified structure containing analysis results 
% - config:  [1x1 struct] Modified structure containing analysis config 
%
% See also dattes, load_result, edit_result
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.



if ~exist('options','var')
    %By default, just load the previous result and show them
    options='r';
end

%1.-Modify results:
if ismember('r',options)
    result = setfieldArray(result,Field,Values);
end
%2 Modify config
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