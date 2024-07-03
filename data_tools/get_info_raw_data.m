function info_raw_data = get_info_raw_data(file_in, ext_list)



if ~exist('ext_list','var')
    ext_list = {};
end

if ~iscell(ext_list)
    info_raw_data = [];
    fprintf('dattes_info_raw_data: wrong inputs.\n');
    fprintf('ext_list must be a cell containing file extensions (char)\n');
    return
end
if any(~cellfun(@ischar,ext_list))
    info_raw_data = [];
    fprintf('dattes_info_raw_data: wrong inputs.\n');
    fprintf('ext_list must be a cell containing file extensions (char)\n');
    return
end

if ~ischar(file_in) && ~iscell(file_in)
    info_raw_data = [];
    fprintf('dattes_info_raw_data: wrong inputs\n');
    fprintf('input must be a pathname (folder or file) or a filelist.\n');
    return
end


if ischar(file_in)
    if isfolder(file_in)
        filelist = lsFiles(file_in,'*');
        if isempty(ext_list)
            %filter typical extensions from cyclers
            ext_list = {'.csv', '.res', '.xls', '.xlsx', '.mpt'};
        end

    elseif isfile(file_in)
        filelist = {file_in};
    else
    info_raw_data = [];
    fprintf('dattes_info_raw_data: input must be a pathname (folder or file) or a filelist.\n');
    fprintf('Given input: %s\n',file_in);
    return
    end
elseif iscell(file_in)
    if any(~cellfun(@ischar,ext_list))
        info_raw_data = [];
        fprintf('dattes_info_raw_data: wrong inputs.\n');
        fprintf('ext_list must be a cell containing file extensions (char)\n');
        return
    else
        filelist = file_in;
    end
end

%filter filelist extensions
[D,F,E] = cellfun(@fileparts,filelist,'UniformOutput',false);
ind_filter = ismember(E,ext_list) | ismember(E,upper(ext_list));
filelist = filelist(ind_filter);
D = D(ind_filter);
F = F(ind_filter);
E = E(ind_filter);


%info raw data
%1. get file list
info_raw_data.filelist = filelist;
%2. get file extension
info_raw_data.extension = E;

%2. get file size
Dirinfo = cellfun(@dir,filelist);
bytes = [Dirinfo.bytes]';

%3. which cycler
[cycler, line1, line2, header_lines, first_data_line] = cellfun(@which_cycler,filelist,'UniformOutput',false);
info_raw_data.cycler = cycler;
info_raw_data.line1 = line1;
info_raw_data.line2 = line2;
info_raw_data.header_lines = header_lines;
info_raw_data.first_data_line = first_data_line;

%4. investigate further:
%TODO: analyse header lines and first line of data.
% Due to multiple different formats do this specifically to each cycler:
% - Arbin CSV: well formed csvs, easy to get column separator
% - Bitrode: different versions, not easy to make it work always
% - Neware: not well formed csv files, different column number for normal
% lines, step statistics, cycle statistics
% - Biologic: not csv files but mpt (fixes column with padding spaces)
% 
% For each cycler, create a function 'analyse_cycler_header' with outputs:
% - variable names and units
% - test date
% - column separator
% - decimal separator
% - datetime format?

 [variable_names, unit_names, date_test, source_file,test_params] = cellfun(@(x,y,z,w) analyse_head(x,y,z,w),header_lines,first_data_line,cycler,filelist,'UniformOutput',false);
 info_raw_data.variable_names = variable_names;
 info_raw_data.unit_names = unit_names;
 info_raw_data.date_test = date_test;
 info_raw_data.source_file = source_file;
 info_raw_data.test_params = test_params;
 

 % reformat data: 1x1 struct of nx1 cells, to nx1 struct
 fields = fieldnames(info_raw_data);

 for ind = 1:length(filelist)
     for ind2 = 1:length(fields)
         info_raw_data1(ind).(fields{ind2})= info_raw_data.(fields{ind2}){ind};
     end
 end
 info_raw_data = info_raw_data1;
end

function [variable_names, unit_names, date_test, source_file,test_params] = analyse_head(header,first_data_line,cycler,filename)

%biologic
if strncmp(cycler,'bio',3)
    [variable_names, unit_names, date_test, source_file,test_params] = analyse_biologic_head(filename,header);
    return
end
%arbin_csv
if strncmp(cycler,'arbin_csv',9)
[variable_names, unit_names, date_test, source_file,test_params] = analyse_arbin_head(filename, header, first_data_line);
    return
end
%bitrode
if strncmp(cycler,'bitrode',7)
[variable_names, unit_names, date_test, source_file,test_params] = analyse_bitrode_head(filename,header);
    return
end
%digatron
if strncmp(cycler,'digatron',8)
[variable_names, unit_names, date_test, source_file,test_params] = analyse_digatron_head(filename, header, first_data_line);
    return
end
%neware
if strncmp(cycler,'neware',6)
    [variable_names, unit_names, date_test, source_file,test_params] = analyse_neware_head(filename, header, first_data_line);
    return
end

%unknown cycler (or binary file):
variable_names = [];
unit_names = [];
date_test = [];
source_file = [];
test_params = [];
end


