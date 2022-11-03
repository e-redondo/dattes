function export_result_json(dattes_struct, dst_folder, file_out)
% export_result_json export result from DATTES struct to json file
%
% 
% Usage:
% export_result_json(dattes_struct, options, dst_folder, file_out)
%
% Input:
% - dattes_struct [1x1 struct] DATTES result structure
% - dst_folder [1xp string]: (optional) 
% - file_out [1xp string]: (optional) 
%
%
% See also dattes_export
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

%check fileout name
if isempty(file_out)
    file_suffix = 'dattes';
    file_ext = '.json';
    file_out = result_filename(dattes_struct.test.file_out, dst_folder,file_suffix, file_ext);
end
write_json_struct(file_out, dattes_struct);

end
