% put here a valid path with arbin files:
% srcdir = 'path_to_test_files';
if ~exist(srcdir,'dir')
    fprintf('please indicate a valid pathname to search Arbin files\n');
    return
end

%1. Find subfolders of srcdir:
folder_list = lsDirs(srcdir);

%2. filtering criteria:
filter_strs_must_be = {'ARBIN'};
filter_strs_do_not_must_be = {};

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
        fprintf('FAILED',this_folder);
        delete_errors = delete_errors+1;
    end
end

%6 make arbin_xls2xml on each folder:
import_errors = 0;
wrote_files = 0;

xls_list = cell(0);
success = logical([]);
for ind =  1:length(folder_list)
    this_folder = folder_list{ind};
    fprintf('arbin_xls2xml on folder %s...',this_folder);
    xls_list1 = lsFiles(this_folder,'.xls');
    xlsx_list1 = lsFiles(this_folder,'.xlsx');
    xls_list1 = [xls_list1(:); xlsx_list1(:)];
    xls_list = [xls_list(:); xls_list1(:)];
    for ind2 = 1:length(xls_list1)
    %do one xls file to better manage wrote_files and import_errors count
        try
            xml_list2 = arbin_xls2xml(xls_list1(ind2));
            if isempty(xml_list2)
                success(end+1) = false;
                ME = MException('arbin_xls2xml:no xml file created','error in arbin_xls2xml');
            else
                success(end+1) = true;
                wrote_files = wrote_files+length(xml_list2);
            end
        catch e
            fprintf('FAILED',this_folder);
            import_errors = import_errors+1;
        end
    end
    
end
%7. short report:
fprintf('\n\ntest_import_arbin results:\n');
fprintf('Found arbin folders:%d\n',length(folder_list));
fprintf('Found xls files:%d\n',length(xls_list));
fprintf('Deleted xml files :%d\n',deleted_files);
fprintf('Deletion failures :%d\n',delete_errors);
fprintf('Created xml files (arbin_xls2xml) :%d\n',wrote_files);
fprintf('xml file creation failures (arbin_xls2xml) :%d\n',import_errors);

%8. full report (TODO)
if any(success)
fprintf('\n\nSuccesful files:\n');
cellfun(@(x) fprintf('%s\n',x),xls_list(success));
end
if any(~success)
    fprintf('\n\nFailed files:\n');
    cellfun(@(x) fprintf('%s\n',x),xls_list(~success));
else
    fprintf('\nAll files successful.\n');
end
if ~any(success)
    fprintf('\nAll files failed.\n');
end

fprintf('END OF TEST\n');
