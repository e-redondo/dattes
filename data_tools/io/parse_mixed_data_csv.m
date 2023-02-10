function [header_lines,data_columns,tail_lines] = parse_mixed_data_csv(file_in,params)
% parse_mixed_data_csv - Read CSV files with mixed data (numeric/text),
% with headers and trailing lines after data.
%
% Usage: [header_lines,data_columns,tail_lines] = parse_mixed_data_csv(file_in,params)
%
% Inputs:
% - file_in [char]: pathname to the csv file
% - paramas [struct] with fields:
%   - 'col_sep' [char]: column separator (default ',')
%   - 'dec_sep' [char]: decimal separator (default '.'), (not yet used)
%   - 'str_sep' [char]: decimal separator (default ''), (not yet used)

%TODO: treat emptys as text instead as numbers
% Currently if empty value is found in text_line, '%f'.
% This is OK for Arbin files: some columns are sparse numeric (most of
% empty, some numbers), but it does not work with Bitrode files: some
% columns are mostly empty but non empty values are char. This makes
% textscan to stop.


if ~exist('params','var')
    params = struct;
end

if ~isfield(params,'col_sep')
    params.col_sep = ',';
end
if ~isfield(params,'dec_sep')
    params.dec_sep = '.';
end
if ~isfield(params,'str_sep')
    params.str_sep = '';
    %params.str_sep = '"'; % to ignore "
    %params.str_sep = "'"; % to ignore '

end
if ~isfield(params,'all_str')
    % treat all column as strings
    params.all_str = false;
end
%1. read header
fid = fopen(file_in,'r','n','ISO-8859-11');
[header_lines,fid] = read_csv_header(fid,params);

first_data_line = header_lines{end};
header_lines = header_lines(1:end-1);
%2. build text_fmt
text_fmt = build_scanf_fmt(first_data_line,params);

if params.all_str
    text_fmt = strrep(text_fmt,'f','s');
end
%3. textscan
if isempty(params.str_sep)
    data_columns1 = textscan(first_data_line,text_fmt,'Delimiter',params.col_sep);
    data_columns = textscan(fid,text_fmt,'Delimiter',params.col_sep);
else
   %TODO: seems not to work in octave (neware files)
   data_columns1 = textscan(first_data_line,text_fmt,'Delimiter',params.col_sep,'Whitespace',[' \b\r\n\t' params.str_sep]);
   data_columns = textscan(fid,text_fmt,'Delimiter',params.col_sep,'Whitespace',[' \b\r\n\t' params.str_sep]);
end


data_columns = cellfun(@(x,y) vertcat(x,y),data_columns1,data_columns,'UniformOutput',false);

data_columns = data_columns';

%3.1 replace each char in str_sep by nothing in string columns:
for ind = 1:length(data_columns)
    if iscell(data_columns{ind})
        for ind2 = 1:length(params.str_sep)
            data_columns{ind} = strrep(data_columns{ind},params.str_sep(ind2),'');
        end
    end
end

%4.tail_lines
tail_lines = cell(0);
while ~feof(fid)
    tail_lines{end+1} = fgetl(fid);
end

fclose(fid);
end

function text_fmt = build_scanf_fmt(text_line,params)
% search in text line numeric data, then build a format string for textscan

if ~exist('params','var')
    params = struct;
end

if ~isfield(params,'col_sep')
    params.col_sep = ',';
end

if ~isfield(params,'str_sep')
    params.str_sep = '';
    %params.str_sep = '"'; % to ignore "
    %params.str_sep = "'"; % to ignore '

end

%cut line into 'words'
words = regexp(text_line,params.col_sep,'split');
%trim leading and trialing spaces
words = strtrim(words);
%ignore some characters:
for ind =1:length(params.str_sep)
words = strrep(words,params.str_sep(ind),'');
end
%build regex expression to detect numbers
expression = '^\-{0,1}[0-9]*\.{0,1}[0-9]+([eE][+-]{0,1}[0-9]+){0,1}$';
%find 'numbers'
numbers = regexp(words,expression,'match','once');
%check back where 'numbers' are equal to 'words'
%index_numbers is thus, positions where numbers are
index_numbers = cellfun(@(x,y) isequal(x,y),words,numbers);

text_fmt = repmat({'%s'},size(words));
text_fmt(index_numbers) = deal({'%f'});
text_fmt = strjoin(text_fmt,' ');


end
