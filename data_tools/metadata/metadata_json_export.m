function err = metadata_json_export(filename, metadata)
% metadata_json_export export metadata struct to json file
%
% 
% Usage:
% err = metadata_json_export(filename, metadata)
%
% Input:
% - filename [1xp string] pathname for json file
% - metadata [1x1 struct] metadata structure
%
% Output:
% - err [1x1 double] error code (0 = no error)
%
% See also metadata_collector
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.


err = 0;

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
%1.- jsonencode
jsontxt = jsonencode(metadata,'PrettyPrint',true);
%2.- write file
fid = fopen(filename,'w+');
if fid<0
    err = -2;
    fprintf('ERROR in metadata_json_export: invalid filename or no write permission\n')
    return
end

fprintf(fid,'%s',jsontxt);
fclose(fid);

end