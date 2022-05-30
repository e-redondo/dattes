function xml = import_arbin_res(file_in)
% import_arbin_res Arbin *.RES to VEHLIB XMLstruct converter (unix)
%   xml = import_arbin_res(file_in) read filename (*.res file) and converts
%   to xml (VEHLIB XMLstruct)
%   Requirements: mdb-tools and mdb_export scripts (voir avec Eduardo)
%
%   See also importArbinTxt, importArbinXls, importBiologic, importBitrode,
%   arbin_res2xml, import_arbin_xls
%
%   IFSTTAR/LTE  - E. REDONDO
%   $Revision: 0.1 $  $Created: 2015/08/12, Modified: 2015/08/12$

if nargin==0
    print_usage
end

verveh = 2.0;

[D, F, E] = fileparts(file_in);

if ~exist(file_in,'file')
    fprintf('ERROR: file does not exist: %s\n',file_in);
    xml = [];
    return;
end

if isunix
    [A, B] = dos('which mdb-tables');
else
    [A, B] = dos('where mdb-tables');
end

if (A)
    fprintf('mdb-tools not found, please contact Eduardo\n');
    xml = [];
    return;
end
% chrono=tic;
mdb_export_tables(file_in);
% %0.-test si mdb_export_tables installe:
% [A, B] = dos('which mdb_export_tables');
% if isempty(B)
%     fprintf('importArbinRes:ERRREUR: manque script mdb_export_tables\n');
%     return;
% end
% %1.- export RES file to CSV
% myCmd = sprintf('mdb_export_tables %s',fileIn);
% [A, B] = dos(myCmd);
% %1.1.- verifier que tout s'est bien passe
% if ~isempty(B)
%     fprintf('ERROR: mdb_export_tables %s\n',fileIn);
%     xml = [];
%     return;
% end
%2.- prendre Channel_Normal_Table, lire et trier par data_point

%2.1- verifier son existence
csvFile = fullfile(D,F,'Channel_Normal_Table.csv');
if ~exist(csvFile,'file')
    fprintf('ERROR: (mdb_export_tables) file does not exist: %s\n',csvFile);
    xml = [];
    return;
end

%2.2- lire
corps = [];
fid = fopen(csvFile,'r');
tete = fgetl(fid);
tete = regexp(tete,'\s','split');
I = ~cellfun(@isempty,tete);
tete = tete(I);
corps = fscanf(fid,'%f');
fclose(fid);
corps = reshape(corps,length(tete),[])';

%2.3- trier par data_point
Dp = corps(:,2);
[Dp I] = unique(Dp);
corps = corps(I,:);

%2.4 Drop Test_ID variable (coherence with import_arbin_xls)
[~,tete,~,Ins] = regexpFiltre(tete,'Test_ID');
corps = corps(:,Ins);

if isempty(corps)
    fprintf('ERROR: (mdb_export_tables) empty resFile: %s\n',file_in);
    xml = [];
    %7.- clean temporary files (exported csv's)
    delete(fullfile(D,F,'*'));
    rmdir(fullfile(D,F));
    return;
end
fprintf('Channel_Normal_Table: %s OK\n',csvFile);

%3.- take Auxiliary_Table, read and classify by data_point
csvFile = fullfile(D,F,'Auxiliary_Table.csv');
[tete1, corps1] = read_aux_table(csvFile);

if ~isempty(corps1)
    %4.-merge Channel_Normal_Table and Auxiliary_Table
    %4.1 Check if datapoints are equal:
    if isequal(corps(:,1),corps1(:,1))
        corps = [corps, corps1(:,2:end)];
        tete = [tete, tete1(2:end)];
    else
        %if not, do not merge
        fprintf('ERROR: Data_Point and Aux_Data_Point are not equal\n');
    end
end
%5.-lire les metadonnees dans les autres fichiers csv (TODO)

%6.-construire la structure XML
%6.1.- variables:
variables = tete;
% variables = regexprep(variables,'/|\|+|-|*', '_');
variables = regexprep(variables,'\(.+)| |/','');%from import_arbin_xls
%6.2.- standardiser les noms des variables:
%     'Test_Time', 'tc'
variables = regexprep(variables,'Test_Time', 'tc');
%     'Date_Time', 'tabs'
variables = regexprep(variables,'DateTime', 'tabs');
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

%6.3.- unites de mesure (TODO: pas d'info dans les fichiers)
units = cell(size(tete));
[units{:}] = deal('');%remplit de chaines vides
I = ~cellfun(@isempty,strfind(tete,'Voltage'));
[units{I}] = deal('V');
I = ~cellfun(@isempty,strfind(tete,'Time'));
[units{I}] = deal('s');
I = ~cellfun(@isempty,strfind(tete,'Current'));
[units{I}] = deal('A');
I = ~cellfun(@isempty,strfind(tete,'Capacity'));
[units{I}] = deal('Ah');
I = ~cellfun(@isempty,strfind(tete,'Energy'));
[units{I}] = deal('Wh');
I = ~cellfun(@isempty,strfind(tete,'dV/dt'));
[units{I}] = deal('V/s');
I = ~cellfun(@isempty,strfind(tete,'Temperature'));%TODO search in Aux_Global_Table
[units{I}] = deal('C');
%6.4.1.- introduire entete:
[XMLHead, err] = makeXMLHead('arbin',date,'',sprintf('ArbinRes2VEH version:%.2f',verveh));

%6.4.2.- metatable
[XMLMetatable, err] = makeXMLMetatable(F,date,sprintf('%s%s',F,E),'');

%variables et unites
XMLVars = cell(size(variables));
for ind = 1:length(variables)
    [XMLVars{ind}, err] = ...
        makeXMLVariable((variables{ind}), (units{ind}), '%f', (variables{ind}), corps(:,ind));
end


[xml, err] = makeXMLStruct(XMLHead, XMLMetatable, XMLVars);
%6.5.- tabs = m2edate(x2mdate(A(:,indice_dateTime)));
tabs = xml.table{end}.tabs.vector;
xml.table{end}.tabs.vector = m2edate(x2mdate(tabs));
%6.6.- mode
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
%6.7: Qc (redondant avec extractBanc)
% Qc = calculAh(t,I);
% xml.table{end}.Qc = makeXMLVariable('Qc', 'Ah', '%f', 'AmpHeure Cumul', Qc);

% pause(0.1);
% tecoule = toc(chrono);
% fprintf('fichier pret en %0.2f secondes.\n',tecoule);

%met les variables dans l'ordre
xml.table{end} = sort_bench_variables(xml.table{end});
%7.- clean temporary files (exported csv's)
delete(fullfile(D,F,'*'));
rmdir(fullfile(D,F));
end

function [tete1, corps1] = read_aux_table(csvFile)

if ~exist(csvFile,'file')
    fprintf('ERROR: (mdb_export_tables) file does not exist: %s\n',csvFile);
    corps1 = [];
    tete1 = [];
    return;
end

%1. read the file
fid = fopen(csvFile,'r');
tete1 = fgetl(fid);
tete1 = regexp(tete1,'\s','split');
I = ~cellfun(@isempty,tete1);
tete1 = tete1(I);
corps1 = fscanf(fid,'%f');
fclose(fid);

if isempty(corps1)
    corps1 = [];
    tete1 = [];
    return;
end

corps1 = reshape(corps1,length(tete1),[])';


%2. reorganize variables into struct:
r = struct();
for ind = 1:length(tete1)
r.(tete1{ind}) = corps1(:,ind);
end

result = struct();
Aux_index = unique(r.Auxiliary_Index);
Dp_all = [];
%Aux Voltages:
for ind = 1:length(Aux_index)
    Is = r.Auxiliary_Index==Aux_index(ind) & r.Data_Type==0;
    V = r.X(Is);
    Dp = r.Data_Point(Is);
    %sort by datapoint:
    [Dp, Is] = unique(Dp);
    V = V(Is);
    if ~isempty(V)
        result.(sprintf('Aux_Voltage_%d',Aux_index(ind)+1)) = V;
        result.(sprintf('Aux_Voltage_%d_dp',Aux_index(ind)+1)) = Dp;
        result.(sprintf('Aux_Voltage_%d_unit',Aux_index(ind)+1)) = 'V';
        
    end
    Dp_all = [Dp_all;Dp];
end
%Temperatures:
for ind = 1:length(Aux_index)
    Is = r.Auxiliary_Index==Aux_index(ind) & r.Data_Type==1;
    V = r.X(Is);
    Dp = r.Data_Point(Is);
    %sort by datapoint:
    [Dp, Is] = unique(Dp);
    V = V(Is);
    if ~isempty(V)
        result.(sprintf('Temperature_%d',Aux_index(ind)+1)) = V;
    result.(sprintf('Temperature_%d_dp',Aux_index(ind)+1)) = Dp;
    result.(sprintf('Temperature_%d_unit',Aux_index(ind)+1)) = 'C';
        
    end
    Dp_all = [Dp_all;Dp];
end
%Digital:
for ind = 1:length(Aux_index)
    Is = r.Auxiliary_Index==Aux_index(ind) & r.Data_Type==7;
    V = r.X(Is);
    Dp = r.Data_Point(Is);
    %sort by datapoint:
    [Dp, Is] = unique(Dp);
    V = V(Is);
    if ~isempty(V)
        result.(sprintf('DigitalOutput_%d',Aux_index(ind)+1)) = V;
        result.(sprintf('DigitalOutput_%d_dp',Aux_index(ind)+1)) = Dp;
        result.(sprintf('DigitalOutput_%d_unit',Aux_index(ind)+1)) = '';
    end
    Dp_all = [Dp_all;Dp];
end

%3. convert back struct to corps1, tete1:
fieldList = fieldnames(result);
[tete1, ~, Is] = regexpFiltre(fieldList','[0-9]$');
Is = find(Is);

variables = fieldList(Is);

%3.1 check datapoints all equal (no missing data)
Dp_unique = unique(Dp_all);
for ind = 1:length(variables)
    dp_variable = sprintf('%s_dp',variables{ind});
    if ~isequal(result.(dp_variable),Dp_unique)
        fprintf('ERROR in Aux Data, missing points\n');
        corps1 = [];
        tete1 = [];
        return
    end
end
%3.2 No error >> concatenate data:
tete1 = [{'Data_Point_Aux'}, tete1];
corps1 = Dp_unique;
for ind = 1:length(Is)
corps1(:,end+1) = result.(fieldList{Is(ind)});
end

end