% Function: lectureXMLFile4Vehlib
% Fonction de lecture de donnees XML format VEH
%
% Groupe:
%
% Lecture / ecriture de donnees en format XML
% http://lx-veh2/mediawiki/index.php/Format_XML
%
% Argument d'appel:
%
% filename = chaine de texte indicant le nom du fichier a lire
% pathname = chaine de texte indicant le chemin du fichier a lire
% oldStruct = structure de donnees compatible avec XML (optionnel)
% 
% Valeur de retour:
%
% Struct = structure de donnees compatible avec XML
%
% Exemple de lancement: 
% xmlStruct = lectureXMLFile4Vehlib('myFile.xml','d:\temp\');
%
% Si oldStruct est une structure valide les informations y presentes seront
% transmises a la structure de retour en ajoutant les donnees contenues
% dans le fichier XML.
%
% Si aucune structure  est passee comme 3eme argument ou oldStruct est une
% structure non valide, la valeur retournee est une nouvelle structure XML.
%
% Auteur: ER
%
% Date de creation: Aout 2011
% Date de modification: Avril 2015
% ------------------------------------------------------
function Struct=lectureXMLFile4Vehlib(filename,pathname,oldStruct)
% fprintf('Lecture de fichier ''%s''\n',filename);
if ~exist('pathname','var')
    pathname='';
end
if ~exist('oldStruct','var')
    oldStruct = [];
end
fullFileName = fullfile(pathname,filename);

if ~exist(fullFileName,'file')
    %Construct an MException object to represent the error.
    err = MException('xml2mat2b:fileNotFound', ...
        'File not found: %s',fullFileName);
    %Throw the exception to stop execution and display an error message.
    throw(err)
end

fid=fopen(fullFileName);
myLine='';
lineNr=0;
while ~strcmp(myLine,'<file>')
    myLine=fgetl(fid);
    lineNr=lineNr+1;
    if lineNr>=10
        %Construct an MException object to represent the error.
        err = MException('xml2mat2b:notValidFile', ...
            'Not a valid XML file: \n%s',filename);
        %Store any information contributing to the error.
        errCause = MException('xml2mat2b:noRootTag', ...
            '<file> not found at %d first lines',lineNr);
        err = addCause(err, errCause);
        %Throw the exception to stop execution and display an error message.
        throw(err)
    end
end

newStruct = struct;

try
    [childTags childValues] = xml2struct(fid);
    fclose(fid);
catch exception
    fclose(fid);
    %Construct an MException object to represent the error.
    err = MException('xml2mat2b:notValidFile', ...
        'Not a valid XML file: \n%s',filename);
    err = addCause(err, exception);
    %Throw the exception to stop execution and display an error message.
    throw(err)
end

for ind=1:1:length(childTags)
    if isfield(newStruct,childTags{ind})
        newStruct.(childTags{ind})(end+1)=childValues{ind};
    else
        newStruct.(childTags{ind})=childValues{ind};
    end
end
newStruct = formatXML2VEH(newStruct);
[newStruct err] = verifFomatXML4Vehlib(newStruct);
if err < 0
    %Construct an MException object to represent the error.
    err = MException('xml2mat2b:verifFomatXMLVEH', ...
        'Incompatible structure, error code: %d',err);
    %Throw the exception to stop execution and display an error message.
    throw(err)
end

%structure fusion
[Struct, err, errS] = XMLFusion(oldStruct,newStruct);


end
% ------------------------------------------------------

% Function: xml2struct
% Fonction de lecture recursive d'un fichier XML
%
% Groupe:
%
% Lecture / ecriture de donnees en format XML
% http://lx-veh2/mediawiki/index.php/Format_XML
%
% Argument d'appel:
%
% fid = integer valued file identifier obtained from FOPEN
%
% Valeur de retour:
%
% Tags = cell array de chaines de texte avec les noms de variables trouvees
% Values = cell array avec les variables trouves (type struct, double ou
% char)
%
% Exemple de lancement: 
% (start code)
% myFile = filename('d:\temp\myFile.xml');
% fid = fopen(filename);
% [myTags myValues] = xml2struct(fid)
% (end)
%
% Auteur: ER
%
% Date de creation: Aout 2011
% ------------------------------------------------------
function [Tags Values] = xml2struct(fid)
%fonction qui prend la ligne suivante et retourne un tag et une valeur
myLine=fgetl(fid);
Tags=cell(0);
Values=cell(0);
% tag='';
% value='';
while ischar(myLine)
    try
        [lineType tag value] = analyseLine(myLine);
        %             catch exception
        %                 throw(exception);
        %             end
    catch exception
        %Construct an MException object to represent the error.
        err = MException(sprintf('xml2struct:%s',exception.identifier),...
            '%s',exception.message);
        err = addCause(err, exception);
       %Throw the exception to stop execution and display an error message.
        throw(err)
    end
    
    
    %         disp(sprintf(' type %i:%s',lineType,myLine));
    switch lineType
        case 0 %ligne speciale
            return;
        case 1 %<tag>
            
            value=struct;
            try
                [childTags childValues]=xml2struct(fid);
                %             catch exception
                %                 throw(exception);
                %             end
            catch exception
                %Construct an MException object to represent the error.
                err = MException(sprintf('xml2struct:%s',exception.identifier),...
                    '');
                err = addCause(err, exception);
                %Throw the exception to stop execution and display an error message.
                throw(err)
            end
            %             if ((length(childTags)==1) && strcmp(childTags{1},'variable'))
            %                 value=childValues{1};
            %             else
            for ind=1:1:length(childTags)
                if isfield(value,childTags{ind})
                    value.(childTags{ind})(end+1)=childValues{ind};
                else
                    value.(childTags{ind})=childValues{ind};
                end
            end
            %%%cast pour mettre le vecteur au format desire
            if isfield(value,'vector')
                %type entier (int16,int8 et uint8)
                if strcmpi(value.type,'int16')
                    value.vector=int16(value.vector);
                elseif strcmpi(value.type,'int8')
                    value.vector=int8(value.vector);
                elseif strcmpi(value.type,'uint8')
                    value.vector=uint8(value.vector);
                    %type booleen (logical)
                elseif strcmpi(value.type,'logical')
                    value.vector=logical(value.vector);
                    %type single (4bytes, 32bits)
                elseif strcmpi(value.type,'single')
                    value.vector=single(value.vector);
                end
            end
            %%%
            %             end
        case 2 %value
            % on ne fait rien tout est fait par analyseLine
            % ne pas effacer pour faire le break
        case 3 %</tag>
            return; % sortie de recursivite
        case 4 %<tag>value</tag>
            % on ne fait rien tout est fait par analyseLine
            % ne pas effacer pour faire le break
            if(strcmp(tag,'vector'))
                %                 disp('c''est un vecteur')
                value = readVector(myLine);
            end
        case 5 %<tag.../>
            value=assignAttrib(myLine);
        case 6 %<tag...>
            %find attributes
            value=assignAttrib(myLine);
            %find children
            try
                [childTags childValues]=xml2struct(fid);
                %             catch exception
                %                 throw(exception);
                %             end
            catch exception
                %Construct an MException object to represent the error.
                err = MException(sprintf('xml2struct:%s',exception.identifier),...
                    '');
                err = addCause(err, exception);
                %Throw the exception to stop execution and display an error message.
                throw(err)
            end
            
            for ind=1:1:length(childTags)
                if isfield(value,childTags{ind})
                    value.(childTags{ind})(end+1)=childValues{ind};
                else
                    value.(childTags{ind})=childValues{ind};
                end
            end
            %%%cast pour mettre le vecteur au format desire
            if isfield(value,'vector')
                %type entier (int16,int8 et uint8)
                if strcmpi(value.type,'int16')
                    value.vector=int16(value.vector);
                elseif strcmpi(value.type,'int8')
                    value.vector=int8(value.vector);
                elseif strcmpi(value.type,'uint8')
                    value.vector=uint8(value.vector);
                    %type booleen (logical)
                elseif strcmpi(value.type,'logical')
                    value.vector=logical(value.vector);
                    %type single (4bytes, 32bits)
                elseif strcmpi(value.type,'single')
                    value.vector=single(value.vector);
                end
            end
            %%%
        case 7%<tag attr="..." ...>value</tag>
            if(strcmp(tag,'vector'))
                %                 disp('c''est une matrice')
                value = readVector(myLine);
            else
                %find attributes
                value=assignAttrib(myLine);
            end
        otherwise %type non valide
            return;
    end
    %find brothers
    Tags=[Tags {tag}];
    Values=[Values {value}];
    
    myLine=fgetl(fid);
end
end
% ------------------------------------------------------

% Function: assignAttrib
% Fonction de lecture d'attribut d'une ligne de texte XML
%
% Groupe:
%
% Lecture / ecriture de donnees en format XML
% http://lx-veh2/mediawiki/index.php/Format_XML
%
% Argument d'appel:
%
% textLine = chaine de texte
%
% Valeur de retour:
%
% s = structure
%
% Exemple de lancement: 
% (start code)
% textLine = '<book category="CHILDREN" title="Harry Potter" year="2005">';
% s = assignAttrib(textLine)
%
% s = 
%
%   category: 'CHILDREN'
%      title: 'Harry Potter'
%       year: '2005'
% (end)
%
% Auteur: ER
%
% Date de creation: Aout 2011
% ------------------------------------------------------
function s = assignAttrib(textLine)
EqualTag=regexp(textLine,'=');

if isempty(EqualTag)
    s='';%element vide
    return;
else
    
    s=struct;
end

Values=regexp(textLine,'"','split');
Values=Values(2:2:end);
% Values = XMLstring2mat(Values);
Values = cellfun(@XMLstring2mat,Values,'UniformOutput', false);
Tags=regexp(textLine, ' (\w+)?=', 'tokens');
Tags = cat(2, Tags{:});

for ind=1:1:length(EqualTag)
    %     Tag=textLine(SpaceTag(ind)+1:EqualTag(ind)-1);
    %     Value=textLine(CoteTag(1,ind)+1:CoteTag(2,ind)-1);
    s.(Tags{ind})= Values{ind};
end

end
% ------------------------------------------------------

% Function: readVector
% Fonction de lecture de vecteurs d'un fichier XML.
% Les vecteurs XML doivent etre du format:
% <vector>1 2 3 4 5 6 7 8 9 10 ... 100 </vector>
%
% Groupe:
%
% Lecture / ecriture de donnees en format XML
% http://lx-veh2/mediawiki/index.php/Format_XML
%
% Argument d'appel:
%
% textLine = chaine de texte
%
% Valeur de retour:
%
% v = double array
%
% Exemple de lancement: 
% (start code)
% m = readVector(textLine)
% (end)
%
% Auteur: ER
%
% Date de creation: Octobre 2011
% ------------------------------------------------------
function v = readVector(textLine)

StartTag=regexp(textLine,'<');
EndTag=regexp(textLine,'>');
value=textLine(EndTag(1)+1:StartTag(end)-1);
v = sscanf(value,'%f ');

end
% ------------------------------------------------------

% Function: analyseLine
% Fonction d'analyse des lignes d'un fichier XML.
% Determine le type de ligne XML:
% XML line types: (has children, has value, has attributes)
% 1) <tag> (yes, no, no)
% 2)value (no,yes,no)
% 3)</tag> (no,no,no)
% 4)<tag>value</tag> (no,yes,no)
% 5)<tag attr="..." .../> (no,no,yes)
% 6)<tag  attr="..." ...> (yes,no,yes)
% 7)<tag  attr="..." ...>value</tag> (no,yes,yes)
%__________________________________
%no other XML line type are allowed
%__________________________________
%
%
% Groupe:
%
% Lecture / ecriture de donnees en format XML
% http://lx-veh2/mediawiki/index.php/Format_XML
%
% Argument d'appel:
%
% textLine = chaine de texte
%
% Valeur de retour:
%
% out = double 1 a 7 selon le type de ligne
% tag = chaine de texte avec le tag
% value = chaine de texte avec la valeur de l'element
% THROW ERROR IF NOT RECOGNIZED LINE
%
% Exemple (1): 
% (start code)
% textLine = '<book category="CHILDREN" title="Harry Potter" year="2005">';
% [out tag value] = analyseLine(textLine)
% out =
% 
%      6
% 
% 
% tag =
% 
% book
% 
% 
% value =
% 
%      ''
% 
% (end)
%
% Exemple (2): 
% (start code)
% textLine = '<book>Harry Potter</book>';
% [out tag value] = analyseLine(textLine)
% out =
% 
%      2
% 
% 
% tag =
% 
% book
% 
% 
% value =
% 
% Harry Potter
% 
% (end)
%
% Auteur: ER
%
% Date de creation: Aout 2011
% ------------------------------------------------------
function [out tag value] = analyseLine(textLine)

StartTag=regexp(textLine,'<');
st=length(StartTag);

tag='';
value='';

EndTag=regexp(textLine,'>');
et=length(EndTag);
if (st>et)
%     out=-1;%non ended tag
    %Construct an MException object to represent the error.
    err = MException('analyseLine:nonEndedTag', ...
        'Error in line: \n%s\n(non ended tag).',textLine);
    
    %Throw the exception to stop execution and display an error message.
    throw(err)
%     return;
elseif (et>st)
%     out=-2;%non started tag
    %Construct an MException object to represent the error.
    err = MException('analyseLine:nonStartedTag', ...
        'Error in line: \n%s\n(non started tag).',textLine);
    
    %Throw the exception to stop execution and display an error message.
    throw(err)
%     return;
end

EndElement=regexp(textLine,'/');
EndElement=EndElement((EndElement>StartTag(end)) | EndElement<EndTag(1));
ee=length(EndElement);
if (ee > 1)
%     out=-3;%double ended element
    %Construct an MException object to represent the error.
    err = MException('analyseLine:doubleEndedElement', ...
        'Error in line: \n%s\n(double ended tag).',textLine);
    
    %Throw the exception to stop execution and display an error message.
    throw(err)
%     return;
end

%type 2
if isempty(StartTag)
    value=textLine;
    value = XMLstring2mat(value);
    out=2;
    return;
end

% AttributIndex=regexp(textLine,' ');
AttributIndex=find(textLine==' ');
AttributIndex=AttributIndex((AttributIndex>StartTag(1)) & (AttributIndex<EndTag(1)));

switch st
    %case 0 traited with isempty(StartTag) > out = 2
    case 1 %type 1 3 5 or 6
        if ee==0 %type 1 or 6
            if isempty(AttributIndex)
                tag=textLine(StartTag(1)+1:EndTag(1)-1);
                out=1;
            else
                tag=textLine(StartTag(1)+1:AttributIndex(1)-1);
                out=6;
            end
        else%type 3 or 5
            if isempty(AttributIndex)
                out=3;
            else
                tag=textLine(StartTag(1)+1:AttributIndex(1)-1);
                out=5;
            end
        end
        
    case 2 %type 4 or 7
        if isempty(AttributIndex)
            tag=textLine(StartTag(1)+1:EndTag(1)-1);
            value=textLine(EndTag(1)+1:StartTag(2)-1);
            value = XMLstring2mat(value);
            out=4;
        else
            tag=textLine(StartTag(1)+1:AttributIndex(1)-1);
            value=textLine(EndTag(1)+1:StartTag(2)-1);
            value = XMLstring2mat(value);
            out=7;
        end
        
    otherwise
%         out=-1;
        %Construct an MException object to represent the error.
        err = MException('analyseLine:noValidLine', ...
            'Not recognized XML line: \n%s\n',textLine);
        
        %Throw the exception to stop execution and display an error message.
        throw(err)
end

end
% ------------------------------------------------------

% Function: XMLstring2mat
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
% origstr = chaine de texte provenant du fichier XML.
%
% Valeur de retour:
%
% str = chaine de texte a ecrire dans la variable MATLAB.
%
% Exemple de lancement: 
% (start code)
% origstr = 'five &gt six';
% str = mat2XMLstring(origstr)
% str = 
%    'five < six'
% (end)
%
% Auteur: ER
%
% Date de creation: Aout 2011
% ------------------------------------------------------
function str = XMLstring2mat(origstr)
%ca marche pas avec des cellules
str = strrep(origstr, '&lt', '<');
str = strrep(str, '&gt', '>');
str = strrep(str, '&amp', '&');
if sum(str(str>127))
    warning('xml2mat2b:XMLstring2mat','invalid character at %s',str)
    strold=str;
    str(str>127)='_';
    fprintf('Warning: %s replaced by %s\n',strold,str);
end
end
% ------------------------------------------------------

% Function: formatXML2VEH
% Fonction de conversion de structures de donnees. Elle prend une structure
% en format XML et retourne la structure equivalente en format de travail.
% La principale difference est que table est une cell array en format de
% travail et une struct en format XML. Les variables sont accesibles par
% son nom dans le format de travail (maStruct.table{ind}.maVariable.vector)
% en format XML les variables sont accesibles comme ceci:
% maStruct.table(ind).variable(ind2).vector.
%
% Groupe:
%
% Lecture / ecriture de donnees en format XML
% http://lx-veh2/mediawiki/index.php/Format_XML
%
% Arguments d'appel:
%
% inStruct = variable de type struct en format XML
%
% Exemple de inStruct (format XML)
% inStruct [1x1 struct]
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
% Exemple de lancement:
% (start code)
% outStruct = formatXML2VEH(inStruct);
% (end)
% Resultat:
% outStruct = variable de type struct en format de travail
%
% Exemple de outStruct (format de travail)
% outStruct [1x1 struct]
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
% Auteur: ER
%
% Date de creation: Octobre 2011
% ------------------------------------------------------
function outStruct = formatXML2VEH(inStruct)
for ind=1:length(inStruct.table)
    inStruct.table(ind).variable = rmfield(inStruct.table(ind).variable,'id');
end
outStruct=inStruct;
outStruct.table=cell(size(inStruct.table));
for ind=1:length(inStruct.table)
    outStruct.table{ind} = rmfield(inStruct.table(ind),'variable');
    for indb=1:length(inStruct.table(ind).variable)
        outStruct.table{ind}.(inStruct.table(ind).variable(indb).name)=inStruct.table(ind).variable(indb);
    end
end
end