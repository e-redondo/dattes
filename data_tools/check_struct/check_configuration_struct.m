function [info, err] = check_configuration_struct(configuration)
% check_configuration_struct - Check configuration structure
%
% Usage: [info, err] = check_configuration_struct(configuration)
%
% err = 0: configuration structure OK
% err = -1: error in mandatory fields
% err = -2: error in field types
% err = -3: error in allowed fields
% err = -9: configuration not a structure
% err = -11: configuration.test error in mandatory fields
% err = -12: configuration.test error in field types
% err = -13: configuration.test error in allowed fields
% err = -xz: configuration.(xth section) error code z (see check_struct)
%
% See also check_struct, check_result_struct

err = 0;
info = struct;
% TODO
end