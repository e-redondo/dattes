function [tete, dateEssai, typeEssai, sourcefile, emptyfile] = biologic_head(filename)
%enteteBiologic Lit et analyse l'entete des fichiers Biologic (MPT)
%   [tete, dateEssai] = enteteBiologic(filename)
%       - tete: [(mx1) cell string] informations de l'entete du fichier
%       - dateEssai: [string] date au format yyyymmdd_HHMMSS
%
if nargin==0
    print_usage
end
tete = '';
dateEssai = '';

%1.-lecture du fichier
[D, F, E] = fileparts(filename);
F = [F,E];
fid = fopen(filename,'r');
if fid<0
    fprintf('lectureBiologicTete: Erreur dans le fichier %s\n',F);
    return;
end
% [tete] = lectureBiologicTete(fid);
[tete] = read_biologic_file(fid,true);
if isempty(tete)
    fprintf('enteteBiologic: Erreur dans le fichier %s\n',F);
    return%on force l'erreur si pas ECLAB file
end
%check if it was last line in file
ligne = fgetl(fid);
if ligne == -1
    emptyfile = true;
else
    emptyfile = false;
end
fclose(fid);

%2.- date essai
dateEssai = '';
ligneDate = regexpFiltre(tete,'^Acquisition started on : ');
if ~isempty(ligneDate)
    dateEssai = regexprep(ligneDate{1},'^Acquisition started on : ','');
    aNum = datenum(dateEssai,'mm/dd/yyyy HH:MM:SS');%default date format in MATLAB = Biologic MM/DD/YY
    dateEssai = datestr(aNum,'yymmdd_HHMMSS.FFF');%v10.23
else%try to deduct date time from filename
    %try on filename
    ligneDate = regexp(F,'^[0-9]{8,8}_[0-9]{4,4}','match','once');
    if isempty(ligneDate) %try on last level folder name
        [~, D1] = fileparts(D)
        ligneDate = regexp(D1,'^[0-9]{8,8}_[0-9]{4,4}','match','once');
    end
    if ~isempty(ligneDate)
        aNum = datenum(ligneDate,'yyyymmdd_HHMM');
        dateEssai = datestr(aNum,'yymmdd_HHMMSS.FFF');
    end
end
%3.- typeEssai
if length(tete)>3
    if  strcmp(tete{4}, 'Special Galvanostatic Cycling with Potential Limitation')
        typeEssai = 'SGCPL';
    elseif strcmp(tete{4}, 'Galvanostatic Cycling with Potential Limitation')
        typeEssai = 'GCPL';
    elseif strcmp(tete{4}, 'Galvano Profile Importation')
        typeEssai = 'GPI';
    elseif  strcmp(tete{4}, 'Galvano Electrochemical Impedance Spectroscopy')
        typeEssai = 'GEIS';
    elseif  strcmp(tete{4}, 'Potentio Electrochemical Impedance Spectroscopy')
        typeEssai = 'PEIS';
    elseif  strcmp(tete{4}, 'Open Circuit Voltage')
        typeEssai = 'OCV';
    elseif  strcmp(tete{4}, 'Wait')
        typeEssai = 'Wait';
    elseif  strcmp(tete{4}, 'Modulo Bat')
        typeEssai = 'MB';
    else
        typeEssai = 'inconnu';
    end
else
    if  ~isempty(strfind(filename,'SGCPL'))
        typeEssai = 'SGCPL';
    elseif ~isempty(strfind(filename,'GCPL'))
        typeEssai = 'GCPL';
    elseif ~isempty(strfind(filename,'GPI'))
        typeEssai = 'GPI';
    elseif ~isempty(strfind(filename,'GEIS'))
        typeEssai = 'GEIS';
    elseif ~isempty(strfind(filename,'PEIS'))
        typeEssai = 'PEIS';
    elseif ~isempty(strfind(filename,'OCV'))
        typeEssai = 'OCV';
    else
        typeEssai = 'inconnu';
    end
end
%4.- sourcefile
% [s e] = regexp(tete,'\s(\w+).mpr$','start','end');
%modification pour les noms de fichier SIMCAL (yyyymmdd-HHMM_...)
% [s] = regexp(tete,'([a-zA-Z_0-9-]+).mpr$','start','end');
[s] = regexp(tete,'([a-zA-Z%�_0-9-]+).mpr$','match','once');
indices = find(cellfun(@(x) ~isempty(x),s));
if length(indices)~=1%pas trouve, on prend le nom du mpt
    %     sourcefile = '';
    [D sourcefile E] = fileparts(filename);
    sourcefile = sprintf('%s%s',sourcefile,E);
else
    %     s = s{indices};
    %     e = e{indices};
    %     index = find(indices);
    %     sourcefile =  tete{index}(s:e);
    %     sourcefile = strtrim(sourcefile);
    sourcefile = s{indices};
end
end