% put here a valid path with xml files:
% srcdir = 'path_to_test_files';
% each path contianing xml files must contain a cfg_file M-file
if ~exist('srcdir','var')
    fprintf('please indicate a valid pathname to search xml files\n');
    return
end

if ~exist(srcdir,'dir')
    fprintf('please indicate a valid pathname to search xml files\n');
    return
end

%1. Find subfolders of srcdir:
folder_list = lsDirs(srcdir);

%2. filtering criteria:
filter_strs_must_be = {'BAROM','ICA','ELLISUP'};%include all folders containing this
filter_strs_must_be = {'ELLISUP'};%include all folders containing this
filter_strs_do_not_must_be = {};%exclude this folders because big files

%3. filter the folder_list
folder_lists = cellfun(@(x) regexpFiltre(folder_list,x),filter_strs_must_be, 'UniformOutput',false);
folder_list = unique(vertcat(folder_lists{:}));


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


%5. remove precedingly created mat in those folders:
delete_errors = 0;
deleted_files = 0;
mat_list = cell(0);
for ind = 1:length(folder_list)
    this_folder = folder_list{ind};
    mat_list1 = lsFiles(folder_list{ind},'.mat');%mat_list for this folders
    mat_list = [mat_list(:); mat_list1(:)];%mat_list for all folders
    fprintf('mat files in folder %s...',this_folder);
    try
        cellfun(@delete,mat_list1);
        fprintf(' deleted %d mat files\n',length(mat_list1));
        deleted_files = deleted_files+length(mat_list1);
    catch e
        fprintf('\n%s FAILED\n',this_folder);
        delete_errors = delete_errors+1;
    end
end

%6. make dattes(xml_list,'xsv') on each folder:
import_errors = 0;
wrote_files = 0;

xml_list = cell(0);
success = logical([]);
for ind =  1:length(folder_list)
    this_folder = folder_list{ind};
    fprintf('\ndattes on folder %s...\n',this_folder);
    xml_list1 = lsFiles(this_folder,'.xml');%xml_list for this folder
    %search cfg_file for each xml
    m_list = cellfun(@(x) lsFiles(fileparts(x),'.m'),xml_list1,'UniformOutput',false);
    
    %remove empty M-files (cfg_file not found)
    Is = ~cellfun(@isempty ,m_list);
    xml_list1 = xml_list1(Is);
    m_list = m_list(Is);
    %keep just first m file found in folder
    m_list = cellfun(@(x) x{1},m_list,'UniformOutput',false);
    
    xml_list = [xml_list(:); xml_list1(:)];%xml_list for all folders
    for ind2 = 1:length(xml_list1)
        %do one csv file to better manage wrote_files and import_errors
        %count
        try
            [D cfg_file E] = fileparts(m_list{ind2});
            
            addpath(D);%add path where cfg_file is
            [r,c,p] = dattes(xml_list1{ind2},'cvs',cfg_file);
            rmpath(D);%rm path where cfg_file is
            if ~exist(result_filename(r.test.file_in),'file')
                success(end+1) = false;
                ME = MException('dattes:no mat file created','error in dattes');
            else
                success(end+1) = true;
                wrote_files = wrote_files+2;
            end
        catch e
            fprintf('\n%s FAILED\n',xml_list1{ind2});
            import_errors = import_errors+1;
        end
    end
end

%7. final report:
fprintf('\n\ntest_extract_decompose_configure results:\n');
fprintf('Found xml folders: %d\n',length(folder_list));
fprintf('Found mat files: %d\n',length(mat_list));
fprintf('Deleted mat files: %d\n',deleted_files);
fprintf('Deletion failures: %d\n',delete_errors);
fprintf('Created mat files: %d\n',wrote_files);
fprintf('mat file creation failures: %d\n',import_errors);

%8. full report (TODO)
if any(success)
fprintf('\n\nSuccesful files:\n');
cellfun(@(x) fprintf('%s\n',x),xml_list(success));
end
if any(~success)
    fprintf('\n\nFailed files:\n');
    cellfun(@(x) fprintf('%s\n',x),xml_list(~success));
end
if all(success) && ~isempty(success)
    fprintf('\nAll files successful.\n');
end
if all(~success) && ~isempty(success)
    fprintf('\nAll files failed.\n');
end

fprintf('END OF TEST\n');


