function export_result_json(dattes_struct, file_out)
% export_result_json export result from DATTES struct to json file
%
% 
% Usage:
% export_result_json(dattes_struct, options, file_out)
%
% Input:
% - dattes_struct [1x1 struct] DATTES result structure
% - file_out [1xp string]: (optional) 
%
%
% See also dattes_export
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

%0. check inputs

%check fileout name
if ~exist('fileout','var')
    file_suffix = '_dattes.json';
    file_out = regexprep(dattes_struct.test.file_in,'.[a-zA-Z0-9]*$',file_suffix);
end

write_json_struct(file_out, dattes_struct);

end
