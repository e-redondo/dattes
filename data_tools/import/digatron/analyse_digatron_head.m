function [variable_names, unit_names, date_test, source_file,test_params] = analyse_digatron_head(file_name, header, first_data_line)
% analyse_digatron_head Analyse header and variables of digatron files
%
%
% Usage:
% [variable_names, unit_names, date_test, source_file,test_params] = analyse_digatron_head(file_name, header, first_data_line)
% Inputs : 
% - file_name: Result file_name from the Biologic cycler
% Outputs : 
% - variable_names: [1xn cell] Names of the variables
% - unit_names: [1xn cell] Names of the variables units
% - date_test: [1xn cell] Date of the test
% - source_file: [1xn cell] Source file
% - test_params: [struct]  with fields, not still used
%
%   See also import_arbin_csv
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

source_file = file_name;
variables_line = header{end-1};
units_line = header{end};


% test date
date_test_line = regexpFiltre(header,'Start.Time');
if isempty(date_test_line)
    date_test = '';
else
    date_test = regexp(date_test_line{1},'[0-9].*$','match','once');
    col_sep = regexp(date_test_line{1},'Start.Time.','match','once');
    col_sep = col_sep(end);%first char after 'Start.Time.'
    test_params.colsep = col_sep;
end

variable_names = regexp(variables_line,test_params.colsep,'split');
unit_names = regexp(units_line,test_params.colsep,'split');
unit_names = regexprep(unit_names,'\[','');
unit_names = regexprep(unit_names,'\]','');

end