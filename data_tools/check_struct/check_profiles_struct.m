function [info, err] = check_profiles_struct(profiles)
% check_profiles_struct - Check profiles structure
%
% Usage: [err, info] = check_profiles_struct(profiles)
%
% err = 0: profiles structure OK
% err = -1: error in mandatory fields
% err = -2: error in field types
% err = -3: error in allowed fields
% err = -9: profiles is not struct
%
% See also check_struct, check_result_struct

err = 0;

if ~isstruct(profiles)
    err = -4;
    return;
end
% checkstruct:
allowed_fields = {'datetime','t','U','I','mode','soc','dod_ah','T'};
mandatory_fields = {'datetime','t','U','I','mode'};
field_types = {'double','double','double','double','double','double','double','double'};

[info, err] = check_struct(profiles, allowed_fields, field_types, mandatory_fields);

end