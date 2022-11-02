function [info, err] = check_metadata_struct(metadata)
% check_metadata_struct - Check metadata structure
%
% Usage: [info, err] = check_metadata_struct(metadata)
%
% err = 0: metadata structure OK
% err = -1: error in mandatory fields
% err = -2: error in field types
% err = -3: error in allowed fields
% err = -9: metadata not a structure
% err = -11: metadata.test error in mandatory fields
% err = -12: metadata.test error in field types
% err = -13: metadata.test error in allowed fields
% err = -xz: metadata.(xth section) error code z (see check_struct)
%
% See also check_struct, check_result_struct

err = 0;
info = struct;
% TODO
end