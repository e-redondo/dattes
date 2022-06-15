% put here a valid path with xml files:
% srcdir = 'path_to_test_files';
% each path containing xml files must contain a cfg_file M-file
if ~exist('srcdir','var')
    fprintf('please indicate a valid pathname to search xml files\n');
    return
end

if ~exist(srcdir,'dir')
    fprintf('please indicate a valid pathname to search xml files\n');
    return
end

%1. Find xml files in srcdir:
xml_list = lsFiles(srcdir,'.xml');

%2. filtering criteria:
filter_strs_must_be = {'BAROM','ELLISUP'};%include all files containing this
filter_strs_must_be = {'BAROM'};%include all files containing this
filter_strs_do_not_must_be = {};%exclude this folders because big files

%3. filter the folder_list
xml_list = cellfun(@(x) regexpFiltre(xml_list,x),filter_strs_must_be, 'UniformOutput',false);
xml_list = unique(vertcat(xml_list{:}));


for ind = 1:length(filter_strs_do_not_must_be)
    [~, xml_list] = regexpFiltre(xml_list,filter_strs_do_not_must_be{ind});
end

%4. make dattes(xml_list,'SCRZ') on each folder:
import_errors = 0;
wrote_files = 0;


% DEBUG
% xml_list = xml_list(1);

success = logical([]);
for ind =  1:length(xml_list)
    this_file = xml_list{ind};
    fprintf('\ndattes on file %s...\n',this_file);
%     try
        m_file = lsFiles(fileparts(this_file),'.m');
        if length(m_file)==1 %reconfigure
            [D,F,E] = fileparts(m_file{1});
            addpath(D);
            r = dattes(this_file,'cSCROZs',F);
            rmpath(D);
        end
        if ~exist(result_filename(r.test.file_in),'file')
            success(end+1) = false;
            ME = MException('dattes:no mat file created','error in dattes');
        else
            success(end+1) = true;
            wrote_files = wrote_files+1;
        end
%     catch e
%         fprintf('\n%s FAILED\n',this_file);
%         import_errors = import_errors+1;
%     end

end

%7. final report:
fprintf('\n\ntest_soc_capacity_resistance_impedance results:\n');
fprintf('Found xml files: %d\n',length(xml_list));
fprintf('Created/modified mat files: %d\n',wrote_files);
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


