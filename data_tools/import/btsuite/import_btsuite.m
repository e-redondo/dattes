function xml = import_btsuite(file_in, options)
% import_btsuite  Biologic BT-Suite *.CSV to VEHLIB XMLstruct converter
%
% Usage
%   xml = import_btsuite(file_in)
% Read filename (*.csv file) and converts to xml (VEHLIB XMLstruct)
% Inputs:
% - file_in (string): pathname of a csv file
%           (string): folder to search csv files in
% - options (string): containing the following characters
%   - 'v': verbose, tells what it does
%
% Outputs:
% - xml (struct): structure with XML format 4 VEHLIB
%
%   See also csv2profiles, analyse_btsuite_head
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab:
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

verveh=2.0;

%0.-Errors:
if ~exist('options','var')
    options = '';
end

if ~exist(file_in,'file')
    fprintf('import_btsuite: file does not exist: %s\n',file_in);
    xml = [];
    return;
end

%0.1.- Check file existance
[D F E] = fileparts(file_in);
filename = [F E];




info_raw_data = get_info_raw_data(file_in);


if ~strcmp(info_raw_data.cycler,'bio_btsuite')
    %Probably an error reading xls file:
    fprintf('WARNING: not a Biologic BT Suite csv file: %s\n',file_in);
    xml = [];
    return;
end

%1.- reading file
params = struct;  % see csv2profiles if some params are needed
%params.U_thres = 0.01;
%params.I_thres = 0.1;
params.colsep = info_raw_data.params.colsep;

params.date_fmt = '';

params.variable_list = info_raw_data.variable_names;
params.units_list = info_raw_data.unit_names;

%dt, tt, u, i, m, T, dod_ah, soc, step, ah, ah_dis, ah_cha
col_names = {'','Time','U','I','','Temperature','','','Step_number', 'Q', 'Q_discharge', 'Q_charge'};


[profiles, other_cols] = csv2profiles(file_in,col_names,params);
%dt, tt, u, i, m, T, dod_ah, soc, step, ah, ah_dis, ah_cha
profiles_units = {'s','s','V','A','','degC','Ah','','','Ah','Ah','Ah'};

%Change mode by Task codes:
profiles.mode = zeros(size(profiles.t));
%CC
[~,~,ind_cc] = regexpFiltre(other_cols.Task,'^CC$');
profiles.mode(ind_cc) = 1;
%CV
[~,~,ind_cv] = regexpFiltre(other_cols.Task,'^CV$');
profiles.mode(ind_cv) = 2;
%REST
[~,~,ind_rest] = regexpFiltre(other_cols.Task,'^REST$');
profiles.mode(ind_rest) = 3;
%EIS
[~,~,ind_eis] = regexpFiltre(other_cols.Task,'^EIS$');
profiles.mode(ind_eis) = 4;

%PROFILE (other points to 5)
%TODO: check other working modes before (CP?, CR?...)
profiles.mode(profiles.mode==0) = 5;


if isempty(profiles.datetime)
    profiles.datetime = profiles.t;
end



%DEBUG
% [D,F,E] = fileparts(file_in);
% save(sprintf('%s.mat',F),'profiles');

%3.- creer XML
%3.1.- introduire entete:
[XMLHead, err] = makeXMLHead('bt-suite',date,'',sprintf('import_btsuite version:%.2f',verveh));
%3.2.- metatable
[XMLMetatable, err] = makeXMLMetatable(filename,date,filename,'');


%3.3.- profiles variables
variables = fieldnames(profiles);
%change some variable names: (see doc/structure specification)
variables_names = variables;
variables_names(ismember(variables,{'datetime'})) = {'tabs'};
variables_names(ismember(variables,{'t'})) = {'tc'};
variables_names(ismember(variables,{'m'})) = {'mode'};

XMLVars = cell(size(variables));
for ind = 1:length(variables)
    if ~isempty(profiles.(variables{ind}))
        %do not put empty vectors in XML
        [XMLVars{ind}, errorcode] = ...
            makeXMLVariable((variables_names{ind}), (profiles_units{ind}), '%f', (variables_names{ind}), profiles.(variables{ind}));
    end
end
% remove 'empty' vars:
Ie = cellfun(@isempty,XMLVars);
XMLVars = XMLVars(~Ie);

%3.4 other_cols
variables = fieldnames(other_cols);


%separate unis
[units,variables] = regexpFiltre(variables,'_units$');

%TODO: standard variable names:
new_variables = regexprep(variables,'__', '_');% remove duplicates in spaces + underscores

new_variables = regexprep(new_variables,'Step_Time', 'tp');
%     'Step_Index' , 'Step'
new_variables = regexprep(new_variables,'Step_Index' , 'Step');
%     'Cycle_Index' , 'Cycle'
new_variables = regexprep(new_variables,'Cycle_Index' , 'Cycle');
%     'Current' , 'I'
% new_variables = regexprep(new_variables,'Current' , 'I');
%     'Voltage' , 'U'
% new_variables = regexprep(new_variables,'Voltage' , 'U');
%
new_variables = regexprep(new_variables,'Aux_Voltage_' , 'U');
%
new_variables = regexprep(new_variables,'Aux_Temperature_' , 'T');

new_variables = regexprep(new_variables,'Temperature_' , 'T');

XMLVars_other = cell(size(variables));
for ind = 1:length(variables)
    if isnumeric(other_cols.(variables{ind}))
        %TODO convert cells to double, see csv2profile (try-catch)
        %TODO: make xml accept non numeric columns, or find alternative to xml 
        [XMLVars_other{ind}, errorcode] = ...
        makeXMLVariable((new_variables{ind}), other_cols.(units{ind}), '%f', (new_variables{ind}), other_cols.(variables{ind}));
    end
end
% remove 'empty' vars:
Ie = cellfun(@isempty,XMLVars_other);
XMLVars_other = XMLVars_other(~Ie);

%merge all XMLVars:
XMLVars = [XMLVars(:); XMLVars_other(:)];

[xml, errorcode] = makeXMLStruct(XMLHead, XMLMetatable, XMLVars);

end
