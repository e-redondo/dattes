% put here a valid path with bitrode files:
% srcdir = 'path_to_test_files';
if ~exist(srcdir,'dir')
    fprintf('please indicate a valid pathname to search Bitrode files\n');
    return
end

%1. Find subfolders of srcdir:
folder_list = lsDirs(srcdir);

%2. filtering criteria:
filter_strs_must_be = {'BITRODE'};%include all folders containing this
filter_strs_do_not_must_be = {'BAROM'};%exclude this folders because big files

%3. filter the folder_list
for ind = 1:length(filter_strs_must_be)
    folder_list = regexpFiltre(folder_list,filter_strs_must_be{ind});
end

for ind = 1:length(filter_strs_do_not_must_be)
    [~, folder_list] = regexpFiltre(folder_list,filter_strs_do_not_must_be{ind});
end

%4. eliminate subfolders
%4.1 cut pathnames into parts:
folder_list_parts = regexp(folder_list,filesep,'split');

%4.2
issubfolder = false(length(folder_list_parts),length(folder_list_parts)); %nxn logical matrix
for ind1 = 1:length(folder_list_parts)
    for ind2 = 1:length(folder_list_parts)
        if length(folder_list_parts{ind2})>length(folder_list_parts{ind1})
            min_length = length(folder_list_parts{ind1});
            issubfolder(ind1,ind2) = isequal(folder_list_parts{ind2}(1:min_length),folder_list_parts{ind1}(1:min_length));
        end
    end
end
%sum rows:
issubfolder = sum(issubfolder);

folder_list = folder_list(~issubfolder);


%5. remove precedingly created xmls in those folders:
delete_errors = 0;
deleted_files = 0;
for ind = 1:length(folder_list)
    this_folder = folder_list{ind};
    xml_list = lsFiles(folder_list{ind},'.xml');
    fprintf('deleting xml files in folder %s...',this_folder);
    try
        cellfun(@delete,xml_list);
        fprintf(' deleted %d xml files\n',length(xml_list));
        deleted_files = deleted_files+length(xml_list);
    catch e
        fprintf('\n%s FAILED\n',this_folder);
        delete_errors = delete_errors+1;
    end
end


%6. make bitrode_csv2xml on each folder:
import_errors = 0;
wrote_files = 0;

csv_list = cell(0);
success = logical([]);
for ind =  1:length(folder_list)
    this_folder = folder_list{ind};
    fprintf('bitrode_csv2xml on folder %s...',this_folder);
    
    csv_list1 = lsFiles(this_folder,'.csv');%csv_list for this folder
    
    %remove also all bitrode.log  files:
    log_list = lsFiles(this_folder,'.log');
    log_list = regexpFiltre(log_list,'bitrode.log$');
    cellfun(@delete,log_list);
    

    %write bitrode log on each folder containing csv files:
    D = unique(cellfun(@fileparts,csv_list1,'UniformOutput',false));
    cellfun(@(x) write_bitrode_log(x,'n'),D);
    csv_list = [csv_list(:); csv_list1(:)];%csv_list for all folders
    for ind2 = 1:length(csv_list1)
        %do one csv file to better manage wrote_files and import_errors
        %count
        try
            xml_list2 = bitrode_csv2xml(csv_list1(ind2));
            if isempty(xml_list2)
                success(end+1) = false;
                ME = MException('bitrode_csv2xml:no xml file created','error in bitrode_csv2xml');
            else
                success(end+1) = true;
                wrote_files = wrote_files+length(xml_list2);
            end
        catch e
            fprintf('\n%s FAILED\n',csv_list1{ind2});
            import_errors = import_errors+1;
        end
    end
end

%7. final report:
fprintf('\n\ntest_import_bitrode results:\n');
fprintf('Found bitrode folders: %d\n',length(folder_list));
fprintf('Found csv files: %d\n',length(csv_list));
fprintf('Deleted xml files: %d\n',deleted_files);
fprintf('Deletion failures: %d\n',delete_errors);
fprintf('Created xml files: %d\n',wrote_files);
fprintf('xml file creation failures: %d\n',import_errors);

%8. full report (TODO)
if any(success)
fprintf('\n\nSuccesful files:\n');
cellfun(@(x) fprintf('%s\n',x),csv_list(success));
end
if any(~success)
    fprintf('\n\nFailed files:\n');
    cellfun(@(x) fprintf('%s\n',x),csv_list(~success));
else
    fprintf('\nAll files successful.\n');
end
if ~any(success)
    fprintf('\nAll files failed.\n');
end

fprintf('END OF TEST\n');


