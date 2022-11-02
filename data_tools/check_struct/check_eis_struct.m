function [info, err] = check_eis_struct(eis)
% check_eis_struct - Check test structure
%
% Usage: [info, err] = check_eis_struct(eis)
%
% err = 0: eis structure OK
% err = -1: error in mandatory fields
% err = -2: error in field types
% err = -3: error in allowed fields
% err = -9: eis not a structure
%
% See also check_struct, check_result_struct


err = 0;
info = struct;
% TODO
end