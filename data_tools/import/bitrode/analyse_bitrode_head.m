function [variable_names, unit_names, date_test, source_file,test_params] = analyse_bitrode_head(filename,header)
% analyse_bitrode_head Analyse header and variables of bitrode files
%
%
% Usage:
% [variable_names, unit_names, date_test, source_file,test_params] = analyse_bitrode_head(header)
% Inputs : 
% - header: Result file_name from the Biologic cycler
% Outputs : 
% - variable_names: [1xn cell] Names of the variables
% - unit_names: [1xn cell] Names of the variables units
% - date_test: [1xn cell] Date of the test
% - source_file: [1xn cell] Source file
% - test_params: [struct]  with fields, not still used
%
%   See also import_bitrode
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab:
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

variable_names=[];
unit_names=[];
date_test=[];
source_file=filename;
test_params.colsep='';

variables_line = header{end};

% test date
date_test_line = regexpFiltre(header,'Test.Date');
if isempty(date_test_line)
    date_test = '';
else
    date_test = regexp(date_test_line{1},'[0-9].*[0-9]','match','once');
    col_sep = regexp(date_test_line{1},'Test.Date.','match','once');
    col_sep = col_sep(end);%first char after 'Test.Date'
    test_params.colsep = col_sep;
end

% test name
test_name_line = regexpFiltre(header,'Test.Name');
if isempty(test_name_line)
    test_params.test_name = '';
else
    test_params.test_name = regexprep(test_name_line{1},'Test.Name.','');
end


%variables
if variables_line(1)=='"'
    % new format: "Total Time, S","Cycle","Loop Counter #1",...
    variables_line = regexprep(variables_line,', ','_');
    variables_line = regexprep(variables_line,'"','');
end
variable_names = regexp(variables_line,test_params.colsep,'split');
ind_empty = cellfun(@(x) isempty(x),variable_names);
variable_names = variable_names(~ind_empty);

%unit_names
unit_names = regexp(variable_names,'_.*$','match','once');
ind_empty = cellfun(@(x) isempty(x),unit_names);
[unit_names{ind_empty}] = deal('');
unit_names = regexprep(unit_names,'^_','');
variable_names = regexprep(variable_names,'_.*$','');

%fix units names:
unit_names = regexprep(unit_names,'S','s');
unit_names = regexprep(unit_names,'AH','Ah');
unit_names = regexprep(unit_names,'WH','Wh');
unit_names = regexprep(unit_names,'.C','degC');


end