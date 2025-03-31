function [variable_names, unit_names, date_test, source_file,params] = analyse_generic_head(file_name, header, first_data_line)
% analyse_generic_head Analyse header and variables of generic files
%
%
% Usage:
% [variable_names, unit_names, date_test, source_file,test_params] = analyse_generic_head(file_name, header, first_data_line)
% Inputs : 
% - file_name: Result file_name
% Outputs : 
% - variable_names: [1xn cell] Names of the variables
% - unit_names: [1xn cell] Names of the variables units
% - date_test: [1xn cell] Date of the test
% - source_file: [1xn cell] Source file
% - test_params: [struct]  with fields, not still used
%
%   See also import_generic_csv
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

variables_line = header{end};
%detect column separator:
col_sep = detect_col_sep(variables_line, first_data_line);
%detect decimal separator:
dec_sep = detect_dec_sep(first_data_line,col_sep);


%initialise outputs:
    variable_names={};
    unit_names={};
    date_test=[];
    source_file=file_name;
    params.col_sep=col_sep;
    params.dec_sep=dec_sep;

if isempty(col_sep)
    %not found column separator, stop here
    return
end

variable_names = regexp(variables_line,col_sep,'split');
unit_names = regexp(variable_names,'\(.*\)','match','once');

variable_names = regexprep(variable_names,'\(.*\)','');
unit_names = regexprep(unit_names,'\(|\)','');
end

function col_sep = detect_col_sep(variables_line, first_data_line)

variables_line = strtrim(variables_line);
first_data_line = strtrim(first_data_line);
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

function dec_sep = detect_dec_sep(first_data_line,col_sep)

if ismember('.',first_data_line)
    dec_sep = '.';
    return
end
if ismember(',',first_data_line) && ~isequal(',',col_sep)
    dec_sep = ',';
    return
end

dec_sep = ''; %unknown
end