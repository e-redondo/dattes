function [info, err] = check_result_struct(result)
% check_result_struct - Check result structure
%
% Usage: err = check_result_struct(result)
%
% err = 0: result structure OK
% err = -1: result error in mandatory fields
% err = -2: result error in field types
% err = -3: result error in allowed fields
% err = -9: result is not struct
% err = -1xy: error in profiles, see check_profiles_struct
% err = -2xy: error in eis, see check_eis_struct
% err = -3xy: error in phases, see check_phases_struct
% err = -4xy: error in metadata, see check_metadata_struct
% err = -5xy: error in test, see check_test_struct
%   - 'x': first level
%   - 'y': second level
% Examples:
% err = -101 error in profiles mandatory fields
% err = -102 error in profiles field types
% err = -103 error in profiles allowed fields
% err = -401 error in metadata mandatory fields
% err = -402 error in metadata field types
% err = -403 error in metadata allowed fields
% err = -411 error in metadata.test mandatory fields
% err = -412 error in metadata.test field types
% err = -413 error in metadata.test allowed fields
% err = -421 error in metadata.cell mandatory fields
% err = -422 error in metadata.cell field types
% err = -423 error in metadata.cell allowed fields
% 
% General example:
% err = -z error at first level of result, error code z (see check_struct)
% err = -x0z error at 'x'th field of result, error code z (see check_struct) 
% err = -xyz error at 'y'th field of 'x'th field of result, error code z (see check_struct) 
%
% See also check_struct, check_profiles_struct, check_eis_struct, check_phases_struct,
% check_metadata_struct, check_test_struct

%% first level: result
err = 0;

if ~isstruct(result)
    info = struct;
    err = -4;
    return;
end
% checkstruct:
allowed_fields = {'profiles','eis','phases','metadata','test','configuration'};
mandatory_fields = {'profiles','phases','test'};
field_types = {'struct','struct','struct','struct','struct','struct'};

[info, err] = check_struct(result, allowed_fields, field_types, mandatory_fields);

if err<0
    return
end
%% second level result sections:
%profiles (mandatory)
if ~isfield(result,'profiles')
    %profiles is mandatory
    err=-100;
    return
end
[info_p, err_p] = check_profiles_struct(result.profiles);
if err_p
    err = err_p-100;
    return
end
info.info_profiles = info_p;

%eis (non mandatory)
if isfield(result,'eis')
    %eis is not mandatory
    [info_e, err_e] = check_eis_struct(result.eis);
    if err_e
        err = err_e-200;
        return
    end
    info.info_eis = info_e;
end

%phases (mandatory)
if ~isfield(result,'phases')
    %profiles is mandatory
    err=-300;
    return
end
[info_ph, err_ph] = check_phases_struct(result.phases);
if err_ph
    err = err_ph-300;
    return
end
info.info_phases = info_ph;

%metadata (not mandatory)
if isfield(result,'metadata')
    %eis is not mandatory
    [info_m, err_m] = check_metadata_struct(result.metadata);
    if err_m
        err = err_m-400;
        return
    end
    info.info_metadata = info_m;
end

%test (mandatory)
if ~isfield(result,'test')
    %profiles is mandatory
    err=-500;
    return
end
[info_t, err_t] = check_test_struct(result.test);
if err_t
    err = err_t-500;
    return
end
info.info_test = info_t;

%configuration (not mandatory)
if isfield(result,'configuration')
    %eis is not mandatory
    [info_c, err_c] = check_configuration_struct(result.configuration);
    if err_c
        err = err_c-600;
        return
    end
    info.info_configuration = info_c;
end







end