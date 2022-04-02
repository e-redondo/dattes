function [result, config, phases] = dattes(xml_file,cfg_file,options)
%DATTES Data Analysis Tools for Tests on Energy Storage
%
% [result, config, phases] = dattes(xml_file,cfg_file,options):
% Read the *.xml file of a battery test and performd several calculations
% (Capacity, SoC, OCV, impedance idnetification, ICA/DVA, etc.).
% Results are reutern as output variable and (optionnaly) stored in a file
% named 'xml_file_result.mat'.
%
% Usage:
% dattes(xml_file,cfg_file,options)
% - xml_file:
%     -   (1xn string): pathame to th xml file
%     -   (nx1 cell string): xml filelist
% - cfg_file: function name to configure the behavior (see configurator)
% - options: string containing execution options:
%   -'g': show figures
%   -'s': save result, config, phases >>> 'xml_file_result.mat'.
%   -'f': force, redo the actions even if the result file already exists
%   -'u': update, redo the actions even if the xml_file is more recent
%   -'v': verbose, tell what you do
%   -'c': run the configuraiton following cfg_file
%   -'C': Capacity measurement
%   -'S': SoC calculation
%   -'R': Resistance identification
%   -'W': CPE impedance identification (Warburg or other)
%   -'P': peudoOCV (low current charge/discharge cycles)
%   -'O': OCV by points (partial charge/discharges followed by rests)
%   -'I': ICA/DVA
%   -'A': synonym for 'CSRWPOI' (do all)
%   -'G': visualize the resuls obtained before (stored in 'xml_file_result.mat')
%     - 'Gx': visualize extracted profiles (t,U,I)
%     - 'Gd': visualize phase decomposition
%     - 'Gc': visualize configuration
%     - 'GS': visualize SOC
%     - 'GC': visualize capacity
%     - 'GP': visualize pseudoOCV
%     - 'GO': visualize OCV by points
%     - 'GE': visualize efficiency
%     - 'GR': visualize resistance
%     - 'GW': visualize CPE impedance
%     - 'G*j': echelle de temps en jours (* = x,d,c,S,C,R,W,P,O,I)
%     - 'G*d': echelle de temps en days (* = x,d,c,S,C,R,W,P,O,I)
%     - 'G*h': echelle de temps en heures (* = x,d,c,S,C,R,W,P,O,I)
%     - 'G*D': afficher le temps en dates (* = x,d,c,S,C,R,W,P,O,I)
%
% Exemples:
% dattes(XMLfile,CFGfile,'s'): lit le fichier (t,U,I,m) et sauvegarde dans XMLfile_results.mat.
% dattes(XMLfile,CFGfile,'gs'): idem en montrant les figures
% dattes(XMLfile,CFGfile,'gsv'): idem en disant ce qu'il fait (verbose)
%
% dattes(XMLfile,CFGfile,'ds'), decoupe l'essai en phases et sauvegarde
% dattes(XMLfile,CFGfile,'cs'), configure l'essai et sauvegarde
%
% [resultat, config, phases] = dattes(XMLfile,CFGfile,'l'), juste charge les
% resultats.
%
% dattes(XMLfile,CFGfile,'C'), charge la configuration et calcule la Capacite.
%
% dattes(XMLfile,CFGfile,'Cs'), pareil mais sauvegarde le resultat dans
% XMLfile_results.mat.
%
% dattes(XMLfile,CFGfile,'As'), fait tout: lecture, config, tous les calculs,
% sauvegarde de resultats.
%
% See also extractBanc, decoupeBanc, ident_Capa2, ident_OCVr2, ident_R2,
% ident_CPE2

%TODO: review results' structure
% result
%   .x
%     .t, .U, .I, .m, .T
%   .phases
%   .config
%   .Capacity
%       .QCCdis, .QCVdis, QCCcha, QCVcha
%   .Resistance
%       .R, .CRate, .DoD, .dt

%TODO: put all the results in one file (profiles + result + phases + config

%% 0.-interpreter les options
if ~exist('options','var')
    %par defaut lits les fichiers et sauvegarde:
    %1.1.- fichier _result.mat vide
    %1.2.- profil en fichier MAT (extractBanc)
    options = 's';
end
%options d'abreviation:
options = strrep(options,'A','CSRWPOI');
%enfin:
options = unique(options);%on enleve les doublons
%options qui vont etre transmises (inherit) aux sous fonctions:
% -g: graphics
% -f: force
% -u: update
% -v: verbose
% -s: save
InherOptions = options(ismember(options,'gfuvs'));

%% Graphics mode 
if ismember('G',options)
    [result, config, phases] = RPTplot(xml_file,options);
    %SI ON FAIT FIGURES ('G') ON NE FAIT PLUS RIEN APRES
    %(pas de traitement ni sauvegarde)
    return;
end

%% Bulk mode (XML is a cellstring)
if iscell(xml_file)
    [result, config, phases] = cellfun(@(x) dattes(x,cfg_file,options),xml_file,'UniformOutput',false);
    %mise en forme (cell 2 struct):
    [result, config, phases] = compil_result(result, config, phases);
    return;
end


%% 1. LOAD
%1.0.- load previous results (if they exist)
[result, config, phases] = load_result(xml_file,InherOptions);
%1.1.- load data in XML
[t,U,I,m,DoDAh,SOC,T] = extract_bench(xml_file,InherOptions,config);
%1.3.- update result
result.fileIn = xml_file;
result.tIni = t(1);
result.tFin = t(end);
%1.4. DECOMPOSE IN PHASES
[phases] = decompose_bench(t,I,U,m,InherOptions);


%% 2. CONFIGURE
if ismember('c',options)
    if isstruct(cfg_file)
        %CFGfile is given as struct, e.g. dattes(xml,cfg_battery,'cdvs')
        config0 = cfg_file;
    elseif ~isempty(which(cfg_file))
        %CFGfile is given as script, e.g. dattes(xml,'cfg_battery','cdvs')
        config0 = eval(cfg_file);
    else
        %CFGfile is empty, e.g. dattes(xml,'','cdvs'), take config from loadRPT
        config0 = config;
    end
    % TODO check if no 'd' was done before
    [config] = configurator2(t,U,I,m,config0,phases,InherOptions);
    % traceability: if a script for config is given
    if ischar(cfg_file)
        config.CFGfile = cfg_file;
    elseif ~isfield(config,'CFGfile')
        config.CFGfile = '';
    end
end

%% 3. Capacity measurements at different C-rates 1C, C/2, C/5....
if ismember('C',options)
    %3.1- CC capacity (constant current)
    [Capa, CapaRegime] = ident_Capa2(phases,config,InherOptions);
    result.Capa = Capa;
    result.CapaRegime = CapaRegime;
    
    %3.2- CV capacity (constant voltage)
    [UCV, dCV, CapaCV] = ident_CapaCV(t,U,config,phases,InherOptions);
    result.UCV = UCV;
    result.dCV = dCV;
    result.QCV = CapaCV;
end

%% 5. SOC
if ismember('S',options)
    [DoDAh, SOC] = calculSOC(t,I,config,InherOptions);
    if isempty(DoDAh)
        result.DoDAhIni = [];
        result.SOCIni = [];
        result.DoDAhFin = [];
        result.SOCFin = [];
    else
        result.DoDAhIni = DoDAh(1);
        result.SOCIni = SOC(1);
        result.DoDAhFin = DoDAh(end);
        result.SOCFin = SOC(end);
    end
end

%% 6. Profile processing (t,U,I,m,DoDAh) >>> R, CPE, ICA, OCV, etc.

%TODO: Gestion d'erreurs: tous les calculs a partir d'ici ont besoin des
%profils (t,U,I,m,DoDAh)
if any(ismember('PORWI',options))
    if isempty(DoDAh)
        %on a pas fait calculSOC ou s'est mal passe, on arrete (on ne
        %sauvegarde pas)
        fprintf('dattes: ERREUR il faut calculer le SoC de ce fichier:%s\n',...
            result.fileIn);
        return
    end
end

%6.1. pseudo ocv
if ismember('P',options)
    [pOCV, pDoD, pPol,pEff,pUCi,pUDi,pRegime] = ident_pOCV(t,U,DoDAh,config,phases,InherOptions);
    %sauvegarder les resultats
    result.pOCV = pOCV;
    result.pDoD = pDoD;
    result.pPol = pPol;
    result.pEff = pEff;
    result.pUCi = pUCi;
    result.pUDi = pUDi;
    result.pRegime = pRegime;
    
end

%6.2. ocv by points
if ismember('O',options)
    [OCVp, DoDp, tOCVp, Ipsign] = ident_OCVr2(t,U,DoDAh,m,config,phases,InherOptions);
    %OCVs
    result.OCVp = OCVp;
    result.DoDp = DoDp;
    result.tOCVp = tOCVp;
    result.Ipsign = Ipsign;
    
end

%6.3. impedances
%6.3.1. resistance
if ismember('R',options)
    [R, RDoD, RRegime] = ident_R2(t,U,I,DoDAh,config,InherOptions);
    %impedances
    result.R = R;
    result.RDoD = RDoD;
    result.RRegime = RRegime;
end
%6.3.2. CPE
if ismember('W',options)
    [CPEQ, CPEalpha, CPEDoD, CPERegime] = ident_CPE2(t,U,I,DoDAh,config,InherOptions);
    result.CPEQ = CPEQ;
    result.CPEalpha = CPEalpha;
    result.CPEDoD = CPEDoD;
    result.CPERegime = CPERegime;
end

%6.4. ICA/DVA
if ismember('I',options)
    [ICAC, ICAD] = ident_ICA(t,U,DoDAh,m,config,phases,InherOptions);
    %sauvegarder les resultats
    result.ICAC = ICAC;
    result.ICAD = ICAD;
end

%% 7. test temperature
% T = 25;%DEBUG TODO: lire a partir d'un fichier d'histoire?
if ~isfield(result,'T')
    result.T = 25;
end
%autres:
% resultat.rendFar = rendFar; %d'un cycle charge-decharge
% resultat.rendEne = rendEne; %d'un cycle charge-decharge
% resultat.rendRegime = rendRegime;%d'un cycle charge-decharge
%encore?

%% 8. Save results
if ismember('s',options)
    if ismember('v',options)
        fprintf('dattes:sauvegarde...');
    end
    %sauvegarde de resultat,config,phases dans XMLfile_result.mat
    save_result(result,config,phases);
    if ismember('S',options)
        %sauvegarde de DoDAh, SOC dans XMLfile.mat
        MATfile = regexprep(xml_file,'xml$','mat');
        save(MATfile,'-append','DoDAh', 'SOC');
    end
    %TODO ajouter option 'T' pour lecture externe de la température et
    %sauvegarde avec 'append' comme pour le SOC
    if ismember('v',options)
        fprintf('OK\n');
    end
end
%%
end

