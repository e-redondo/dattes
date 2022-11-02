function [info, err] = check_struct(input_struct, allowed_fields, field_types, mandatory_fields)
% check_struct - Generic struct check
%
% Usage: [info, err] = check_struct(input_struct, allowed_fields, field_types, mandatory_fields)
%
% info [struct]:
%  - allowed_fields [1xm logical]: false = field is not in struct
%  - field_types [1xm logical]: false = type is wrong
%  - mandatory_fields [1xn logical]: false = field is missing
%  - not_allowed_fields [1xn cell str]: list of fields in input_struct not
%  in allowed_fields
%
% err = 0 % All OK
% err = -1 % missing one or more mandatory fields
% err = -2 % wrong type of one or more fields
% err = -3 % one or more not allowed fields
%
% See also check_result_struct, check_profiles_struct, check_eis_struct, check_phases_struct,
% check_metadata_struct, check_test_struct

input_fieldlist = fieldnames(input_struct)';
% input_types = cellfun(@(x) class(input_struct.(x)),input_fieldlist, 'UniformOutput',false);


info.allowed_fields = cellfun(@(x) isfield(input_struct,x),allowed_fields);
info.field_types = true(size(field_types));
for ind = 1:length(field_types)
    if isfield(input_struct,allowed_fields{ind})
        info.field_types(ind) = strcmp(class(input_struct.(allowed_fields{ind})),field_types{ind});
    end
end
info.mandatory_fields = cellfun(@(x) isfield(input_struct,x),mandatory_fields);

ind_naf = cellfun(@(x) ~ismember(x,allowed_fields),input_fieldlist);
info.not_allowed_fields = input_fieldlist(ind_naf);

%error codes:
if ~all(info.mandatory_fields)
    err = -1;
elseif ~all(info.field_types)
    err = -2;
elseif ~isempty(info.not_allowed_fields)
    err = -3;
else
    err = 0;
end
end