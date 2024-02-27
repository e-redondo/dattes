function export_metadata_json(dattes_struct, options, dst_folder, file_out)
% export_metadata_json export metadata from DATTES struct to json file
%
% 
% Usage:
% export_metadata_json(dattes_struct, dst_folder, file_out)
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
if ~exist('options','var')
    options = '';%empty string = default = generate file_out
end
if ~exist('file_out','var')
    file_out = '';%empty string = default = generate file_out
end
if ~exist('dst_folder','var')
    dst_folder = '';%empty string = default = keep src_folder
end
%check dattes_struct
if ~isfield(dattes_struct,'metadata')
     fprintf('ERROR export_metadata_json:No metadata found in DATTES struct\n');
     return
end

if ismember('m',options)
    % metadata filename must have .meta extension
    % metadata pathname must be beside raw data (dattes_struct.test.file_out)
    [D,F,E] = fileparts(dattes_struct.test.file_in);
    file_out = fullfile(D,sprintf('%s.meta',F));
end
%check fileout name
if isempty(file_out)
    file_suffix = 'metadata';
    file_ext = '.json';
    file_out = result_filename(dattes_struct.test.file_out, dst_folder,file_suffix, file_ext);
end

metadata = dattes_struct.metadata;

if exist(file_out,'file')
    metadata0 =  read_json_struct(file_out);
    % merge new metadata with original, existing fields will be updated
    metadata = merge_struct(metadata0,metadata);
end

folder_out = fileparts(file_out);
[status, msg, msgID] = mkdir(folder_out);
write_json_struct(file_out, metadata);

end