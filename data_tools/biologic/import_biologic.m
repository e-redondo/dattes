function [outStruct, err, errS] = import_biologic(dirname)
%import_biologic converts *.mpt files (Biologic) in *.xml.
%   [outStruct, err, errS] = import_biologic(dirname)
%   Inputs:
%   - dirname [string]: folder containing *.mpt files
%   - dirname [cell string]: file list to convert
%   Outputs:
%   - outStruct: XML structure in VEHLIB format
%   - err [(1x1) double]: error code (==0 => OK, ~=0 => error)
%   - errS [string]: error descirption
%   Examples:
%   1) [outStruct, err, errS] = import_biologic(dirname) : search for mpt
%   files in dirname and convert them into *.xml
%   2) [outStruct, err, errS] = import_biologic(filelist) : convert every
%   *.mpt in filelist
%   3) [outStruct, err, errS] = import_biologic({filename}) : convert just
%   one *.mpt file (put filename into a cell string)
%
%   See also: mpt2xml, biologic_mpt2xml_folders, which_bench
%
%   IFSTTAR/LTE  - E. REDONDO
%   $Revision: 0.1 $  $Created: 2012$
if nargin==0
    print_usage;
end

%1.-trouver les fichiers MPT
if iscell(dirname)
    fileList = dirname;
    %01 verification de l'existence des fichiers
    indices = cellfun(@(x) exist(x,'file')==2,fileList);
    fileList = fileList(indices);
else
    %01 verification de l'existence du repertoire
    if ~isdir(dirname)
        err = -1;
        fprintf('Inexistent directory: %s\n',dirname);
        if err
            outStruct = [];
            return
        end
    end
    %1 Search
    D = lsFiles(dirname,'.mpt',true);
    %11 verification de l'existence des fichiers
    if isempty(D)
        D = lsFiles(dirname,'.txt',true);
        if isempty(D)
            err = -1;
            fprintf('Nothing to import: %s\n',dirname);
            if err
                outStruct = [];
                return
            end
        end
    end
    fileList = D;
end
fprintf('Found %d files\n',length(fileList));
%2 Lecture des fichiers
corps =cell(size(fileList));
tete = cell(size(fileList));
for ind = 1:length(fileList)
    fprintf('Reading %d of %d ',ind,length(fileList));
    %ouvrir le fichier
    % %     nomFichier = fullfile(dirname,fileList);
    thisFile = fileList{ind};
    fid = fopen(thisFile,'r');
    if fid>0
        %lire fichier
        [tete{ind}, corps{ind}] = read_biologic_file(fid);
        %fermer le fichier
        fclose(fid);
        fprintf('COMPLETE\n');
    else
        fprintf('BAD FILE\n');
    end
end
%on force l'ERREUR si BAD FILE, parce que des elements de tete et corps
%sont vides
indices = ~cellfun(@isempty,corps);
if length(find(indices))<length(corps)
    fprintf('Filtrage de tables: quelques tables sont vides');
    corps = corps(indices);
    %bug, il fallait aussi filtrer la liste de fichiers
    fileList = fileList(indices);
    fprintf('il reste %d tables\n',length(corps));
end
if isempty(corps)
    err = -999;%BRICOLE, a verifier les codes
    outStruct = [];
    fprintf('RIEN A FAIRE: %d\n',err);
    return
end
%3 Format variables
%3.1 tete,corps >>> XMLstruct
[outStruct, err] = Biologic2XML(corps,fileList);
if err
    outStruct = [];
    fprintf('RIEN A FAIRE: %d\n',err);
    return
end

%3.2- trivariables:met en premier les variable les plus utilisees (t,U,I,Q)
for ind = 1:length(outStruct.table)
    outStruct.table{ind} = sort_bench_variables(outStruct.table{ind});
end
%4 verifFomatXML4Vehlib
[outStruct, err, errS] = verifFomatXML4Vehlib(outStruct);
if err
    outStruct = [];
    return
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%function maStruct = Biologic2XML(corps,fileList)
function [maStruct, err] = Biologic2XML(corps,fileList)

% 1.- make Head
XMLfileType = 'Biologic File';
XMLfileDate =  datestr(now,'yyyy/mm/dd HH:MM');
% XMLfileDate =  'yyyy/mm/dd HH:MM';%DEBUG

[XMLHead, err] = makeXMLHead(XMLfileType,XMLfileDate);
if err
    maStruct = [];
    return
end
[maStruct, err] = makeXMLStruct(XMLHead);
if err
    maStruct = [];
    return
end
for indF = 1:length(corps)
    fprintf('Importing %d of %d ',indF,length(corps));
    donnees = corps{indF};
    if ~isempty(donnees)
        % 2.- make Table
        
        [variableNames, unitNames, tableDate, typeEssai, sourcefile] = analyze_head(fileList{indF});
        % 2.1.- make metaTable
        tableName = sprintf('%s_%02i',typeEssai,indF);
        tableComments = '';
        [XMLMetatable, err] = makeXMLMetatable(tableName,tableDate,sourcefile,tableComments);
        if err
            return
        end
        % 2.2.- make Variables
        %variables
        XMLVars = struct;
        for ind = 1:length(variableNames)
            XMLVars.(variableNames{ind}) = ...
                makeXMLVariable(variableNames{ind}, unitNames{ind}, '%f', variableNames{ind}, donnees(:,ind));
        end
        %variables ajoutees:
        %tp (temps de phase)
        tp =  XMLVars.tc.vector-XMLVars.tc.vector(1);
        XMLVars.tp = makeXMLVariable('tp', 's', '%f', 'tp', tp);
        if ~isfield(XMLVars,'I')%sometimes missing I in MB techniques (mars 2021)
            I =  zeros(size(XMLVars.tc.vector));
            XMLVars.I = makeXMLVariable('I', 'mA', '%f', 'I', I);
        end
        if ~isempty(tableDate)
            %tabs (temps absolu) depuis le premier janvier 2000
            tBio = datenum(tableDate,'yymmdd_HHMMSS.FFF')-datenum('000101','yymmdd');
            tabs = XMLVars.tc.vector+tBio*86400;
            XMLVars.tabs = makeXMLVariable('tabs', 's', '%f', 'temps absolu', tabs);
        end
        if  strcmp(typeEssai, 'GEIS') || strcmp(typeEssai, 'PEIS')
            
            %mode 4
            mode =  4*ones(size(XMLVars.tc.vector));
            XMLVars.mode = makeXMLVariable('mode', '', '%i', 'mode', mode);
            %error
            Error = zeros(size(XMLVars.tc.vector));
            XMLVars.error = makeXMLVariable('error', '', '%i', 'error', Error);
            
        elseif  strcmp(typeEssai, 'GPI')  
            %mode 5
            mode =  5*ones(size(XMLVars.tc.vector));
            XMLVars.mode = makeXMLVariable('mode', '', '%i', 'mode', mode);
        elseif  strcmp(typeEssai, 'OCV')
            %I
            I =  zeros(size(XMLVars.tc.vector));
            XMLVars.I = makeXMLVariable('I', 'mA', '%f', 'I', I);
            %Qp (AmpHeure charges endant la phase)
            Qp =  zeros(size(XMLVars.tc.vector));
            XMLVars.Qp = makeXMLVariable('Qp', 'mAh', '%f', 'Qp', Qp);
            
        end
        %Ns
        if isfield(XMLVars,'Ns_changes')
            Ns =  cumsum(XMLVars.Ns_changes.vector);
        else
            Ns =  zeros(size(XMLVars.tc.vector));
        end
        XMLVars.Ns = makeXMLVariable('Ns', '', '%i', 'Ns', Ns);
        %unites du SI
        if strcmp(XMLVars.I.unit,'mA')
            XMLVars.I.vector = XMLVars.I.vector/1000;
            XMLVars.I.unit = 'A';
        end
        if isfield(XMLVars,'Qp')
            if strcmp(XMLVars.Qp.unit,'mAh')
                XMLVars.Qp.vector = XMLVars.Qp.vector/1000;
                XMLVars.Qp.unit = 'Ah';
            end
        end
        %TENTATIVE: modifier le mode dans des EIS insérées dans des
        %techniques MB
        if isfield(XMLVars,'freq')
            Is = XMLVars.freq.vector ~= 0;
            XMLVars.mode.vector(Is) = 4;
        end
        % 3.- add Table
        XMLVars = struct2cell(XMLVars);
        [maStruct, err] = addXMLTable(maStruct,XMLMetatable, XMLVars);
        if err
            return
        end
    end
    fprintf('COMPLETE\n');
end
%correction de tc (batch files)
if isfield(maStruct.table{1},'tabs')
    debutTests = maStruct.table{1}.tabs.vector(1);
    for ind = 1:length(maStruct.table)
        if isfield(maStruct.table{ind},'tabs')
            maStruct.table{ind}.tc.vector = maStruct.table{ind}.tabs.vector - debutTests;
        end
    end
end

end
