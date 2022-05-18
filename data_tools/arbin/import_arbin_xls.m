function xml = import_arbin_xls(fileIn)
% importArbinXls Arbin *.XLS to VEHLIB XMLstruct converter (windows)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Nom              : importArbinXls.m
%
%Language         : MATLAB R2010b
%Auteur           : IFSTTAR/LTE - E. REDONDO
%
%Date de creation : fevrier 2015
%
%Sujet            : conversion des fichiers du banc Arbin (*.xls)
%                   au format XMLstruct de VEHLIB
%Version          : 2.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
verveh = 2.0;
%0.-Erreurs:
%0.1.- verifier existance du fichier
[D F E] = fileparts(fileIn);
filename = [F E];

if ~exist(fileIn,'file')
    fprintf('ERROR: file does not exist: %s\n',fileIn);
    xml = [];
    return;
end
% chrono=tic;
fprintf('Lecture des metadonnees du fichier xls: %s...',filename);
[st, sheets, fo] = xlsfinfo(fileIn);

if ~iscell(sheets)
    %Probably an error reading xls file:
    fprintf('ERROR: unreadable xls file?: %s\n',fileIn);
    xml = [];
    return;
end
% dataSheets = sheets(~(cellfun(@isempty,regexp(sheets,'^Channel'))));
dataSheets = sheets;
% if length(dataSheets)>1
%     noSheets = regexp(dataSheets,'_[0-9]$','match','once');
%     channels = regexprep(dataSheets,noSheets,'');
%     
%     %0.2.- compatibilite du fichier (nb de feuilles)
%     if length(unique(channels))~=1
%         fprintf('ERROR in %s, voici les feuilles trouvees:\n',fileIn);
%         fprintf('%s\n',sheets{:});
%         xml = [];
%         return;
%     end
%     noSheets = strrep(noSheets,'_','');
%     noSheets = cellfun(@(x) sscanf(x,'%f'),noSheets);
%     [noSheets, I] = sort(noSheets);
%     dataSheets = dataSheets(I);%met dans l'ordre
% end
fprintf('OK, %d feuilles\n',length(sheets));

%1.- lecture du fichier
fprintf('Lecture du fichier xls: %s...',filename);
% [A, tete, r] = xlsread(fileIn,dataSheets{1});
% if isnan(A(2,3))
%     I = strcmp(tete(1,:),'Date_Time');
%     datetime = tete(2:end,I);
% %     dateNum = m2xdate(datenum(datetime,'dd/mm/yyyy HH:MM:SS'));
% %     A(:,I) = dateNum;
%     tete = tete(1,:);%probleme des dates a regler TODO BRICOLE....
% end
% fprintf('feuille %d: %d lignes\n',1,size(A,1));
% for ind = 2:length(dataSheets)
%     A1 = xlsread(fileIn,dataSheets{ind});
%     fprintf('feuille %d: %d lignes\n',ind,size(A1,1));
%     A = [A;A1];
% end

%read all datasheets
[data, header, ~] = cellfun(@(x) xlsread(fileIn,x),dataSheets,'UniformOutput',false);
%remove sheets with empty header:
Is = ~cellfun(@isempty, header);
data = data(Is);
header = header(Is);
%keep only sheets with first header variable == 'Data_Point'
Is = cellfun(@(x) strcmp(x{1,1},'Data_Point'),header);
data = data(Is);
header = header(Is);

if isempty(header)
    fprintf('ERROR: no data found in %s\n',fileIn);
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
% m = modeBanc(t,I,U,seuilI,seuilU);
m = mode_bench2(t,I,U,Step,seuilI,seuilU);
mode = makeXMLVariable('mode','', '%f','mode', m);
xml.table{end}.mode = mode;

%met les variables dans l'ordre
xml.table{end} = sort_bench_variables(xml.table{end});

end
