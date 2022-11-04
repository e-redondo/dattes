function struct_out = func2str_struct(struct_in)
% func2str_struct - convert function handles into strings
%
% Input structure is recursively explored. Every function handles
% will be converted to string starting with '@'.
%
% Usage: struct_out = func2str_struct(struct_in)
% Inputs:
%  - struct_in: [1x1 struct] input struct
% Output:
%  - struct_out: [1x1 struct] output struct
%
% See also str2func_struct
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab:
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

fieldlist = fieldnames(struct_in);

if isempty(fieldlist)
    %struct with no fields
    struct_out = struct_in;
    return
end

for ind = 1:length(struct_in)
    for ind_f = 1:length(fieldlist)
        field = struct_in(ind).(fieldlist{ind_f});
        if isstruct(field)
            field = func2str_struct(field);
        elseif isa(field,'function_handle')
            field = ['@' func2str(field)];
        end
        struct_out(ind).(fieldlist{ind_f}) = field;
    end
end
end