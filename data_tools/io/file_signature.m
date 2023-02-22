function [file_type, signature, signature_char] = file_signature(filename)

[D, F, E] = fileparts(filename);
%open the file:
fid = fopen(filename);

%read first 8 bytes (double):
first_bytes = fread(fid,8);
%convert signature to string
signature = strjoin(num2cell(dec2hex(first_bytes),2),'');
signature_char = char(first_bytes);

%close the file:
fclose(fid);

if length(first_bytes)<8
  file_type = 'empty';
  return
end

%determine file type/encoding
if isequal(first_bytes(1:3),[239; 187; 191]) % hex: 'EF BB BF'
    file_type = 'UTF-8';
elseif all(ismember(first_bytes,[10 13 20:126]))
    file_type = 'ascii';
elseif isequal(first_bytes(1:2),[80; 75]) % hex: '50 4B'
    if strncmpi(E,'.xls',4)
        %sometimes xlsx files are save dunder xls extension
        file_type = 'xlsx';
    else
        file_type = 'zip';
    end
elseif isequal(signature,'000100005374616E') % hex: 'EF BB BF'
    file_type = 'mdb'; %access 2007 database
else
    file_type = 'unknowkn';
end


end
