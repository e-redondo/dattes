function [R,C,P,xml] = calcul_soc_patch(XML,options,cellName)
% calcul_soc_patch - calculate SOC when calcul_soc has failed.
%
% [R,C,P] = calcul_soc_patch(XML,options,cellName)
%
% Inputs:
% - XML [1xn cell string]: file List
% - options [1xp char]:
% -- 'b': search before 
% -- 'a': search after
% -- 'v': verbose
% -- 'u': unpatch (undo of previous calcul_soc_patch)
% - cellName [1xm char]: regex to filter XML by a pattern 'cell name'
%
% Outputs:
% - R,C,P as in dattes
% - xml [nx1 cell]: list of treated files
%
% Le principe est le suivant:
% 1) on essaye une premiere fois avec dattes(XML,...,'Ss')
% >>> les tests qui ne contiennet pas de charge CCCV n'ont pas de SOC.
% 2) on cherche parmi les tests realises sur la meme cellule
% l'immediatement anterieur (par defaut) ou posterieur.
% 3) le DoDfin de ce test sera le DoDini de notre test (a l'envers si
% recherche posterieur).
% 4) on execute calcul_soc.
% 5) on passe au fichier suivant.
%
%Exemple (1):
% [R,C,P] = calcul_soc_patch(XML,'cell62','av');
% calcule les SOCs manquants dans la liste XML avec le nom cell62 en
% prenant les fichiers anterieurs ('a'), et en disant ce qu'il est fait ('v')
%
%Exemple (2):
%2.1) [R,C,P] = dattes(XML,'cfg_file','cs');
%refait la configuration, les essais sans repere de SoC100 auront DoDini et DoDfin = [].
%2.2) [R,C,P] = calcul_soc_patch(XML,'','u');
%les fichiers qui ont DoDini et DoDfin = [] seront recalcules (vecteur SOC = [])
%
% See also dattes, calcul_soc

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
%essayer de mettre comme argument (R,C,P), pour ne pas charger tout a
%chaque fois.
% XML = {R.test.file_in};
if ismember('u',options)%option 'unpatch', defaire ce que l'on a fait
    [R,C,P] = load_result(XML);
    %search files with imposed DoDIni or DoDFin:
    Ie = ~arrayfun(@(x) isempty(x.DoDAhIni) && isempty(x.DoDAhFin),C);
    %List of files that will be treated
    xml = XML(Ie);
    %Filter results to this files:
    r = R(Ie);
    c = C(Ie);
    p = P(Ie);
    
    for ind = 1:length(r)
        c(ind).DoDAhIni = [];
        c(ind).DoDAhFin = [];
        
        r(ind).DoDAhIni = [];
        r(ind).SOCIni = [];
        r(ind).DoDAhFin = [];
        r(ind).SOCFin = [];
        if verbose
            fprintf('reset SOC for %s\n',r(ind).test.file_in);
        end
    end
    save_result(r,c,p);
    dattes({r.test.file_in},'','Ss');%reset SOC
    return;
end


%1.-filter to nameCell: take only tests from nameCell
if isempty(cellName)
    xml = XML;%no filtering, take all files
else
    xml = regexpFiltre(XML,cellName);
end

[r,~,~] = load_result(xml);
%take start times
tInis = [r.test.t_ini];

%put in chronological order
[~, Is] = sort(tInis);
xml = xml(Is);

%reload by chronological order
[r,c,p] = load_result(xml);


%2.-search tests with empty SOCIni
Ie = arrayfun(@(x) isempty(x.SOCIni),r);
indEmptySOC =  find(Ie);
indAvant = indEmptySOC-1;
indApres = indEmptySOC+1;

if ismember('b',options)%before: search for previous test
    for ind = 1:length(indEmptySOC)%direct for (start:1:end)
        if indAvant(ind)>0 && ismember('b',options)%recherche de l'anterieur
            c(indEmptySOC(ind)).DoDAhIni = r(indAvant(ind)).DoDAhFin;
            if verbose
                fprintf('%s.DoDFin >>> %s.DoDIni\n',r(indAvant(ind)).test.file_in, r(indEmptySOC(ind)).test.file_in)
            end
        end
        save_result(r(indEmptySOC(ind)),c(indEmptySOC(ind)),p{indEmptySOC(ind)});%sauvegarder la configuration
        r(indEmptySOC(ind)) = dattes(xml{indEmptySOC(ind)},c(indEmptySOC(ind)).CFGfile,'Ss');%recalculer le SOC
        if isempty(r(indEmptySOC(ind)).SOCIni)
            fprintf('calcul_soc %s >>>>>>>>>>>>NOK\n',r(indEmptySOC(ind)).test.file_in);
        else
            fprintf('calcul_soc %s >>>>>>>>>>>>OK\n',r(indEmptySOC(ind)).test.file_in);
        end
        save_result(r(indEmptySOC(ind)),c(indEmptySOC(ind)),p{indEmptySOC(ind)});%sauvegarder le resultat
    end
elseif ismember('a',options)%after: search for following test
    for ind = length(indEmptySOC):-1:1%reverse for (end:-1:start)
        if indApres(ind)<=length(r) && ismember('a',options)%recherche du posterieur
            c(indEmptySOC(ind)).DoDAhFin = r(indApres(ind)).DoDAhIni;
            if verbose
                fprintf('%s.DoDFin <<< %s.DoDIni\n', r(indEmptySOC(ind)).test.file_in,r(indApres(ind)).test.file_in)
            end
        end
        save_result(r(indEmptySOC(ind)),c(indEmptySOC(ind)),p{indEmptySOC(ind)});%sauvegarder la configuration
        r(indEmptySOC(ind)) = dattes(xml{indEmptySOC(ind)},c(indEmptySOC(ind)).CFGfile,'Ss');%recalculer le SOC
        if isempty(r(indEmptySOC(ind)).SOCIni)
            fprintf('calcul_soc %s >>>>>>>>>>>>NOK\n',r(indEmptySOC(ind)).test.file_in);
        else
            fprintf('calcul_soc %s >>>>>>>>>>>>OK\n',r(indEmptySOC(ind)).test.file_in);
        end
        save_result(r(indEmptySOC(ind)),c(indEmptySOC(ind)),p{indEmptySOC(ind)});%sauvegarder le resultat
    end
end

[R,C,P] = load_result(XML);
xml = xml(Ie);%liste de fichiers qu'on a traite

end