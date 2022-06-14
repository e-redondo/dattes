function xml = import_arbin_xls(file_in)
% import_arbin_xls Arbin *.XLS to VEHLIB XMLstruct converter 
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
%   See also importArbinTxt, importArbinXls, importBiologic, importBitrode,
%   arbin_res2xml, import_arbin_res
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

verveh=2.0;

%0.-Errors:
%0.1.- Check file existance
[D F E] = fileparts(file_in);
filename = [F E];

if ~exist(file_in,'file')
    fprintf('import_arbin_xls: file does not exist: %s\n',file_in);
    xml = [];
    return;
end
% chrono=tic;
fprintf('Lecture des metadonnees du fichier xls: %s...',filename);
[st, sheets, fo] = xlsfinfo(file_in);

if ~iscell(sheets)
    %Probably an error reading xls file:
    fprintf('ERROR: unreadable xls file?: %s\n',file_in);
    xml = [];
    return;
end
dataSheets = sheets;

fprintf('OK, %d feuilles\n',length(sheets));

%1.- lecture du fichier
fprintf('Lecture du fichier xls: %s...',filename);

%read all datasheets
[data, header, ~] = cellfun(@(x) xlsread(file_in,x),dataSheets,'UniformOutput',false);
%remove sheets with empty header:
Is = ~cellfun(@isempty, header);
data = data(Is);
header = header(Is);
%keep only sheets with first header variable == 'Data_Point'
Is = cellfun(@(x) strcmp(x{1,1},'Data_Point'),header);
data = data(Is);
header = header(Is);

if isempty(header)
    fprintf('ERROR: no data found in %s\n',file_in);
     xml = [];
    return
end
header = header{1};
data = vertcat(data{:});

Dp = data(:,1);%datapoint column
[Dp, I] = unique(Dp);%sort and remove duplicates
data = data(I,:);
fprintf('OK, %d lignes, %d colonnes\n',size(data));

%2.- entete
%2.1.- unites de mesure
units = regexp(header,'\(.+)','match','once');
units = regexprep(units,'\(','');
units = regexprep(units,')','');
%other units
I = ~cellfun(@isempty,strfind(header,'Voltage'));
[units{I}] = deal('V');
I = ~cellfun(@isempty,strfind(header,'Time'));
[units{I}] = deal('s');
I = ~cellfun(@isempty,strfind(header,'Current'));
[units{I}] = deal('A');
I = ~cellfun(@isempty,strfind(header,'Capacity'));
[units{I}] = deal('Ah');
I = ~cellfun(@isempty,strfind(header,'Energy'));
[units{I}] = deal('Wh');
I = ~cellfun(@isempty,strfind(header,'dV/dt'));
[units{I}] = deal('V/s');
I = ~cellfun(@isempty,strfind(header,'Temperature'));%TODO search in Aux_Global_Table
[units{I}] = deal('C');
%change fractions to underscores:
unites = regexprep(units,'/','_');

%2.2.- noms des variables
variables = regexprep(header,'\(.+)| |/','');
%2.3.- standardiser les noms des variables:
%
%     'Test_Time', 'tc'
variables = regexprep(variables,'Test_Time', 'tc');
%     'Date_Time', 'tabs'
variables = regexprep(variables,'Date_Time', 'tabs');
%     'Step_Time', 'tp'
variables = regexprep(variables,'Step_Time', 'tp');
%     'Step_Index' , 'Step'
variables = regexprep(variables,'Step_Index' , 'Step');
%     'Cycle_Index' , 'Cycle'
variables = regexprep(variables,'Cycle_Index' , 'Cycle');
%     'Current' , 'I'
variables = regexprep(variables,'Current' , 'I');
%     'Voltage' , 'U'
variables = regexprep(variables,'Voltage' , 'U');
%     'Charge_Capacity'
%     'Discharge_Capacity'
%     'Charge_Energy'
%     'Discharge_Energy'
%     'dVdt'
%     'Internal_Resistance'
%     'Is_FC_Data'
%     'AC_Impedance'
%     'ACI_Phase_Angle'
%     'Aux_Voltage_1' , 'V1'
variables = regexprep(variables,'Aux_Voltage' , 'V');

%3.- creer XML
%3.1.- introduire entete:
[XMLHead, err] = makeXMLHead('arbin',date,'',sprintf('ArbinXls2VEH version:%.2f',verveh));
%3.2.- metatable
[XMLMetatable, err] = makeXMLMetatable(filename,date,filename,'');
%3.3.- variables et unites
XMLVars = cell(size(variables));
for ind = 1:length(variables)
    [XMLVars{ind}, errorcode] = ...
        makeXMLVariable((variables{ind}), (unites{ind}), '%f', (variables{ind}), data(:,ind));
end

[xml, errorcode] = makeXMLStruct(XMLHead, XMLMetatable, XMLVars);

%3.4.- tabs = m2edate(x2mdate(A(:,indice_dateTime)));
tabs = xml.table{end}.tabs.vector;
xml.table{end}.tabs.vector = m2edate(x2mdate(tabs));
%3.5.- mode
% t = xml.table{end}.tabs.vector;
t = xml.table{end}.tc.vector;
U = xml.table{end}.U.vector;
I = xml.table{end}.I.vector;
Step =  xml.table{end}.Step.vector;
seuilI = 0.010;
seuilU = 0.010;

m = which_mode(t,I,U,Step,seuilI,seuilU);
mode = makeXMLVariable('mode','', '%f','mode', m);
xml.table{end}.mode = mode;

%met les variables dans l'ordre
xml.table{end} = sort_cycler_variables(xml.table{end});

end
