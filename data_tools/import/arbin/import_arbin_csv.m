function xml = import_arbin_csv(file_in, options)
% import_arbin_xls Arbin *.CSV to VEHLIB XMLstruct converter
%
% Usage
%   xml = import_arbin_xls(file_in)
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
%   See also csv2profiles, import_arbin_res, import_arbin_xls, arbin_res2xml,
% arbin_xls2xml, arbin_csv2xml
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab:
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

%TODO: in recent versions of MITSPro, a column named CC2CV exists,
% this may indicate change of CC to CV.
verveh=2.0;

%0.-Errors:
if ~exist('options','var')
    options = '';
end

if isfolder(file_in)
    %batch mode: search all csv files in folder, then put all in a xml
    file_list = lsFiles(file_in,'.csv',true);
    xml = cellfun(@(x) import_arbin_csv(x,options),file_list,'UniformOutput',false);
    % remove empty xmls (not valid csv files):
    ind_empty = cellfun(@isempty,xml);
    xml = xml(~ind_empty);
    % merge all xml into first one
    for ind = 2:length(xml)
        xml{1} = XMLFusion(xml{1},xml{ind});
    end

    if isempty(xml)
      %no arbin file in folder
      xml = [];
    else
      %return first (merged) xml
      xml = xml{1};
    end

    return
end

if ~exist(file_in,'file')
    fprintf('import_arbin_csv: file does not exist: %s\n',file_in);
    xml = [];
    return;
end

%0.1.- Check file existance
[D F E] = fileparts(file_in);
filename = [F E];


% chrono=tic;
fid = fopen_safe(file_in);
[cycler,line1] = which_cycler(fid);
fclose(fid);

if ~strncmp(cycler,'arbin_csv',9)
    %Probably an error reading xls file:
    fprintf('WARNING: not an Arbin csv file: %s\n',file_in);
    xml = [];
    return;
end

%1.- reading file
params = struct;  % see csv2profiles if some params are needed
%params.U_thres = 0.01;
%params.I_thres = 0.1;

params.date_fmt = '';
% params.date_fmt = 'yyyy-mm-dd HH:MM:SS';
if strcmp(cycler,'arbin_csv_v1')
    col_names = {'Date_Time','Test_Time(s)','Voltage(V)','Current(A)',...
        'Step_Index','',...
        'Discharge_Capacity(Ah)','Charge_Capacity(Ah)','','','',''};
elseif strcmp(cycler,'arbin_csv_v2')
    col_names = {'Date Time','Test Time (s)','Voltage (V)','Current (A)',...
        'Step Index','',...
        'Discharge Capacity (Ah)','Charge Capacity (Ah)','','','',''};
end


[profiles, other_cols] = csv2profiles(file_in,col_names,params);
profiles_units = {'s','s','V','A','','degC','Ah',''};

%DEBUG
% [D,F,E] = fileparts(file_in);
% save(sprintf('%s.mat',F),'profiles');

%3.- creer XML
%3.1.- introduire entete:
[XMLHead, err] = makeXMLHead('arbin',date,'',sprintf('arbin_csv2xml version:%.2f',verveh));
%3.2.- metatable
[XMLMetatable, err] = makeXMLMetatable(filename,date,filename,'');


%3.3.- profiles variables
variables = fieldnames(profiles);
%change some variable names: (see doc/structure specification)
variables_names = variables;variables_names = variables;
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
[units,variables] = regexpFiltre(variables(2:end),'_units$');

%TODO: standard variable names:
new_variables = regexprep(variables,'Step_Time', 'tp');
%     'Step_Index' , 'Step'
new_variables = regexprep(new_variables,'Step_Index' , 'Step');
%     'Cycle_Index' , 'Cycle'
new_variables = regexprep(new_variables,'Cycle_Index' , 'Cycle');
%     'Current' , 'I'
new_variables = regexprep(new_variables,'Current' , 'I');
%     'Voltage' , 'U'
% new_variables = regexprep(new_variables,'Voltage' , 'U');
%
new_variables = regexprep(new_variables,'Aux_Voltage_' , 'U');
%
new_variables = regexprep(new_variables,'Aux_Temperature_' , 'T');


XMLVars_other = cell(size(variables));
for ind = 1:length(variables)
    if isnumeric(other_cols.(variables{ind}))
        %TODO convert cells to double, see csv2profile (try-catch)
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
