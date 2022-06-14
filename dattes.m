function [result, config, phases] = dattes(xml_file,options,cfg_file)
%DATTES Data Analysis Tools for Tests on Energy Storage
%
% [result, config, phases] = dattes(xml_file,options,cfg_file):
% Read the *.xml file of a battery test and performe several calculations
% (Capacity, SoC, OCV, impedance identification, ICA/DVA, etc.).
% Results are returned as output variables and (optionally) stored in a file
% named 'xml_file_result.mat'.
%
% Usage:
% [result, config, phases] = dattes(xml_file,options,cfg_file)
% Inputs : 
% - xml_file:
%     -   [1xn string]: pathame to the xml file
%     -   [nx1 cell string]: xml filelist
% - options:  [1xn string] string containing execution options:
%   -'g': show figures
%   -'s': save result, config, phases >>> 'xml_file_result.mat'.
%   -'f': force, redo the actions even if the result file already exists
%   -'u': update, redo the actions even if the xml_file is more recent
%   -'v': verbose, tell what you do
%   -'c': run the configuration following cfg_file
%   -'e': EIS (plot_eis)
%   -'C': Capacity measurement
%   -'S': SoC calculation
%   -'R': Resistance identification
%   -'Z': impedance identification (CPE, Warburg or other)
%   -'P': pseudoOCV (low current charge/discharge cycles)
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
% - cfg_file:  [1x1 struct] function name to configure the behavior (see configurator)
%
% Outputs : 
% - result: [1x1 struct] structure containing analysis results 
% - config:  [1x1 struct] function name used to configure the behavior (see configurator)
% - phases: [1x1 struct] structure containing information about the different phases of the test
%
% Examples:
% dattes(xml_file,'s',cfg_file): Load the profiles (t,U,I,m) in .xml file and save them in a xml_file_result.mat.
% dattes(xml_file,'gs',cfg_file): idem and plot profiles graphs
% dattes(xml_file,'gsv',cfg_file): idem and describe ongoing analysis (verbose)
%
% dattes(xml_file,'ps',cfg_file), split the test in phases and save
% dattes(xml_file,'cs',cfg_file), configure the test and save
%
% [result, config, phases] = dattes(xml_file,'l'), load the results
%
% dattes(xml_file,'C'), make capacity analysis.
%
% dattes(xml_file,'Cs'), idem and save results in a xml_file_results.mat.
%
% dattes(xml_file,'As'), Do all analysis : load, configuration all
% analysis and save results in a xml_file_results.mat.
%
%
% See also extract_profiles, split_phases, configurator
% ident_capacity, ident_ocv_by_points, ident_pseudo_ocv, ident_r, ident_cpe, ident_rrc, ident_ica
%
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

%% 0.- optional inputs, set defaults:
if ~exist('options','var')
    %par defaut lits les fichiers et sauvegarde:
    %1.1.- fichier _result.mat vide
    %1.2.- profil en fichier MAT (extractBanc)
    options = 's';
end

if ~exist('cfg_file','var')
    cfg_file = '';
end

%% 0.1.- check inputs:
if ~ischar(xml_file) && ~iscell(xml_file)
    error('dattes: xml_file must be a string (pathname) or a cell (filelist)');
end

if ischar(xml_file)
    if ~exist(xml_file,'file')
        error('dattes: file %s not found',xml_file);
    end
end

if ~ischar(cfg_file) && ~isstruct(cfg_file)
    error('dattes: cfg_file must be a string (pathname to cfg_file) or a struct (config struct)');
end

if ischar(cfg_file) && ~isempty(cfg_file)
    if isempty(which(cfg_file))
        error('dattes: cfg_file %s not found',cfg_file);
    end
end

if ~ischar(options) 
    error('dattes: options must be a string (actions/options list)');
end

%abbreviation options
options = strrep(options,'A','CSRWPOI');
%remove duplicate:
options = unique(options);
%Options that will be given as inputs (inherit) to sub-fonctions:
% -g: graphics
% -f: force
% -u: update
% -v: verbose
% -s: save
inher_options = options(ismember(options,'gfuvse'));

%% Graphics mode 
if ismember('G',options)
    [result, config, phases] = dattes_plot(xml_file,options);
    %If figures are plotted ('G') none analysis is done then
    return;
end

%% Bulk mode (XML is a cellstring)
if iscell(xml_file)
    [result, config, phases] = cellfun(@(x) dattes(x,options,cfg_file),xml_file,'UniformOutput',false);
    %formatting (cell 2 struct):
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

    [config] = configurator(t,U,I,m,config0,phases,inher_options);
    % traceability: if a script for config is given
    if ischar(cfg_file)
        config.test.cfg_file = cfg_file;
    elseif ~isfield(config.test,'cfg_file')
        config.test.cfg_file = '';
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
        %If  calcul_soc have not been processed correctly, none analysis is processed (and neither saved)
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
            [resistance] = ident_r(t,U,I,dod_ah,config,phases,inher_options);
            %save the results
            result.resistance = resistance;
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

%% 7. Test temperature
if ~isfield(result,'temperature')
    result.temperature = 25;
end


%% 8. Save results
if ismember('s',options)
    if ismember('v',options)
        fprintf('dattes: save result...');
    end
    %save outputs result,config and phases in a xml_file_result.mat
    save_result(result,config,phases);
    if ismember('S',options)
        %save dod_ah and soc in the xml_file.mat
        mat_file = regexprep(xml_file,'xml$','mat');
        save(mat_file,'-v7','-append','dod_ah', 'soc');
    end
    if ismember('v',options)
        fprintf('OK\n');
    end
end
%%
end

