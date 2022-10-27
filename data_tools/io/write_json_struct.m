function err = write_json_struct(filename, struct_in)
% write_json_struct export struct to json file
%
% 
% Usage:
% err = write_json_struct(filename, struct_in)
%
% Input:
% - filename [1xp string] pathname for json file
% - struct_in [1x1 struct] input structure
%
% Output:
% - err [1x1 double] error code (0 = no error)
%
% See also read_json_struct
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.


err = 0;

%0.- check inputs
if ~ischar(filename)
    err = -1;
    fprintf('ERROR in write_json_struct: filename must be string\n')
    return
end
if ~isstruct(struct_in)
    err = -1;
    fprintf('ERROR in write_json_struct: metadata must be struct\n')
    return
end

%0.1 convert function handles into strings
struct_in = func2str_struct(struct_in);
%1.- jsonencode
jsontxt = jsonencode(struct_in,'PrettyPrint',true);
%2.- write file
fid = fopen(filename,'w+');
if fid<0
    err = -2;
    fprintf('ERROR in write_json_struct: invalid filename or no write permission\n')
    return
end

fprintf(fid,'%s',jsontxt);
fclose(fid);

end