function [header_lines,data_columns,tail_lines,data_lines] = parse_mixed_data_csv(file_in,params)

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
    %params.str_sep = '"'; % to replace " by nothing
    %params.str_sep = "'"; % to replace ' by nothing

end

fid = fopen(file_in);
[header_lines,fid] = read_csv_header(fid,params);

data_lines = header_lines(end);
header_lines = header_lines(1:end-1);
while ~feof(fid)
    data_lines{end+1,1} = fgetl(fid);
end
fclose(fid);

%clean 'str_sep':
if ~isempty(params.str_sep)
    %TODO: just replace by couple of str_sep "protect string"
    %TODO: how to protect from split, e.g. "string1","string2, with ,"
    data_lines = regexprep(data_lines,['\' params.str_sep],'');
end

%cut lines into words:
data_matrix = regexp(data_lines,params.col_sep,'split');


nr_words = cellfun(@length,data_matrix);
ind_tail_lines = find(nr_words~=nr_words(1),1);

if ~isempty(ind_tail_lines)
    tail_lines = data_lines(ind_tail_lines:end);
    data_lines = data_lines(1:ind_tail_lines-1);
    data_matrix = data_matrix(1:ind_tail_lines-1);
else
    tail_lines = cell(0);
end
data_matrix = vertcat(data_matrix{:});

%find column types from ifirst line of data:
this_line = data_lines{1};
this_words = regexp(this_line,params.col_sep,'split');
index_numbers = cellfun(@str2num,this_words,'UniformOutput',false);
index_numbers = ~cellfun(@isempty,index_numbers);

%expression = '^-{0,1}[0-9]*\.{0,1}[0-9]*((e|E)(+|-)[0-9]*){0,1}$'
expression = '^\-{0,1}[0-9]*\.{0,1}[0-9]+([eE][+-]{0,1}[0-9]+){0,1}$';
index_numbers = regexp(this_words,expression,'match','once');
index_numbers = ~cellfun(@isempty,index_numbers);

% index_dates = ~cellfun(@isempty,regexp(this_words,'^[0-9]*[^0-9\.\-].*[0-9AP][0-9M]$','match','once'));
%for each column do conversions:
data_columns = cell(size(data_matrix,2),1);
for ind = 1:size(data_matrix,2)
    this_column = data_matrix(:,ind);
    if index_numbers(ind)
        %replace empties with nans
        ind_empty = cellfun(@isempty,this_column);
        this_column(ind_empty) = deal({'nan'});
        %this column is numeric
%         data_matrix(:,ind) = num2cell(str2double(this_column));
%         data_matrix(:,ind) =  cellfun(@(x) sscanf(x,'%f'),this_column,'UniformOutput',false);
        data_columns{ind} = cellfun(@(x) sscanf(x,'%f'),this_column);
%     elseif index_dates(ind)
        %this column is a date
%         try
%           data_matrix(:,ind) = num2cell(datenum(this_column));
%         catch
            %do nothing
%         end
    else
        data_columns{ind} = this_column;
    end
end


end
