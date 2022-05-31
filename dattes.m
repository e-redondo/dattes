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
%   -'e': EIS (plot_eis)
%   -'C': Capacity measurement
%   -'S': SoC calculation
%   -'R': Resistance identification
%   -'Z': impedance identification (CPE, Warburg or other)
%   -'P': peudoOCV (low current charge/discharge cycles)
%   -'O': OCV by points (partial charge/discharges followed by rests)
%   -'I': ICA/DVA
%   -'A': synonym for 'CSRWPOI' (do all)
%   -'G': visualize the resuls obtained before (stored in 'xml_file_result.mat')
%     - 'Gx': visualize extracted profiles (t,U,I)
%     - 'Gp': visualize phase decomposition
%     - 'Gc': visualize configuration
%     - 'GS': visualize soc
%     - 'GC': visualize capacity
%     - 'GP': visualize pseudoOCV
%     - 'GO': visualize OCV by points
%     - 'GE': visualize efficiency
%     - 'GR': visualize resistance
%     - 'GW': visualize CPE impedance
%     - 'G*d': time in days (* = x,p,c,S,C,R,W,P,O,I)
%     - 'G*h': time in hours (* = x,p,c,S,C,R,W,P,O,I)
%     - 'G*D': time as date/time (* = x,p,c,S,C,R,W,P,O,I)
%
% Exemples:
% dattes(xml_file,cfg_file,'s'): lit le fichier (t,U,I,m) et sauvegarde dans xml_file_results.mat.
% dattes(xml_file,cfg_file,'gs'): idem en montrant les figures
% dattes(xml_file,cfg_file,'gsv'): idem en disant ce qu'il fait (verbose)
%
% dattes(xml_file,cfg_file,'ps'), cut the test in phases and save
% dattes(xml_file,cfg_file,'cs'), configure the test and save
%
% [result, config, phases] = dattes(xml_file,cfg_file,'l'), just load the
% results
%
% dattes(xml_file,cfg_file,'C'), charge la configuration et calcule la Capacite.
%
% dattes(xml_file,cfg_file,'Cs'), pareil mais sauvegarde le result dans
% xml_file_results.mat.
%
% dattes(xml_file,cfg_file,'As'), fait tout: lecture, config, tous les calculs,
% sauvegarde de results.
%
% See also extract_profiles, split_phases, configurator
% ident_capacity, ident_ocv_by_points, ident_pseudo_ocv, ident_r, ident_cpe, ident_rrc, ident_ica


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
inher_options = options(ismember(options,'gfuvse'));

%% Graphics mode 
if ismember('G',options)
    [result, config, phases] = dattes_plot(xml_file,options);
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
[result, config, phases] = load_result(xml_file,inher_options);

%1.1.-take some basic config parameters in config0 struct
% (e.g. Uname and Tname needed in extract_profiles)
if isstruct(cfg_file)
    %cfg_file is given as struct, e.g. dattes(xml,cfg_battery,'cdvs')
    config0 = cfg_file;
elseif ~isempty(which(cfg_file))
    %cfg_file is given as script, e.g. dattes(xml,'cfg_battery','cdvs')
    config0 = eval(cfg_file);
else
    %cfg_file is empty, e.g. dattes(xml,'','cdvs'), take config from load_result
    config0 = config;
end
    
%1.2.- load data in XML
[t,U,I,m,dod_ah,soc,temperature, eis] = extract_profiles(xml_file,inher_options,config0);
%1.3.- update result
result.test.file_in = xml_file;
result.test.t_ini = t(1);
result.test.t_fin = t(end);
if ~isempty(eis)
    result.eis = eis;
end
%1.4. DECOMPOSE IN PHASES
[phases] = split_phases(t,I,U,m,inher_options);


%% 2. CONFIGURE
if ismember('c',options)

    % TODO check if no 'p' was done before
    [config] = configurator(t,U,I,m,config0,phases,inher_options);
    % traceability: if a script for config is given
    if ischar(cfg_file)
        config.cfg_file = cfg_file;
    elseif ~isfield(config,'cfg_file')
        config.cfg_file = '';
    end
end

%% 3. Capacity measurements at different C-rates 1C, C/2, C/5....
if ismember('C',options)
    [capacity] = ident_capacity(config,phases,inher_options);
    result.capacity = capacity;
end

%% 5. soc
if ismember('S',options)
    [dod_ah, soc] = calcul_soc(t,I,config,inher_options);
    if isempty(dod_ah)
        result.test.dod_ah_ini = [];
        result.test.soc_ini = [];
        result.test.dod_ah_fin = [];
        result.test.soc_fin = [];
    else
        result.test.dod_ah_ini = dod_ah(1);
        result.test.soc_ini = soc(1);
        result.test.dod_ah_fin = dod_ah(end);
        result.test.soc_fin = soc(end);
    end
end

%% 6. Profile processing (t,U,I,m,dod_ah) >>> R, CPE, ICA, OCV, etc.

if any(ismember('PORZI',options))
    if isempty(dod_ah)
        %on a pas fait calculSOC ou s'est mal passe, on arrete (on ne
        %sauvegarde pas)
        fprintf('dattes: ERREUR il faut calculer le SoC de ce fichier:%s\n',...
            result.test.file_in);
        %         return
    else
        
        
        %6.1. pseudo ocv
        if ismember('P',options)
            [pseudo_ocv] = ident_pseudo_ocv(t,U,dod_ah,config,phases,inher_options);
            %save the results
            result.pseudo_ocv = pseudo_ocv;
            
        end
        
        %6.2. ocv by points
        if ismember('O',options)
            [ocv_by_points] = ident_ocv_by_points(t,U,dod_ah,m,config,phases,inher_options);
            %save the results
            result.ocv_by_points = ocv_by_points;
        end
        
        %6.3. impedances
        %6.3.1. resistance
        if ismember('R',options)
            [R, RDoD, RRegime, Rt, Rdt] = ident_r(t,U,I,dod_ah,config,phases,inher_options);
            %resistances
            result.resistance.R = R;
            result.resistance.dod = RDoD;
            result.resistance.crate = RRegime;
            result.resistance.time = Rt;
            result.resistance.delta_time = Rdt;
            
        end
        %6.3.2. Impedance
        if ismember('Z',options)
            ident_z = config.impedance.ident_fcn;
            [impedance] = ident_z(t,U,I,dod_ah,config,phases,inher_options);
            result.impedance= impedance;
        end
        
        %6.4. ICA/DVA
        if ismember('I',options)
            ica = ident_ica(t,U,dod_ah,config,phases,inher_options);
            %sauvegarder les resultats
            result.ica = ica;
        end
    end
end

%% 7. test temperature
% temperature = 25;%DEBUG TODO: lire a partir d'un fichier d'histoire?
if ~isfield(result,'temperature')
    result.temperature = 25;
end
%autres:
% result.rendFar = rendFar; %d'un cycle charge-decharge
% result.rendEne = rendEne; %d'un cycle charge-decharge
% result.rendRegime = rendRegime;%d'un cycle charge-decharge
%encore?

%% 8. Save results
if ismember('s',options)
    if ismember('v',options)
        fprintf('dattes: save result...');
    end
    %sauvegarde de result,config,phases dans xml_file_result.mat
    save_result(result,config,phases);
    if ismember('S',options)
        %sauvegarde de dod_ah, soc dans xml_file.mat
        mat_file = regexprep(xml_file,'xml$','mat');
        save(mat_file,'-append','dod_ah', 'soc');
    end
    %TODO ajouter option 'T' pour lecture externe de la température et
    %sauvegarde avec 'append' comme pour le soc
    if ismember('v',options)
        fprintf('OK\n');
    end
end
%%
end

