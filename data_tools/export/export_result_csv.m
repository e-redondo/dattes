function export_result_csv(dattes_struct, options, dst_folder, folder_out)
% export_result_csv export result from DATTES struct to json file
%
% Export every substructure of result into a csv file.
% result.profiles, results.eis, result.phases 
% Usage:
% export_result_csv(dattes_struct, options, dst_folder, file_out)
%
% Input:
% - dattes_struct [1x1 struct] DATTES result structure
% - options [1xp string]: (optional) not yet used
%   - 'm': include metadata in csv's header in json format commented lines (starting with '#')
% - dst_folder [1xp string]: (optional) 
% - file_out [1xp string]: (optional) 
%
%
% See also dattes_export, export_profiles_csv, export_eis_csv, export_phases_csv
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

%0. check inputs
if ~exist('folder_out','var')
    folder_out = '';%empty string = default = generate file_out
end
if ~exist('dst_folder','var')
    dst_folder = '';%empty string = default = keep src_folder
end

%check folder_out name
if isempty(folder_out)
    file_suffix = 'dattes';
    file_ext = '';
    folder_out = result_filename(dattes_struct.test.file_out, dst_folder,file_suffix, file_ext);
end
%mkdir
[status, msg, msgID] = mkdir(folder_out);


%export profiles
export_profiles_csv(dattes_struct, options, folder_out)
%export eis
export_eis_csv(dattes_struct, options, folder_out)
%export phases
export_phases_csv(dattes_struct, options, folder_out);

%export metadata
export_metadata_json(dattes_struct, options, folder_out);
%export configuration
export_configuration_json(dattes_struct, options, folder_out);

end
