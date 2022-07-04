% put here a valid path with xml files:
% srcdir = 'path_to_test_files';
if ~exist('srcdir','var')
    fprintf('please indicate a valid pathname to search csv files\n');
    return
end

csv_list = lsFiles(srcdir,'.csv');

for ind= 1:length(csv_list)
    file_in = csv_list{ind};
    
    tic;xml(ind) = import_arbin_csv(file_in);toc;
end
