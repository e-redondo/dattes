function [info, err] = check_test_struct(test)
% check_test_struct - Check test structure
%
% Usage: [info, err] = check_test_struct(test)
%
% err = 0: test structure OK
% err = -1: error in mandatory fields
% err = -2: error in field types
% err = -3: error in allowed fields
% err = -9: test not a structure
%
% See also check_struct, check_result_struct

err = 0;
info = struct;
% TODO
end