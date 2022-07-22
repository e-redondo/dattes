function [err] = profiles2csv(filename,profiles, other_cols,params)
% profiles2csv Write profiles to CSV file
%
% Usage:
% [err] = profiles2csv(filename,profiles, other_cols,params)
%
% Inputs:
% - filename [1xp string]: pathname to .csv file
% - profiles [1x1 struct] with fields:
%   - t,U,I,m,T,dod_ah,soc [mx1 double]
% - other_cols [1x1 struct]: with same structure than profiles but other names
%   - if empty, no other_cols
% - params [1x1 struct] with fields:
%    - col_sep: default ','
%    - append: true/false append file
% Outputs:
% - err [1x1 double]: 0 if no error, <0 if error

%
% See also which_mode
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

% TODO: add support for other_cols (additionnal columns as in csv2profiles)

err = 0;
%0. check inputs
default_params.col_sep = ',';
default_params.append = false;
if ~exist('params','var')
    params = struct;
end
if ~isfield(params,'col_sep')
    params.col_sep = default_params.col_sep;
end
if ~isfield(params,'append')
    params.append = default_params.append;
end

%0.1 check profiles struct:
if ~isstruct(profiles)
    err = -1;
    return
end
fieldlist = fieldnames(profiles);
%find vectors:
Iv = cellfun(@(x) isvector(profiles.(x)),fieldlist);
%get vector lengths
L =  cellfun(@(x) length(profiles.(x)),fieldlist(Iv));
L = unique(L); %get unique length
if length(L)~=1
    err = -2;%not all vectors same size
    return
end
%find emptys:
Ie = cellfun(@(x) isempty(profiles.(x)),fieldlist);
%fill empty vectors with nans:
profiles = cellfun(@(x) setfield(profiles,x,nan(L,1)),fieldlist(Ie));

%1. write header
if params.append
    fid = fopen(filename,'a');
else
    fid = fopen(filename,'w+');
end
if fid<0
    err=-3;
    return
end

header = fieldnames(profiles);
header_line = strjoin(header, params.col_sep);
fprintf(fid,'%s\n',header_line);
fclose(fid);


%2. write data
data = struct2cell(profiles);





data = horzcat(data{:});
% 
% for ind = 1:length(header)
%     fprintf(fid,'%s\t',header{ind});
% end
% fprintf(fid,'\n');
% 
% for ind = 1:size(data,1)
%   fprintf(fid,'%s\t',data(ind,:));
%   fprintf(fid,'\n');
% end

dlmwrite(filename,data,'-append','delimiter',params.col_sep,'precision',12);

end
