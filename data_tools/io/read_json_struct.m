function [struct_out, err] = read_json_struct(filename)
% read_json_struct import json file to struct
%
% 
% Usage:
% [struct_out, err] = read_json_struct(filename)
%
% Input:
% - filename [1xp string] pathname for json file
%
% Output:
% - struct_out [1x1 struct] structure
% - err [1x1 double] error code (0 = no error)
%
% See also write_json_struct
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.


err = 0;
struct_out = struct([]);
%0.- check inputs
if ~ischar(filename)
    err = -1;
    fprintf('ERROR in read_json_struct: filename must be string\n')
    return
end

%1.- read file
fid = fopen(filename,'r');
if fid<0
    err = -2;
    fprintf('ERROR in read_json_struct: invalid filename or no read permission\n')
    return
end

json_txt = fread(fid,inf, 'uint8=>char')';
fclose(fid);

%2.- jsondecode
struct_out = jsondecode(json_txt);

%3. convert function handle strings
struct_out = str2func_struct(struct_out);

end