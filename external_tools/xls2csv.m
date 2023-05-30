function [folder_out, err] = xls2csv(file_in)
% xls2csv - Interface to run PET4DATTES' ss2csv script
%
% convert a xls(x) file into a folder containing a csv file per sheet.

code_folder = fileparts(which('xls2csv'));
py_list = lsFiles(code_folder, '.py');

%python command name (e.g.: python, python3, /usr/bin/python3.8, etc.)
%user can adapt to their setup
python_cmd = 'python3';
ss2csv_pathname = regexpFiltre(py_list,'ss2csv.py$');
ss2csv_pathname = ss2csv_pathname{1};

dos_cmd = sprintf('%s "%s" "%s"',python_cmd,ss2csv_pathname, file_in);

if isunix
  [err,result] = unix(dos_cmd);
else
  [err,result] = dos(dos_cmd);
end

[D, F, E] = fileparts(file_in);

folder_out = fullfile(D,F);

if err
    fprintf('xls2csv: ERROR, check your python and pet4dattes install\n');
    fprintf('%s',result);
end
end
