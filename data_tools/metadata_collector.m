function [metadata, meta_list,errors] = metadata_collector(filename,max_depth)
% metadata_collector Collects metadata in folder tree
%
% Usage:
% metadata = metadata_collector(filename)
%
% Input:
% - filename [1xp string] pathname of a test file
% - max_depth [1x1 double] max folder depth (default 8)
% Output:
% - metadata [1x1 struct] collected metadata
%
% See also csv2profiles
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

if ~exist('max_depth','var')
    max_depth = 8;
end
%% 1.Search, select and sort .meta files in folder tree:
%get folder:
D = cell(max_depth,1);
D{1} = fileparts(filename);
for ind = 2:max_depth
D{ind} = fileparts(D{ind-1});
end
meta_list =  cellfun(@(x) lsFiles(x,'.meta',true),D,'UniformOutput',false);
meta_list = vertcat(meta_list{:});

%remove extensions
meta_filenames = regexprep(meta_list,'.meta$','');
% filter meta_files in right 'branch', that is:
ind_filter = cellfun(@(x) ~isempty(regexp(filename,x)),meta_filenames);
meta_list = meta_list(ind_filter);
%sort by length (folder depth):
meta_path_lengths = cellfun(@length,meta_list);
[~,ind_sort] = sort(meta_path_lengths);
meta_list = meta_list(ind_sort);


metadata = struct;
errors = zeros(size(meta_list));
for ind = 1:length(meta_list)
    this_meta = meta_list{ind};
    if exist(this_meta,'file')
        try
            fid = fopen(this_meta);
            json_txt = fread(fid,inf, 'uint8=>char')';
            fclose(fid);
            this_metadata = jsondecode(json_txt);
        catch e
            errors(ind) = -1;
            this_metadata = struct;
        end
        fieldlist = fieldnames(this_metadata);
        for ind_f = 1:length(fieldlist)
            %second level
            fieldlist2 = fieldnames(this_metadata.(fieldlist{ind_f}));
            for ind_f2 = 1:length(fieldlist2)
                metadata.(fieldlist{ind_f}).(fieldlist2{ind_f2}) = ...
                    this_metadata.(fieldlist{ind_f}).(fieldlist2{ind_f2});
            end
        end
    end
end
end