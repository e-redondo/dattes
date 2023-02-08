function [header_lines,fid] = read_csv_header(fid,params)

if ~exist('params','var')
    params = struct;
end

if ~isfield(params,'str_sep')
    %see parse_mixed_data_csv
    params.str_sep = '';
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

while ~feof(fid) && isempty(regexp(this_line,'^\-?\.?[0-9]','once')) && length(header_lines)<100
    this_line = my_fgetl(fid);
    header_lines{end+1,1} = this_line;
end


end