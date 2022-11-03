function struct_out = func2str_struct(struct_in)
%convert function handles to strings
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