function [metadata, err] = metadata_json_import(filename)
% metadata_json_export import json file to metadata struct
%
% 
% Usage:
% err = metadata_json_export(filename, metadata)
%
% Input:
% - filename [1xp string] pathname for json file
%
% Output:
% - metadata [1x1 struct] metadata structure
% - err [1x1 double] error code (0 = no error)
%
% See also metadata_collector, metadata_json_export
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.


err = 0;
metadata = struct([]);
%0.- check inputs
if ~ischar(filename)
    err = -1;
    fprintf('ERROR in metadata_json_export: filename must be string\n')
    return
end
if ~isstruct(metadata)
    err = -1;
    fprintf('ERROR in metadata_json_export: metadata must be struct\n')
    return
end
%1.- read file
fid = fopen(filename,'r');
if fid<0
    err = -2;
    fprintf('ERROR in metadata_json_export: invalid filename or no write permission\n')
    return
end

json_txt = fread(fid,inf, 'uint8=>char')';
fclose(fid);

%2.- jsondecode
metadata = jsondecode(json_txt);

end