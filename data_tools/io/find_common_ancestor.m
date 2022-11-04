function source_folder = find_common_ancestor(filelist)
% find_common_ancestor - Find common folder to all files in filelist
%
% Usage: source_folder = find_common_ancestor(filelist)
%
% - filelist [nx1 cellstring]: file list
% - source_folder [string]: common ancestor
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab:
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.


source_folders = unique(fileparts(filelist));
source_folders_parts = regexp(source_folders,['\' filesep],'split');
min_source_depth = min(cellfun(@length,source_folders_parts));
for ind = 1:min_source_depth
    first_elements = cellfun(@(x) x{1},source_folders_parts,'UniformOutput',false);
    if length(unique(first_elements))>1
        ind = ind-1;
        break;
    end
end
max_common_depth = ind;
source_folder = strjoin(source_folders_parts{1}(1:max_common_depth),filesep);

end