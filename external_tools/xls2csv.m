function [folder_out, err] = xls2csv(file_in)
% xls2csv - Interface to run PET4DATTES' ss2csv script
%
% convert a xls(x) file into a folder containing a csv file per sheet.

code_folder = fileparts(which('xls2csv'));
py_list = lsFiles(code_folder, '.py');

ss2csv_pathname = regexpFiltre(py_list,'ss2csv.py$');
ss2csv_pathname = ss2csv_pathname{1};

dos_cmd = sprintf('python3 "%s" "%s"',ss2csv_pathname, file_in);

if isunix
  [err,result] = unix(dos_cmd);
else
  [err,result] = dos(dos_cmd);
end

[D, F, E] = fileparts(file_in);

folder_out = fullfile(D,F);

end
