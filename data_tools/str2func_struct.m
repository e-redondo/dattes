function struct_out = str2func_struct(struct_in)
% str2func_struct - convert strings into function handles
%
% Input structure is recursively explored. Every string starting with '@'
% will be converted to function handle. 
%
% Usage: struct_out = str2func_struct(struct_in)
% Inputs:
%  - struct_in: [1x1 struct] input struct
% Output:
%  - struct_out: [1x1 struct] output struct
%
% See also func2str_struct
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab:
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

%convert strings to function handles
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
            field = str2func_struct(field);
        elseif ischar(field) && length(field)>1
            if field(1)=='@' && isvarname(field(2:end))
                field = str2func(field);
            end
        end
        struct_out(ind).(fieldlist{ind_f}) = field;
    end
end
end