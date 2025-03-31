function [header_lines,fid] = read_csv_header(fid,params)

if ~exist('params','var')
    params = struct;
end

if ~isfield(params,'str_sep')
    %see parse_mixed_data_csv
    params.str_sep = '';
end
if ~isfield(params,'max_lines')
    %maximum number of lines to read if no numeric is found
    params.max_lines = 100;
end
if ~isfield(params,'header_lines')
    %fixed number of lines to read if no numeric is found
    %
    params.header_lines = 0;
end

%clean 'str_sep':
if isempty(params.str_sep)
    my_fgetl = @fgetl;
else
    %using handle functions is REALLY cool
    my_fgetl = @(x) regexprep(fgetl(x),['\' params.str_sep],'');
end

frewind(fid);
this_line = my_fgetl(fid);
header_lines = {this_line};

if params.header_lines>0
    %read exactly number of header_lines
    while ~feof(fid) && length(header_lines)<params.header_lines
        this_line = my_fgetl(fid);
        header_lines{end+1,1} = this_line;
    end
else
    %read until find a number or max_lines
    while ~feof(fid) && isempty(regexp(this_line,'^\s*\-?\.?[0-9]','once')) && length(header_lines)<params.max_lines
        this_line = my_fgetl(fid);
        header_lines{end+1,1} = this_line;
    end
end


end