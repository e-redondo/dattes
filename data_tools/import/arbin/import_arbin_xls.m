function xml = import_arbin_xls(file_in,options)
% import_arbin_xls Arbin *.XLS to VEHLIB XMLstruct converter 
%
% Converts each xls(x) file into csv, then uses import_arbin_csv to convert
% to xml.
%
% Usage
%   xml = import_arbin_xls(file_in) 
% Read filename (*.xls file) and converts   to xml (VEHLIB XMLstruct)
% Inputs:
% - file_in (string): filename or full pathname
%
% Outputs:
% - xml (struct): structure with XML format 4 VEHLIB
% 
%   See also import_arbin_csv, xls2csv
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

verveh=2.0;

%0.-Errors:
if ~exist('options','var')
    options = '';
end
verbose = ismember('v',options);

%0.1.- Check file existance
[D F E] = fileparts(file_in);
filename = [F E];

if ~exist(file_in,'file')
    fprintf('import_arbin_xls: file does not exist: %s\n',file_in);
    xml = [];
    return;
end

%1.- file conversion
if verbose
fprintf('import_arbin_xls: %s...\n',file_in);
end

 %convert to csv
 [csv_folder, err] = xls2csv(file_in);
 
 if err
     fprintf('import_arbin_xls: error during xls to csv conversion. Check your python setup.\n');
 else
 %import csv to xml:
 xml = import_arbin_csv(csv_folder, options);

 %delete csv folder
 delete(fullfile(csv_folder,'*.csv'));
 rmdir(csv_folder)

 if verbose
     fprintf('import_arbin_xls: %s...OK\n',file_in);
 end
 end
end
