function export_metadata_script(dattes_struct, file_out)
% export_metadata_script export metadata from DATTES struct to json file
%
% 
% Usage:
% export_metadata_script(dattes_struct, file_out)
%
% Input:
% - dattes_struct [1x1 struct] DATTES result structure
% - file_out [1xp string]: (optional) 
%
%
% See also dattes_export, export_metadata_script
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

%0. check inputs
%check dattes_struct
if ~isfield(dattes_struct,'metadata')
     fprintf('ERROR export_metadata_script:No metadata found in DATTES struct\n');
     return
end

%check fileout name
if ~exist('fileout','var')
    file_suffix = '_dattes_metadata.m';
    file_out = regexprep(dattes_struct.test.file_in,'.[a-zA-Z0-9]*$',file_suffix);
end

write_metadata_script(file_out, dattes_struct.metadata);

end