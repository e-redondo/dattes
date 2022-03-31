% Function: verifFomatXML4Vehlib
% Fonction de verification de structures de donnees. Elle renseigne aussi
% le champ Struct.head.version.
%
% Groupe:
%
% Lecture / ecriture de donnees en format XML
% http://lx-veh2/mediawiki/index.php/Format_XML
%
% Arguments d'appel:
%
% Struct = variable de type struct en format de travail
%
% Exemple de Struct (format de travail)
% Struct [1x1 struct]
%   head: [1x1 struct]
%       version: char
%       type: char
%       date: char
%       project: char
%       comments: char
%   table: nx1 cell {[1x1 struct] ... [1x1 struct]}
%       id: char
%       metatable: [1x1 struct]
%           name: char
%           date: char
%           sourcefile: char
%           comments: char
%       variable_1: [1x1 struct]
%       ...
%       variable_m: [1x1 struct]
%           name: char
%           unit: char
%           precision: char
%           type: char
%           longname: char
%           vector: [px1 double]
% Exemple de lancement:
% (start code)
% [Struct err] = verifFomatXML4Vehlib(Struct);
% (end)
% Resultat:
% Struct = variable de type struct en format de travail apres la
% verification (la seule difference est Struct.head.version).
% err = variable type double avec le code d'erreur:
%   0: structure valide
%   -XYZ: structure pas valide
%   Z: type d'erreur
%       -1: is not Struct
%       -2: required field is not present
%       -3: not allowed field is found
%       -4: field type is not correct
%       -5: field type is not correct
%       -6: struct length is bigger than max allowed length
%   Y: position entre freres (structures dans le meme niveau)
%   X: niveau de profondeur de la structure (0: niveau de base)
% Exemples:
%   err = -2 :  erreur en Struct (il manque un champ: head ou table)
%   err = -102 :  erreur en Struct.head (il manque un champ)
%   err = -112 :  erreur en Struct.table (il manque un champ)
%   err = -212 :  erreur en Struct.table.metatable (il manque un champ)
%   err = -1 :  erreur en Struct (ce n'est pas une structure)
%   err = -101 :  erreur en Struct.head (ce n'est pas une structure)
%   err = -111 :  erreur en Struct.table (ce n'est pas une structure)
%   err = -311 :  erreur de longueur de vecteur (variable #11 d'une des
%   tables)
%
%
% Auteur: ER
%
% Date de creation: Aout 2011
% Date de modification: Aout 2013
% ------------------------------------------------------
function [Struct err errS] = verifFomatXML4Vehlib(Struct)
version = 0.9;
%Level 0: file
%1.- file must be 1x1 struct
maxLength = 1;
%2.- 'head' and 'table' must be fields
mandatoryFields = {'head','table'};
%3.- only 'head', 'table' and 'txt' are allowed
allowedFields = {'head','table','txt'};
fieldTypes = {'struct','cell','struct'};
[err errS] = verifStruct(Struct,mandatoryFields,allowedFields,fieldTypes,maxLength);
if (err < 0)
    return;
end

%Level 1: head
%1.- head must be 1x1 struct
maxLength = 1;
%2.- 'version' 'type' and 'date' must be fields
Struct.head.version = sprintf('%.1f',version);
mandatoryFields = {'version','type','date'};
%3.- only 'version', 'date', 'project' and 'comments' are allowed
allowedFields = {'version','type','date','project','comments'};
fieldTypes = {'char','char','char','char','char'};
[err errS] = verifStruct(Struct.head,mandatoryFields,allowedFields,fieldTypes,maxLength);
if (err < 0)
    err = err-100;
    errS = sprintf('struct>head>%s',errS);
    return;
end

%Level 1bis: table
%1.- table must be cell (max number of elements 100)
maxLength = 1000;
if length(Struct.table) > maxLength
    err=-116;
    errS = sprintf('struct>table>length:%d,max:%d',length(Struct.table),maxLength);
    return;
end
%2.- 'id' 'metatable' and 'data' must be fields
mandatoryFields = {'id','metatable'};

%3.- only 'metatable' and 'data'
allowedFields = {'id','metatable',''};
fieldTypes = {'char','struct','struct'};
for ind = 1:length(Struct.table)
    [err errS] = verifStruct(Struct.table{ind},mandatoryFields,allowedFields,fieldTypes,1);
    if (err < 0)
        err = err-110;
        errS = sprintf('struct>table{%d}>%s',ind,errS);
        return;
    end
end
%Level 1ter: txt
if isfield(Struct,'txt')
    %1.- txt must be struct (max number of elements 100)
    maxLength = 100;
    %2.- 'metatable' and 'data' must be fields
    mandatoryFields = {'id','metatable','data'};
    
    %3.- only 'metatable' and 'data'
    allowedFields = {'id','metatable','data'};
    fieldTypes = {'char','struct','cell'};
    [err errS] = verifStruct(Struct.txt,mandatoryFields,allowedFields,fieldTypes,maxLength);
    if (err < 0)
        err = err-120;
        errS = sprintf('struct>txt>%s',ind,errS);
        return;
    end
end

%Level 2: table>metatable
%1.- metatable must be 1x1 struct
maxLength = 1;
%2.- 'id' 'metatable' and 'data' must be fields
mandatoryFields = {'name'};

%3.- only 'metatable' and 'data'
allowedFields = {'name','date','sourcefile','comments'};
fieldTypes = {'char','char','char','char'};
for ind=1:length(Struct.table)
    [err errS] = verifStruct(Struct.table{ind}.metatable,mandatoryFields,allowedFields,fieldTypes,maxLength);
    if (err < 0)
        err = err-210;
        errS = sprintf('struct>table{%d}>metatable>%s',ind,errS);
        return;
    end
    
end
%Level 2bis: table>variables
%1.- variable must be struct (max number of elements 1000)
maxLength = 1000;
%2.- 'name' 'type' 'unit' and 'precision' must be fields
mandatoryFields = {'name','vector'};

%3.- only 'metatable' and 'data'
allowedFields = {'name', 'type', 'unit', 'precision','longname','vector','factor','unit4Factor'};
fieldTypes = {'char','char','char','char','char','','double','char'};
% variableList
for ind=1:length(Struct.table)
    variableList = fieldnames(Struct.table{ind});
    variableList = variableList(~strcmp(variableList(:),'id') & ~strcmp(variableList(:),'metatable'));
    lengthVector = length(Struct.table{ind}.(variableList{1}).vector);
    for indb=1:length(variableList)
        [err errS] = verifStruct(Struct.table{ind}.(variableList{indb}),mandatoryFields,allowedFields,fieldTypes,maxLength);
        if (err < 0)
            err = err-220;
            errS = sprintf('struct>table{%d}>%s>%s',ind,variableList{indb},errS);
            return;
        end
        %Level 3: table>variables>vector
        %verify vector length
        thisVectorLength = length(Struct.table{ind}.(variableList{indb}).vector);
        if (thisVectorLength~=lengthVector)
            err = -indb-300;
            errS = sprintf('struct>table{%d}>%s>length:%d,length(1):%d',ind,variableList{indb},thisVectorLength,lengthVector);
            return;
        end
        
    end
    
end
%Level 2ter: txt>metatable
if isfield(Struct,'txt')
    %1.- metatable must be 1x1 struct
    maxLength = 1;
    %2.- 'id' 'metatable' and 'data' must be fields
    mandatoryFields = {'name'};
    
    %3.- only 'metatable' and 'data'
    allowedFields = {'name','date','sourcefile','type','comments'};
    fieldTypes = {'char','char','char','char','char'};
    for ind=1:length(Struct.txt)
        [err errS] = verifStruct(Struct.txt(ind).metatable,mandatoryFields,allowedFields,fieldTypes,maxLength);
        if (err < 0)
            err = err-230;
            errS = sprintf('struct>txt{%d}>metatable>%s',ind,errS);
            return;
        end
        
    end
end

err = 0;

end

function [err errS] = verifStruct(Struct,requiredFields,allowedFields,fieldTypes,maxLength)
if ~isstruct(Struct)
    err=-1;
    errS = 'Not struct';
    return;
end
for ind = 1:length(requiredFields)
    if ~isfield(Struct,requiredFields{ind})
        err=-2;
        errS = sprintf('Missing required field:%s',requiredFields{ind});
        return;
    end
end

fieldList = fieldnames(Struct);
if ~strcmp('',allowedFields(end))
    C = cell(length(allowedFields),1);
    S = cell2struct(C,allowedFields);
    for ind = 1:length(fieldList)
        if ~isfield(S,fieldList{ind})
            err=-3;
            errS = sprintf('Not allowed field:%s',fieldList{ind});
            return;
        end
    end
end
for ind = 1:length(allowedFields)
    if isfield(Struct,allowedFields{ind})
        for ind2 = 1:length(Struct)
            if ~isempty(fieldTypes{ind})
                if ~strcmp(class(Struct(ind2).(allowedFields{ind})),fieldTypes{ind})
                    err=-4;
                    errS = sprintf('Wrong class:%s must be %s',allowedFields{ind},fieldTypes{ind});
                    return;
                end
            end
        end
    end
end
if strcmp('',allowedFields(end))
    %si le nom du champ n'est pas renseigne
    %on verifie pas le nom mais le type pour tous les champs
    %qui n'ont ete verifies
    index = true(size(fieldList));
    for ind=1:length(allowedFields)
        index= index & ~strcmp(fieldList(:),allowedFields{ind});
    end
    fieldList2=fieldList(index);
    for ind = 1:length(fieldList2)
        for ind2 = 1:length(Struct)
            if ~strcmp(class(Struct(ind2).(fieldList2{ind})),fieldTypes{end})
                err=-5;
                errS = sprintf('Wrong class:%s must be %s',fieldList2{ind},fieldTypes{end});
                return;
            end
        end
    end
end
if length(Struct) > maxLength
    err=-6;
    errS = sprintf('Struct is too much long:%d (Max:%d)',length(Struct),maxLength);
    return;
end

err = 0;
errS = '';
end