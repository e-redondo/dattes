function export_metadata_script(dattes_struct, options, dst_folder, file_out)
% export_metadata_script export metadata from DATTES struct to json file
%
% 
% Usage:
% export_metadata_script(dattes_struct, dst_folder, file_out)
%
% Input:
% - dattes_struct [1x1 struct] DATTES result structure
% - options [1xp string]: (optional) not yet used
% - dst_folder [1xp string]: (optional) 
% - file_out [1xp string]: (optional) 
%
%
% See also dattes_export, export_metadata_script
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

%0. check inputs
if ~exist('file_out','var')
    file_out = '';%empty string = default = generate file_out
end
if ~exist('dst_folder','var')
    dst_folder = '';%empty string = default = keep src_folder
end
%check dattes_struct
if ~isfield(dattes_struct,'metadata')
     fprintf('ERROR export_metadata_script:No metadata found in DATTES struct\n');
     return
end

%check fileout name
if isempty(file_out)
    file_preffix = 'metadata';
    file_suffix = '';
    file_ext = '.m';
    file_out = result_filename(dattes_struct.test.file_out, dst_folder,file_suffix, file_ext);
    [folder_out, file_out] = fileparts(file_out);
    file_out = fullfile(folder_out,[file_preffix file_out '.m']);
end

[status, msg, msgID] = mkdir(folder_out);
write_metadata_script(file_out, dattes_struct.metadata);

end