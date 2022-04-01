
% Function: ecritureXMLFile4Vehlib
% Fonction d'ecriture de donnees XML format VEH
%
% Groupe:
%
% Lecture / ecriture de donnees en format XML
% http://lx-veh2/mediawiki/index.php/Format_XML
%
% Arguments d'appel:
%
% Struct = structure de donnees compatible avec le format XMLVEH
% filename : nom du fichier XML
% pathname : repertoire de stockage du fichier
%
% Exemple de lancement:
% ecritureXMLFile4Vehlib(file,'myFile.xml','d:\temp\');
%
% Auteur: ER
%
% Date de creation: Aout 2011
% Date de modification: Octobre 2011
% ------------------------------------------------------
function ecritureXMLFile4Vehlib(Struct,filename,pathname,options)
if ~exist('options','var')
    options='';
end
verbose = ismember('v',options);

if verbose
    fprintf('Ecriture de fichier ''%s''\n',filename);
end

if ~exist('pathname','var')
    pathname='';
end
fullFileName = fullfile(pathname,filename);
% filename2=regexp(fullFileName,filesep,'split');
% filename2 = filename2{end};
% if ~strcmp(filename,filename2)
%     %Construct an MException object to represent the error.
%     err = MException('mat2xml2b:notValidFileName', ...
%         'Filename must not contain file separators (%s): %s',filesep,filename);
%     %Throw the exception to stop execution and display an error message.
%     throw(err)
% end
fid=fopen(fullFileName,'w+');
if fid == -1
    %Construct an MException object to represent the error.
    err = MException('mat2xml2b:fileNotWritable', ...
        'Write error: %s',filename);
    %Throw the exception to stop execution and display an error message.
    throw(err)
end
[Struct, err, errS] = verifFomatXML4Vehlib(Struct);
% err = 0;
if err < 0
    fclose(fid);
    delete(fullFileName);%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%DELICAT (permission fichiers...?)
    %Construct an MException object to represent the error.
    err = MException('mat2xml2b:verifFomatXMLVEH', ...
        'Incompatible structure, error code: %d',err);
    %Throw the exception to stop execution and display an error message.
    display(errS)
    throw(err)
end
Struct = formatVEH2XML(Struct);
fprintf(fid,'<?xml version="1.0" encoding="utf-8"?>\n');
try
    struct2XML(fid,Struct,'file');
catch exception
    fclose(fid);
    movefile(fullFileName,[fullFileName '.broken']);%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%DELICAT (permission fichiers...?)
    %Construct an MException object to represent the error.
    err = MException('mat2xml2b:struct2XML', ...
        'Error writting file, see:''%s''',[filename '.BROKEN']);
    err = addCause(err, exception);
    %Throw the exception to stop execution and display an error message.
    throw(err)
end
fclose(fid);

if verbose
    fprintf('Ecriture de fichier ''%s'' OK\n',filename);
end
end
% ------------------------------------------------------

% Function: struct2XML
% Fonction d'eriture recursive d'une variable MATLAB en XML
%
% Groupe:
%
% Lecture / ecriture de donnees en format XML
% http://lx-veh2/mediawiki/index.php/Format_XML
%
% Arguments d'appel:
%
% fid = integer valued file identifier obtained from FOPEN
% variable = variable de type struct (recursivite), ou autre (non cell)
% tag = chaine de texte avec le nom de la varibale a ecrire
%
% Exemple de lancement:
% (start code)
% fid=fopen(filename,'w+');
% myVariable = struct;
% myVariable.project = 'myproject';
% myVariable.date = 'Day/Month/Year';
% myVariable.array = [0 1 2 3;5.1 5.2 5.3 5.4; 10 11 12 13]';
% struct2XML(fid,myVariable,'myVariable');
% (end)
% Resultat:
% Fichier XML dont le contenu est:
% <myVariable>
%   <project>myproject</project>
%   <date>Day/Month/Year</date>
%   <array>
%       <line id="1">0 5.1 10 </line>
%       <line id="2">1 5.2 11 </line>
%       <line id="3">2 5.3 12 </line>
%       <line id="4">3 5.4 13 </line>
%   </array>
% </myVariable>
%
% Auteur: ER
%
% Date de creation: Aout 2011
% ------------------------------------------------------
function struct2XML(fid,variable,tag)
if ~ischar(tag)
    %Construct an MException object to represent the error.
    err = MException('struct2XML:badTagName', ...
        'Tag name must be a string, found: %s (%s)',var2str(tag),class(tag));
    %Throw the exception to stop execution and display an error message.
    throw(err)
end
if isstruct(variable)
    for ind_i=1:1:length(variable)
        if isfield(variable,'id')
            fprintf(fid,'<%s id="%s">\n',tag,variable(ind_i).id);
        else
            fprintf(fid,'<%s>\n',tag);
        end
        fieldList=fieldnames(variable);
        for ind=1:1:length(fieldList)
            if ~strcmp(fieldList{ind},'id')
                %                 temp_var=getfield(variable(ind_i), fieldList{ind});
                temp_var=variable(ind_i).(fieldList{ind});
                struct2XML(fid,temp_var,fieldList{ind});
            end
        end
        fprintf(fid,'</%s>\n',tag);
    end
else
    if isnumeric(variable) && length(variable)>1
        fprintf(fid,'<%s>',tag);
        [writtenValues] = writeVector(fid,variable);
        if (length(variable) ~= writtenValues)
            %Construct an MException object to represent the error.
            err = MException('struct2XML:writeVector:inconsistentMatrix', ...
                'Matrix length: %d, written matrix: %d'...
                ,length(variable),writtenLines,writtenValues);
            %Throw the exception to stop execution and display an error message.
            throw(err)
        end
        fprintf(fid,'</%s>\n',tag);
    else
        writeValue(fid,variable,tag);
    end
end

end
% ------------------------------------------------------

% Function: writeValue
% Fonction d'eriture d'une variable simple (non structure) MATLAB en XML
%
% Groupe:
%
% Lecture / ecriture de donnees en format XML
% http://lx-veh2/mediawiki/index.php/Format_XML
%
% Arguments d'appel:
%
% fid = integer valued file identifier obtained from FOPEN
% value = variable de type numeric, char ou logical
% tag = chaine de texte avec le nom de la varibale a ecrire
%
% Exemple de lancement:
% (start code)
% tag='oneNumber';
% oneNumber=5.23;
% writeValue(fid,oneNumber,tag);
% tag='oneText';
% oneText= 'five twenty three';
% writeValue(fid,oneText,tag);
% (end)
%
% Resultat:
% Les lignes suivantes seront ecrites dans le fichier:
% ...(avant)
%   <oneNumber>5.23</oneNumber>
%   <oneText>'five twenty three'</oneText>
% ...(apres)
%
% Auteur: ER
%
% Date de creation: Aout 2011
% ------------------------------------------------------
function writeValue(fid,value,tag)
if ~isempty(value)
    value = var2str(value);
    value = mat2XMLstring(value);
    fprintf(fid,'<%s>%s</%s>\n',tag,value,tag);
else
    fprintf(fid,'<%s />\n',tag);
end
end

function str=var2str(variable)
if isnumeric(variable)
    str=sprintf('%.10g',variable(1));
elseif islogical(variable)
    str=sprintf('%d',variable(1));
    
elseif ischar(variable)
    str=sprintf('%s',variable);
else
    str=class(variable);
end
end
% ------------------------------------------------------

% Function: writeVector
% Fonction d'ecriture de vecteurs d'un fichier XML.
% Le vecteur sera ecrit dans le format
% <vector>1 2 3 4 5 6 7 8 9 10 ... 100 </vector>
%
% Groupe:
%
% Lecture / ecriture de donnees en format XML
% http://lx-veh2/mediawiki/index.php/Format_XML
%
% Argument d'appel:
%
% fid = integer valued file identifier obtained from FOPEN
% vector = double array
%
% Valeur de retour:
%
% writtenValues = nombre de valeurs ecrites
%
% Exemple de lancement:
% (start code)
% [writtenValues]=writeVector(fid,array)
% (end)
%
% Auteur: ER
%
% Date de creation: Octobre 2011
% ------------------------------------------------------
function [writtenValues]=writeVector(fid,vector)
writtenValues=length(vector);
fprintf(fid,'%.10g ',vector);
end
% ------------------------------------------------------

% Function: mat2XMLstring
% Fonction d'ecriture de caracteres reserves XML (< > et &).
% Pour l'instant les accents degres et autre symboles sont interdits
% (toute la partie haute du code ASCII 128-255 sera remplace par
% underscore).
%
% Groupe:
%
% Lecture / ecriture de donnees en format XML
% http://lx-veh2/mediawiki/index.php/Format_XML
%
% Argument d'appel:
%
% origstr = chaine de texte provenant du MATLAB.
%
% Valeur de retour:
%
% str = chaine de texte a ecrire dans le fichier XML.
%
% Exemple de lancement:
% (start code)
% origstr = 'five < six';
% str = mat2XMLstring(origstr)
% str =
%    'five &gt six'
% (end)
%
% Auteur: ER
%
% Date de creation: Aout 2011
% ------------------------------------------------------
function str = mat2XMLstring(origstr)
%�a marche pas avec des cellules
str = strrep(origstr, '<', '&lt');
str = strrep(str, '>', '&gt');
str = strrep(str, '&', '&amp');
str = strrep(str, sprintf('\n'), '\n');%sauts de ligne
str = strrep(str, char(176), 'deg');%symbole degres
str = strrep(str, char(181), 'u');%symbole micro
if sum(str(str>127))
    warning('xml2mat2b:XMLstring2mat','invalid character at %s',str)
    strold=str;
    str(str>127)='_';
    fprintf('Warning: %s replaced by %s\n',strold,str);
end
end
% ------------------------------------------------------

% Function: formatVEH2XML
% Fonction de conversion de structures de donnees
%
% Groupe:
%
% Lecture / ecriture de donnees en format XML
% http://lx-veh2/mediawiki/index.php/Format_XML
%
% Arguments d'appel:
%
% inStruct = variable de type struct en format de travail
%
% Exemple de inStruct (format de travail)
% inStruct [1x1 struct]
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
%
% Exemple de lancement:
% (start code)
% outStruct = formatVEH2XML(inStruct);
% (end)
% Resultat:
% outStruct = variable de type struct en format de travail
%
% Exemple de outStruct (format d'ecriture XML)
% outStruct [1x1 struct]
%   head: [1x1 struct]
%       version: char
%       type: char
%       date: char
%       project: char
%       comments: char
%   table: [nx1 struct]
%       id: char
%       metatable: [1x1 struct]
%           name: char
%           date: char
%           sourcefile: char
%           comments: char
%       variable: [mx1 struct]
%           name: char
%           unit: char
%           precision: char
%           type: char
%           longname: char
%           vector: [px1 double]
%
% Auteur: ER
%
% Date de creation: Octobre 2011
% ------------------------------------------------------
function outStruct = formatVEH2XML(inStruct)
outStruct=inStruct;
outStruct.table=struct;
outStruct.table.id='';
outStruct.table.metatable=struct;
outStruct.table.variable=struct;
for ind=1:length(inStruct.table)
    outStruct.table(ind).id = inStruct.table{ind}.id;
    outStruct.table(ind).metatable = inStruct.table{ind}.metatable;
    variableList = fieldnames(inStruct.table{ind});
    variableList = variableList(~strcmp(variableList(:),'id') & ~strcmp(variableList(:),'metatable'));
    outStruct.table(ind).variable = inStruct.table{ind}.(variableList{1});
    outStruct.table(ind).variable(1).id = num2str(1);
    variableFields = fieldnames(outStruct.table(ind).variable);
    variableFields = {variableFields{end} variableFields{1:end-1}}';
    outStruct.table(ind).variable = orderfields(outStruct.table(ind).variable,variableFields);
    for indb=2:length(variableList)
        s = inStruct.table{ind}.(variableList{indb});
        s.id=num2str(indb);
        s = orderfields(s,variableFields);
        outStruct.table(ind).variable(indb) = s;
    end
    %     outStruct.table = rmfield(outStruct.table,variableList);
end
end