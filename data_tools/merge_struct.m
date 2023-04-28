function S = merge_struct(S1,S2)
%merge_struct - merge fields of structures.
%
% Output structure is the result of overwritting fields of S1 with fields
% of S2. Non existing fields in S2 mean keeping S1 values. S1 and S2 must
% have same size. Substructures are recursively merged.
%
% Usage: S = merge_struct(S1,S2)
% Inputs:
%  - S1: [mxn struct] input struct
%  - S2: [mxn struct] input struct
% Output:
%  - S: [mxn struct] output struct
%
% See also str2func_struct
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab:
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.
if ~isequal(size(S1),size(S2))
    fprintf('ERROR, input structure must be of equal size\n');
    return
end

fieldList2 = fieldnames(S2);
for ind = 1:length(S1)
    for ind2 = 1:length(fieldList2)
        if isstruct(S2(ind).(fieldList2{ind2}))
            S1(ind).(fieldList2{ind2}) = merge_struct(S1(ind).(fieldList2{ind2}),S2(ind).(fieldList2{ind2}));
        else
            S1(ind).(fieldList2{ind2}) = S2(ind).(fieldList2{ind2});
        end
    end
end

S = S1;

end