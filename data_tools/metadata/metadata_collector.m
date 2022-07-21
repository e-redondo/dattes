function [metadata, meta_list,errors] = metadata_collector(filename,max_depth)
% metadata_collector Collects metadata in folder tree
%
% Each .meta file placed beside a folder with same name applies to all test
% files in this folder. Each .meta file placed beside a test file apply to
% this test file. E.g.:
% ├── [drwx------]  inr18650
% │   ├── [drwx------]  checkup_tests
% │   │   ├── [drwx------]  cell1
% │   │   │   ├── [-rwx------]  20190102_1230_initial_checkup.csv
% │   │   │   ├── [-rwx------]  20190102_1230_initial_checkup.meta
% │   │   │   ├── [-rwx------]  20190202_1230_intermediary.csv
% │   │   │   ├── [-rwx------]  20190202_1230_intermediary.meta
% │   │   │   ├── [-rwx------]  20190302_1230_intermediary.csv
% │   │   │   ├── [-rwx------]  20190302_1230_intermediary.meta
% │   │   │   ├── [-rwx------]  20190402_1230_final.csv
% │   │   │   └── [-rwx------]  20190402_1230_final.meta
% │   │   ├── [-rwx------]  cell1.meta
% │   │   ├── [drwx------]  cell2
% │   │   ├── [-rwx------]  cell2.meta
% │   │   ├── [drwx------]  cell3
% │   │   └── [-rwx------]  cell3.meta
% │   ├── [-rwx------]  checkup_tests.meta
%
% In example above, checkup_tests.meta applies to all files under
% checkup_tests folder, then cell1.meta, cell2.meta, cell3.meta apply
% respectively to files under cell1, cell2, cell3 subfolders. Thas is,
% existing fields in preceding metadata will be overwritten by these ones.
% Finally, 20190102_1230_initial_checkup.meta applies only to csv file with
% same name.
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
            [this_metadata, err] = metadata_json_import(this_meta);
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