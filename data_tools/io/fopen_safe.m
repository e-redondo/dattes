function fid = fopen_safe(file_in, options)

if ~exist('options','var')
    options = '';
end

[file_type] = file_signature(file_in);
if isequal(file_type,'UTF-8')
fid = fopen(file_in,'r','n','UTF-8');%utf-8
elseif isequal(file_type,'ascii')
fid = fopen(file_in,'r','n','ISO-8859-11');%ascii files
else
fid = fopen(file_in,'r');%try generic open
end

if ismember('v',options)
    [file, mode, arch, encoding] = fopen (fid);
    fprintf('fopen_safe: file %s is open as %s\n',file,encoding);
end

end
