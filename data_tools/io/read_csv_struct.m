function [profiles, metadata, err] = read_csv_struct(file_in)
% read_csv_struct profiles/eis from csv file to DATTES struct
%
% 
% Usage:
% [profiles, metadata] = read_csv_struct(dattes_struct, options, file_out)
%
% Input:
% - file_in [1xp string]: pathname
%
% Output:
% - profiles [1x1 struct] DATTES profiles/eis structure
% - metadata [1x1 struct] DATTES metadata structure
%
% See also dattes_import, export_profiles_csv, export_eis_csv,
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

%TODO: customize col_sep

%TODO: error management
err = 0;
profiles = struct;
metadata = struct;
%0. check inputs


%1. open fileout
fid_in = fopen(file_in,'r');
if fid_in<1
    fprintf('ERROR read_csv_struct:Unable to open %s\n',file_in);
    
    return
end

%2. read header
header = {fgetl(fid_in)};
while ~feof(fid_in) && header{end}(1)=='#'
    header{end+1} = fgetl(fid_in);
end

var_names = regexp(header{end},',','split');
header = header(1:end-1);
if ~isempty(header)
    %read metadata
    jsonlines = regexprep(header,'^#','');
    jsontxt = [jsonlines{:}];
    metadata = jsondecode(jsontxt);
end
%3. read data
data = cell(0);
while ~feof(fid_in)
    data{end+1} = fgetl(fid_in);
end
fclose(fid_in);

%3.1 convert data to numbers
data = regexp(data,',','split');
data = vertcat(data{:});
data = cellfun(@(x) sscanf(x,'%f'),data);
%4. organise data in data_struct
for ind = 1:length(var_names)
    profiles.(var_names{ind}) = data(:,ind);
end

%TODO: check if it is profiles or eis struct

end