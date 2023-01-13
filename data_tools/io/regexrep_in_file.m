function regexrep_in_file(file_in,str_old,str_new,file_out)
% regexrep_in_file do regexrep for lines in a file
% 
% Usage 
% regexrep_in_file(file_in,str_old,str_new,file_out)
% Inputs:
% - file_in (string): input pathname
% - str_old (string): text to replace (regex syntax)
%           (cell of string): texts to replace (regex syntax)
% - str_new (string): replacement text
%           (cell of string): replacement texts
% - file_out (string): output pathname
%                      (if not given 'file_in_replace.extension')
%
% 
% See also regexp, rexgexprep
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

if ~exist('file_out','var')
    [D,file_out,E]  = fileparts(file_in);

    file_out = fullfile(D,sprintf('%s_replace%s',file_out,E));
end
fid_in = fopen(file_in,'r');
fid_out = fopen(file_out,'w+');

if ischar(str_old)
    str_old = {str_old};
end
if ischar(str_new)
    str_new = {str_new};
end

if length(str_old)~=length(str_new)
    return;
end

while ~feof(fid_in)
    this_line = fgetl(fid_in);
    for ind = 1:length(str_old)
        this_line = regexprep(this_line,str_old{ind},str_new{ind});
    end
    fprintf(fid_out,'%s\n',this_line);
end

fclose(fid_in);
fclose(fid_out);

end