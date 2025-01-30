function [variable_names, unit_names, date_test, source_file,test_params] = analyse_comutes2_head(filename,header)
% analyse_comutes2_head Analyse header and variables of comutes2 files
%
%
% Usage:
% [variable_names, unit_names, date_test, source_file,test_params] = analyse_comutes2_head(header)
% Inputs : 
% - header: Result file_name from the Biologic cycler
% Outputs : 
% - variable_names: [1xn cell] Names of the variables
% - unit_names: [1xn cell] Names of the variables units
% - date_test: [1xn cell] Date of the test
% - source_file: [1xn cell] Source file
% - test_params: [struct]  with fields, not still used
%
%   See also import_comutes2
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

colsep = regexp(variables_line,'[^A-Za-z0-9]','match');
colsep = unique(colsep);
if length(colsep)>1
    error('analyse_comutes_head: more than one possible column separator');
end
test_params.colsep = colsep{1};

% test date
date_test_line = regexpFiltre(header,'test_time');
if isempty(date_test_line)
    date_test = '';
else
    date_test = regexp(date_test_line{1},'[0-9].*[0-9]','match','once');
end

% TODO other info (lab name, temperature, test type, etc.)


%variables
variable_names = regexp(variables_line,test_params.colsep,'split');
ind_empty = cellfun(@(x) isempty(x),variable_names);
variable_names = variable_names(~ind_empty);

%unit_names (from variable names)
unit_names = regexprep(variable_names,'Time','s');
unit_names = regexprep(unit_names,'U','V');
unit_names = regexprep(unit_names,'I','A');
unit_names = regexprep(unit_names,'Q','Ah');
unit_names = regexprep(unit_names,'Temp','degC');
unit_names = regexprep(unit_names,'Mode','');


end