function export_configuration_json(dattes_struct, file_out)
% export_configuration_json export configuration from DATTES struct to json file
%
% 
% Usage:
% export_configuration_json(dattes_struct, file_out)
%
% Input:
% - dattes_struct [1x1 struct] DATTES result structure
% - file_out [1xp string]: (optional) 
%
%
% See also dattes_export, export_configuration_script
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

%0. check inputs
%check dattes_struct
if ~isfield(dattes_struct,'configuration')
     fprintf('ERROR export_configuration_json:No configuration found in DATTES struct\n');
     return
end

%check fileout name
if ~exist('fileout','var')
    file_suffix = '_dattes_configuration.json';
    file_out = regexprep(dattes_struct.test.file_in,'.[a-zA-Z0-9]*$',file_suffix);
end

struct_out.configuration = dattes_struct.configuration;
write_json_struct(file_out, struct_out);

end