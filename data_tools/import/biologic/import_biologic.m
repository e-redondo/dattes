function [outStruct, err, errS] = import_biologic(dirname,options)
% import_biologic converts *.mpt files (Biologic) in *.xml
%
% Usage:
% [outStruct, err, errS] = import_biologic(dirname)
%
% Inputs:
% - dirname [(1xp) string]: folder containing *.mpt files
% - dirname [cell string]: file list to convert
% - options (string): containing the following characters
%   - 'v': verbose, tells what it does
%
% Outputs:
% - outStruct: xml structure in VEHLIB format
% - err [(1x1) double]: error code (==0 => OK, ~=0 => error)
% - errS [string]: error description
%
% Examples:
% [outStruct, err, errS] = import_biologic(dirname) % search for mpt
%   files in dirname and convert them into xml struct (outStruct)
% [outStruct, err, errS] = import_biologic(filelist) : convert every
%   *.mpt in filelist and convert them into xml struct (outStruct)
% [outStruct, err, errS] = import_biologic({filename}) : convert just
%   one *.mpt file (put filename into a cell string)
%
% See also: biologic_mpt2xml_files, biologic_mpt2xml_folders, which_cycler
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab:
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

%TODO: change dirname/filelist/file_in logic to be according other
%functions (e.g. import_arbin_csv):
% - default input: file_in
% - if file_in is a folder: do lsfiles, cellfun, xmlfusion
% - if file_in is a cell: cellfun
%TODO2: when first TODO done, change input name to file_in

if nargin==0
    print_usage;
end
%0.- check inputs:
if ~exist('options','var')
    options = '';
end
if isfile(dirname)
    %if 'path/to/file.mpt' given in input, convert to cell to consider it
    %as a file list.
    dirname = {dirname};
end
%1.-trouver les fichiers MPT
if iscell(dirname)
    fileList = dirname;
    %01 verification de l'existence des fichiers
    indices = cellfun(@(x) exist(x,'file')==2,fileList);
    fileList = fileList(indices);
else
    %01 verification de l'existence du repertoire
    if ~isfolder(dirname)
        err = -1;
        fprintf('import_biologic: nonexistent directory: %s\n',dirname);
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
            fprintf('import_biologic: Nothing to import: %s\n',dirname);
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

    fid = fopen_safe(thisFile);
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
    outStruct.table{ind} = sort_cycler_variables(outStruct.table{ind});
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
XMLfileDate =  datestr(now,'yyyy/mm/dd');
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

        [variableNames, unitNames, tableDate, sourcefile,test_params] = analyse_biologic_head(fileList{indF});
        % 2.1.- make metaTable
        tableName = sprintf('%s_%02i',test_params.type_test,indF);
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

        %sometimes 'step' missing (no Ns variable)
        % build it from 'Ns_changes'
        if ~isfield(XMLVars,'step') && isfield(XMLVars,'Ns_changes')
            step = cumsum(XMLVars.Ns_changes.vector);
            XMLVars.step = makeXMLVariable('step', '', '%f', 'step', step);
        end

        if ~isempty(tableDate)
            %tabs (temps absolu) depuis le premier janvier 2000
            tBio = datenum(tableDate,'yymmdd_HHMMSS.FFF')-datenum('000101','yymmdd');
            tabs = XMLVars.tc.vector+tBio*86400;
            XMLVars.tabs = makeXMLVariable('tabs', 's', '%f', 'temps absolu', tabs);
        end
        if  strcmp(test_params.type_test, 'GEIS') || strcmp(test_params.type_test, 'PEIS')

            %mode 4
            mode =  4*ones(size(XMLVars.tc.vector));
            XMLVars.mode = makeXMLVariable('mode', '', '%i', 'mode', mode);
            %error
            Error = zeros(size(XMLVars.tc.vector));
            XMLVars.error = makeXMLVariable('error', '', '%i', 'error', Error);

            %Iavg (Is in mpt files: constant average current):
            if isfield(test_params,'Is')
               Iavg =  test_params.Is*ones(size(XMLVars.tc.vector));
               XMLVars.Iavg = makeXMLVariable('Iavg', 'A', '%f', 'Iavg', Iavg);
            else
               XMLVars.Iavg = makeXMLVariable('Iavg', 'A', '%f', 'Iavg', nan(size(XMLVars.tc.vector)));
            end
            %Iamp (Ia in mpt files: current amplitude):
            if isfield(test_params,'Ia')
                Iamp =  test_params.Ia*ones(size(XMLVars.tc.vector));
                XMLVars.Iamp = makeXMLVariable('Iamp', 'A', '%f', 'Iamp', Iamp);
            else
               XMLVars.Iamp = makeXMLVariable('Iamp', 'A', '%f', 'Iamp', nan(size(XMLVars.tc.vector)));
            end
            %Uavg (Is in mpt files: constant average current):
            if isfield(test_params,'Us')
               Uavg =  test_params.Us*ones(size(XMLVars.tc.vector));
               XMLVars.Uavg = makeXMLVariable('Uavg', 'V', '%f', 'Uavg', Uavg);
            else
               XMLVars.Uavg = makeXMLVariable('Uavg', 'A', '%f', 'Uavg', nan(size(XMLVars.tc.vector)));
            end
            %Uamp (Ia in mpt files: current amplitude):
            if isfield(test_params,'Ua')
                Uamp =  test_params.Ua*ones(size(XMLVars.tc.vector));
                XMLVars.Uamp = makeXMLVariable('Uamp', 'V', '%f', 'Uamp', Uamp);
            else
               XMLVars.Uamp = makeXMLVariable('Uamp', 'A', '%f', 'Uamp', nan(size(XMLVars.tc.vector)));
            end

        elseif  strcmp(test_params.type_test, 'MB')

            %Found GEIS in MB:
            %Iavg (Is in mpt files: constant average current):
            if isfield(test_params,'Is')
                Iavg =  nan(size(XMLVars.tc.vector));
                if ~all(isnan(test_params.Is))
                    step = XMLVars.step.vector;
                    for ind = 1:length(test_params.Is)
                        if ~isnan(test_params.Is(ind))
                            Iavg(step+1==ind) = test_params.Is(ind);
                        end
                    end
                end
                XMLVars.Iavg = makeXMLVariable('Iavg', 'A', '%f', 'Iavg', Iavg);
            end
            %Iamp (Ia in mpt files: current amplitude):
            if isfield(test_params,'Ia')
                Iamp =  nan(size(XMLVars.tc.vector));
                if ~all(isnan(test_params.Ia))
                    step = XMLVars.step.vector;
                    for ind = 1:length(test_params.Ia)
                        if ~isnan(test_params.Ia(ind))
                            Iamp(step+1==ind) = test_params.Ia(ind);
                        end
                    end
                end
                 XMLVars.Iamp = makeXMLVariable('Iamp', 'A', '%f', 'Iamp', Iamp);
            end

            %Found PEIS in MB:
            %Uavg (Us in mpt files: constant average voltage):
            if isfield(test_params,'Us')
                Uavg =  nan(size(XMLVars.tc.vector));
                if ~all(isnan(test_params.Us))
                    step = XMLVars.step.vector;
                    for ind = 1:length(test_params.Us)
                        if ~isnan(test_params.Us(ind))
                            Uavg(step+1==ind) = test_params.Us(ind);
                        end
                    end
                end
                XMLVars.Uavg = makeXMLVariable('Uavg', 'V', '%f', 'Uavg', Uavg);
            end
            %Uamp (Ua in mpt files: current amplitude):
            if isfield(test_params,'Ua')
                Uamp =  nan(size(XMLVars.tc.vector));
                if ~all(isnan(test_params.Ua))
                    step = XMLVars.step.vector;
                    for ind = 1:length(test_params.Ua)
                        if ~isnan(test_params.Ua(ind))
                            Uamp(step+1==ind) = test_params.Ua(ind);
                        end
                    end
                end
                 XMLVars.Uamp = makeXMLVariable('Uamp', 'V', '%f', 'Uamp', Uamp);
            end
            %TODO: put always Iamp / Iavg to NaN to avoid errors in
            %extract_eis (field not found in xml.table)
            %TODO: add support for PEIS (Uamp / Uavg?)
        elseif  strcmp(test_params.type_test, 'GPI')
            %mode 5
            mode =  5*ones(size(XMLVars.tc.vector));
            XMLVars.mode = makeXMLVariable('mode', '', '%i', 'mode', mode);
        elseif  strcmp(test_params.type_test, 'OCV')
            %I
            I =  zeros(size(XMLVars.tc.vector));
            XMLVars.I = makeXMLVariable('I', 'mA', '%f', 'I', I);
            %Qp (AmpHeure charges pendant la phase)
            Qp =  zeros(size(XMLVars.tc.vector));
            XMLVars.Qp = makeXMLVariable('Qp', 'mAh', '%f', 'Qp', Qp);

        end
        %Ns (commented, already done above
%         if isfield(XMLVars,'Ns_changes')
%             Ns =  cumsum(XMLVars.Ns_changes.vector);
%         else
%             Ns =  zeros(size(XMLVars.tc.vector));
%         end
%         XMLVars.Ns = makeXMLVariable('Ns', '', '%i', 'Ns', Ns);
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
        if isfield(XMLVars,'ah')
            if strcmp(XMLVars.ah.unit,'mAh')
                XMLVars.ah.vector = XMLVars.ah.vector/1000;
                XMLVars.ah.unit = 'Ah';
            end
        end
        if isfield(XMLVars,'ah_dis')
            if strcmp(XMLVars.ah_dis.unit,'mAh')
                XMLVars.ah_dis.vector = XMLVars.ah_dis.vector/1000;
                XMLVars.ah_dis.unit = 'Ah';
            end
        end
        if isfield(XMLVars,'ah_cha')
            if strcmp(XMLVars.ah_cha.unit,'mAh')
                XMLVars.ah_cha.vector = XMLVars.ah_cha.vector/1000;
                XMLVars.ah_cha.unit = 'Ah';
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
