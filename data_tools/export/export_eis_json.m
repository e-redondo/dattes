function export_eis_json(dattes_struct, options, dst_folder, file_out)
% export_eis_json export EIS from DATTES struct to json file
%
% 
% Usage:
% export_eis_json(dattes_struct, options, dst_folder, file_out)
%
% Input:
% - dattes_struct [1x1 struct] DATTES result structure
% - options [1xp string]: (optional)
%   - 'm': include metadata in header in json format commented lines (starting with '#')
% - dst_folder [1xp string]: (optional) 
% - file_out [1xp string]: (optional) 
%
%
% See also dattes_export, export_eis_csv
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
if ~isfield(dattes_struct,'eis')
     fprintf('ERROR export_eis_json:No EIS found in DATTES struct\n');
     return
end
%check options
if ~exist('options','var')
    options = '';%default: no metadata
end

%check fileout name
if isempty(file_out)
    file_suffix = 'eis';
    file_ext = '.json';
    file_out = result_filename(dattes_struct.test.file_out, dst_folder,file_suffix, file_ext);
end

%2. metadata option
if ismember('m',options') && isfield(dattes_struct,'metadata')
struct_out.metadata = dattes_struct.metadata;
end
struct_out.eis = dattes_struct.eis;
write_json_struct(file_out, struct_out);

end