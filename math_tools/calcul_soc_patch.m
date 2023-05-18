function [result,xml] = calcul_soc_patch(XML,options,cellName)
% calcul_soc_patch - calculate SOC when calcul_soc has failed.
%
% [result,xml] = calcul_soc_patch(XML,options,cellName)
% Inputs:
% - XML [1xn cell string]: file List
% - options [1xp char]:
% -- 'b': search before 
% -- 'a': search after
% -- 'v': verbose
% -- 'u': unpatch (undo of previous calcul_soc_patch)
% - cellName [1xm char]: regex to filter XML by a pattern 'cell name'
%
% Outputs : 
% - result: [1x1 struct] structure containing analysis results 
% - xml [nx1 cell]: list of treated files
%
%
%Exemple (1):
% [result] = calcul_soc_patch(XML,'cell62','av');
% calcule les SOCs manquants dans la liste XML avec le nom cell62 en
% prenant les fichiers anterieurs ('a'), et en disant ce qu'il est fait ('v')
%
%Exemple (2):
%2.1) [result] = dattes(XML,'cfg_file','cs');
%refait la configuration, les essais sans repere de SoC100 auront DoDini et DoDfin = [].
%2.2) [result] = calcul_soc_patch(XML,'','u');
%les fichiers qui ont DoDini et DoDfin = [] seront recalcules (vecteur SOC = [])
%
% See also dattes, calcul_soc
%
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

if ~exist('options','var')
    options = '';
end
if ~exist('cellName','var')
    cellName = '';
end

verbose = ismember('v',options);

if ~ismember('a',options) && ~ismember('b',options)
    options = [options 'b'];%before by default
end



%TODO: changer ca
%essayer de mettre comme argument (result,config,phases), pour ne pas charger tout a
%chaque fois.
% XML = {result.test.file_in};
if ismember('u',options)%option 'unpatch', defaire ce que l'on a fait
    [result] = dattes_load(XML);
    %search files with imposed DoDIni or DoDFin:
    Ie = ~cellfun(@(x) isempty(x.configuration.soc.dod_ah_ini) && isempty(x.configuration.soc.dod_ah_fin),result);
    %List of files that will be treated
    xml = XML(Ie);
    %Filter results to this files:
    r = result(Ie);

    
    for ind = 1:length(r)
        r{ind}.configuration.soc.dod_ah_ini = [];
        r{ind}.configuration.soc.dod_ah_fin = [];
        
        r{ind}.test.dod_ah_ini = [];
        r{ind}.test.soc_ini = [];
        r{ind}.test.dod_ah_fin = [];
        r{ind}.test.soc_fin = [];
        if verbose
            fprintf('reset SOC for %s\n',r{ind}.test.file_in);
        end
        dattes_save(r{ind});
        dattes(r{ind}.test.file_in,'Ss');%reset SOC
    end
    return;
end


%1.-filter to nameCell: take only tests from nameCell
if isempty(cellName)
    xml = XML;%no filtering, take all files
else
    xml = regexpFiltre(XML,cellName);
end

r = dattes_load(xml);
%take start times
tInis = cellfun(@(x) x.test.datetime_ini,r);

%put in chronological order
[~, Is] = sort(tInis);
xml = xml(Is);

%reload by chronological order
r = dattes_load(xml);
c = cellfun(@(x) x.configuration,r,'uniformoutput',false);
p = cellfun(@(x) x.phases,r,'uniformoutput',false);


%2.-search tests with empty SOCIni
Ie = cellfun(@(x) isempty(x.test.soc_ini),r);
indEmptySOC =  find(Ie);
indAvant = indEmptySOC-1;
indApres = indEmptySOC+1;

if ismember('b',options)%before: search for previous test
    for ind = 1:length(indEmptySOC)%direct for (start:1:end)
        if indAvant(ind)>0 && ismember('b',options)%look for the previous
            r{indEmptySOC(ind)}.configuration.soc.dod_ah_ini = r{indAvant(ind)}.test.dod_ah_fin;
            if verbose
                fprintf('%s.DoDFin >>> %s.DoDIni\n',r{indAvant(ind)}.test.file_in, r{indEmptySOC(ind)}.test.file_in)
            end
        end
        dattes_save(r{indEmptySOC(ind)});%save configuration
        r{indEmptySOC(ind)} = dattes(xml{indEmptySOC(ind)},'Ss');%recalculate SOC
        if isempty(r{indEmptySOC(ind)}.test.soc_ini)
            fprintf('calcul_soc %s >>>>>>>>>>>>NOK\n',r{indEmptySOC(ind)}.test.file_in);
        else
            fprintf('calcul_soc %s >>>>>>>>>>>>OK\n',r{indEmptySOC(ind)}.test.file_in);
        end
        dattes_save(r{indEmptySOC(ind)});%save result
    end
elseif ismember('a',options)%after: search for following test
    for ind = length(indEmptySOC):-1:1%reverse for (end:-1:start)
        if indApres(ind)<=length(r) && ismember('a',options)%recherche du posterieur
            r{indEmptySOC(ind)}.configuration.soc.dod_ah_fin = r{indApres(ind)}.test.dod_ah_ini;
            if verbose
                fprintf('%s.DoDFin <<< %s.DoDIni\n', r{indEmptySOC(ind)}.test.file_in,r(indApres(ind)).test.file_in)
            end
        end
        dattes_save(r{indEmptySOC(ind)});%save configuration
        r{indEmptySOC(ind)} = dattes(xml{indEmptySOC(ind)},'Ss',r{indEmptySOC(ind)}.configuration.test.cfg_file);%recalculate SOC
        if isempty(r{indEmptySOC(ind)}.test.soc_ini)
            fprintf('calcul_soc %s >>>>>>>>>>>>NOK\n',r{indEmptySOC(ind)}.test.file_in);
        else
            fprintf('calcul_soc %s >>>>>>>>>>>>OK\n',r{indEmptySOC(ind)}.test.file_in);
        end
        dattes_save(r{indEmptySOC(ind)});%save resultat
    end
end

[result] = dattes_load(XML);
xml = xml(Ie);%list analysed files 

end
