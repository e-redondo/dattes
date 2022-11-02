function [info, err] = check_phases_struct(phases)
% check_phases_struct - Check phases structure
%
% Usage: [info, err] = check_phases_struct(phases)
%
% err = 0: phases structure OK
% err = -1: error in mandatory fields
% err = -2: error in field types
% err = -3: error in allowed fields
% err = -9: phases not a structure
%
% See also check_struct, check_result_struct

err = 0;
info = struct;
% TODO
end