function export_eis_csv(dattes_struct, options, file_out)
% export_eis_csv export EIS from DATTES struct to csv file
%
% 
% Usage:
% export_eis_csv(dattes_struct, options, file_out)
%
% Input:
% - dattes_struct [1x1 struct] DATTES result structure
% - options [1xp string]: (optional)
%   - 'm': include metadata in header in json format commented lines (starting with '#')
% - file_out [1xp string]: (optional) 
%
%
% See also dattes_export, export_profiles_csv
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

%0. check inputs
%check dattes_struct
if ~isfield(dattes_struct,'eis')
     fprintf('ERROR export_eis_csv:No EIS found in DATTES struct\n');
     return
end
%check options
if ~exist('options','var')
    options = '';%default: no metadata
end

%check fileout name
if ~exist('fileout','var')
    file_suffix = '_dattes_eis.csv';
    file_out = regexprep(dattes_struct.test.file_in,'.[a-zA-Z0-9]*$',file_suffix);
end

%1. open fileout
fid_out = fopen(file_out,'w+');
if fid_out<1
    fprintf('ERROR export_eis_csv:Unable to open %s\n', file_out);
    return
end

%2. metadata option
if ismember('m',options')
    %include metadata
    json_txt = jsonencode(dattes_struct.metadata,'PrettyPrint',true);
    json_txt = ['#' regexprep(json_txt,'\n','\n#')];
    fprintf(fid_out,'%s\n',json_txt);
end

%3. export eis
var_names = fieldnames(dattes_struct.eis);
data_array = [];
for ind=1:length(var_names)
    column = dattes_struct.eis.(var_names{ind});%get column
    if isempty(column)
        column = nan(size(data_array,1),1);
    end
    data_array = [data_array,column]; 
end
% convert cell 2 array (all eis concatenated for csv)
data_array = cell2mat(data_array);
%header line:
header_line = strjoin(var_names,',');
fprintf(fid_out,'%s\n',header_line);
%close fileout
fclose(fid_out);

%data:
% dlmwrite(fileout,A,'-append');%not recommended: limited precision
writematrix(data_array,file_out,'Writemode','append');
end