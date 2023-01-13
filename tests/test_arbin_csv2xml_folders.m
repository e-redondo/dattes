
% get a folder with Arbin CSV files
%srcdir = '/home/redondo/essais/DATTES_test_data/'

%1. list csv files in folder
csv_list = lsFiles(srcdir,'.csv');

%2. filtering criteria:
filter_strs_must_be = {'Arbin'};%include all folders containing this
filter_strs_do_not_must_be = {'caracini_testcomplet'};%exclude these folders

%3. filter the folder_list
for ind = 1:length(filter_strs_must_be)
    csv_list = regexpFiltre(csv_list,filter_strs_must_be{ind});
end

for ind = 1:length(filter_strs_do_not_must_be)
    [~, csv_list] = regexpFiltre(csv_list,filter_strs_do_not_must_be{ind});
end

%4. get folder names containing these csv files
csv_folders = cellfun(@fileparts,csv_list,'uniformoutput',false);
csv_folders = unique(csv_folders);

%5. launch arbin_csv2xml_files on selected folders
for ind = 1:length(csv_folders)
    arbin_csv2xml_folders(csv_folders{ind},'f');
end
