function [variable_names, unit_names, date_test, source_file,test_params] = analyse_btsuite_head(file_name, header, first_data_line)
% analyse_btsuite_head Analyse header and variables of Biologic BT-suite files
%
%
% Usage:
% [variable_names, unit_names, date_test, source_file,test_params] = analyse_btsuite_head(file_name, header, first_data_line)
% Inputs : 
% - file_name: Result file_name from the Biologic cycler
% Outputs : 
% - variable_names: [1xn cell] Names of the variables
% - unit_names: [1xn cell] Names of the variables units
% - date_test: [1xn cell] Date of the test
% - source_file: [1xn cell] Source file
% - test_params: [struct]  with fields, not still used
%
%   See also import_btsuite
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

variables_line = header{end};
%detect column separator:
col_sep = detect_col_sep(variables_line, first_data_line);


%initialise outputs:
    variable_names=[];
    unit_names=[];
    date_test=[];
    source_file=file_name;
    test_params.colsep=col_sep;

if isempty(col_sep)
    %not found column separator, stop here
    return
end

%split line by column separator
variable_names = regexp(variables_line,col_sep,'split');
%remove empty elements (e.g. line finishing by separator)
ind_empty = cellfun(@isempty,variable_names);
variable_names = variable_names(~ind_empty)';
unit_names = cell(size(variable_names));

%split variables and units
words = regexp(variable_names,'\s*\/\s*','split','once');

for ind = 1:length(variable_names) 
    variable_names{ind} = strtrim(words{ind}{1});
    if length(words{ind})>1
        unit_names{ind} = strtrim(words{ind}{2});
    end
end

%fix non Ascii names in units:
% temperature:
[~,~,ind_temperature] = regexpFiltre(variable_names,'Temperature');
%TODO: check if other units of temperature (Farenheit, Kelvin)
unit_names(ind_temperature) = deal({'degC'});

% Z (impedance) and Y (admitance)
% Phase units (normally rad)
[~,~,ind_phase] = regexpFiltre(variable_names,'Phase\([ZY]\)');
unit_phase = unit_names(ind_phase);
% impedance units (normally Ohm)
[~,~,ind_impedance] = regexpFiltre(variable_names,'Z');
unit_names(ind_impedance) = deal({'Ohm'});
% admitance units (normally Ohm-1)
[~,~,ind_admitance] = regexpFiltre(variable_names,'Y');
unit_names(ind_admitance) = deal({'Ohm_1'});
%except for Phase(Z) and Phase(Y), put back the unit rad:
unit_names(ind_phase) = deal(unit_phase);

% Rdc and Rac
[~,~,ind_resistance] = regexpFiltre(variable_names,'R[ad]c');
unit_names(ind_resistance) = deal({'Ohm'});

%clean unit names
unit_names = regexprep(unit_names,' \/ ','_');

%clean variable names
variable_names = regexprep(variable_names,'[-|\(\)]','');
variable_names = regexprep(variable_names,' ','_');

end

function col_sep = detect_col_sep(variables_line, first_data_line)

%detect column separator:
nr_commas_header = length(find(variables_line==','));
nr_commas_data = length(find(first_data_line==','));

nr_scolons_header = length(find(variables_line==';'));
nr_scolons_data = length(find(first_data_line==';'));

nr_tabs_header = length(find(variables_line==sprintf('\t')));
nr_tabs_data = length(find(first_data_line==sprintf('\t')));

%comma dominant
if nr_commas_header>=nr_scolons_header && nr_commas_header>=nr_tabs_header...
    && nr_commas_header==nr_commas_data
    col_sep = ',';
    return
end
%semicolon dominant
if nr_scolons_header>=nr_commas_header && nr_scolons_header>=nr_tabs_header...
    && nr_scolons_header==nr_scolons_data
    col_sep = ';';
    return
end
%tab dominant
if nr_tabs_header>=nr_commas_header && nr_tabs_header>=nr_scolons_header...
    && nr_tabs_header==nr_tabs_data
    col_sep = '\t';
    return
end

%not found
col_sep = '';

end