function [result] = dattes(xml_file,options,cfg_file)
%DATTES Data Analysis Tools for Tests on Energy Storage
%
% Read the *.xml file of a battery test and perform several calculations
% (Capacity, SoC, OCV, impedance identification, ICA/DVA, etc.).
% Results are returned as output variables and (optionally) stored in a file
% named 'xml_file_dattes.mat'.
%
% Usage:
% [result] = DATTES(xml_file,options,cfg_file)
%
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
%     - 'Gx': visualize extracted profiles (datetime,U,I)
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
% Output : 
% - result [1x1 struct] with fields:
%     - profiles [1x1 struct]:
%         - created by <a href="matlab: help('extract_profiles')">extract_profiles</a>
%         - modified by calcul_soc and calcul_soc_patch
%         - contains (mx1) vectors with main cell variables (datetime,U,I,m,soc,dod_ah)
%     - eis [1x1 struct]:
%         - created by <a href="matlab: help('extract_profiles')">extract_profiles</a>
%         - contains (px1) cells with EIS measurements, each 'p' contains (nx1) vectors (datetime,U,I,m,ReZ,ImZ,f)
%     - test [1x1 struct]:
%         - created by DATTES
%         - modified by calcul_soc and calcul_soc_patch
%         - contains filename
%         - contains general values of the test initial/final values
%     - phases [1xq struct]:
%         - created by <a href="matlab: help('split_phases')">split_phases</a>
%         - each phase contains general values like initial/final/average values (time, voltage, current...)
%     - configuration [1x1 struct]:
%         - created by config scripts
%         - modified by cfg_default, configurator
%     - capacity [1x1 struct]:
%         - created by <a href="matlab: help('ident_capacity')">ident_capacity</a>
%         - contains (1xk) vectors for CC capacity measurements
%         - contains (1xi) vectors for CV phases
%         - contains (1xj) vectors for CCCV capacity measurements
%     - pseudo_ocv [1xr struct]:
%         - created by <a href="matlab: help('ident_pseudo_ocv')">ident_pseudo_ocv</a>
%         - each pseudo_ocv contains (sx1) vectors for each pseudo_ocv measurement (charge/discharge half cycles)
%         - each pseudo_ocv contains (1x1) values (crate and time of measurement)
%     - ocv_points [1x1 struct]:
%         - created by <a href="matlab: help('ident_ocv_by_points')">ident_ocv_by_points</a>
%         - contains (tx1) vectors for each ocv points
%     - resistance [1x1 struct]:
%         - created by <a href="matlab: help('ident_r')">ident_r</a>
%         - contains (1xv) vectors for resistance measurements
%     - impedance [1x1 struct]:
%         - created by <a href="matlab: help('ident_cpe')">ident_cpe</a> or <a href="matlab: help('ident_rrc')">ident_rrc</a>
%         - contains (1xg) string with chosen topology (R+CPE or R+RC+RC)
%         - contains (1xw) vectors for impedance identifications (circuit parameters)
%     - ica [1xy struct]:
%         - created by <a href="matlab: help('ident_ica')">ident_ica</a>
%         - each ica contains (zx1) vectors for each ICA measurement
%
% Examples:
% DATTES(xml_file,'s',cfg_file): Load the profiles (datetime,U,I,m) in .xml file and save them in a xml_file_result.mat.
% DATTES(xml_file,'gs',cfg_file): idem and plot profiles graphs
% DATTES(xml_file,'gsv',cfg_file): idem and describe ongoing analysis (verbose)
%
% DATTES(xml_file,'ps',cfg_file), split the test in phases and save
% DATTES(xml_file,'cs',cfg_file), configure the test and save
%
% [result] = DATTES(xml_file), load the results
%
% DATTES(xml_file,'C'), make capacity analysis.
%
% DATTES(xml_file,'Cs'), idem and save results in a xml_file_results.mat.
%
% DATTES(xml_file,'As'), Do all analysis : load, configuration all
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
    [result] = dattes_plot(xml_file,options);
    %If figures are plotted ('G') none analysis is done then
    return;
end

%% Bulk mode (XML is a cellstring)
if iscell(xml_file)
    [result] = cellfun(@(x) dattes(x,options,cfg_file),xml_file,'UniformOutput',false);
    %formatting (cell 2 struct):
%     [result] = compil_result(result);
    return;
end

%% 1. LOAD
% if ismember('l',options)
%1.0.- load previous results (if they exist)
[result] = load_result(xml_file,inher_options);
% else
%     result = struct;
% end

%1.1.-take some basic config parameters in config0 struct
% (e.g. Uname and Tname needed in extract_profiles)
if isstruct(cfg_file)
    %cfg_file is given as struct, e.g. dattes(xml,'cvs',cfg_battery)
    config0 = cfg_file;
elseif ~isempty(which(cfg_file))
    %cfg_file is given as script, e.g. dattes(xml,'cvs','cfg_battery_script')
    config0 = eval(cfg_file);
    % traceability: if a script for config is given
    config.test.cfg_file = cfg_file;
elseif isfield(result, 'configuration')
    %cfg_file is empty, e.g. dattes(xml,'cvs')
    % take config from load_result, if result contains any configuration
    config0 = result.configuration;
else
    %no configuration, empty struct
    config0 = struct([]);
end
    
%1.2.- load data in XML
if ismember('x',options) || ~isfield(result,'profiles')
    [profiles, eis, metadata, config0, err] = extract_profiles(xml_file,inher_options,config0);
    if isempty(profiles)
        % no data found in xml_file
        return
    end
    result.profiles = profiles;
    if ~isempty(eis)
        result.eis = eis;
    end
    if ~isempty(metadata)
        result.metadata = metadata;
    end
end

datetime = result.profiles.datetime;
t = result.profiles.t;
U = result.profiles.U;
I = result.profiles.I;
m = result.profiles.m;
T = result.profiles.T;
if isfield(result.profiles,'dod_ah')
    dod_ah = result.profiles.dod_ah;
    soc = result.profiles.soc;
else
    dod_ah = [];
    soc = [];
end

%1.3.- update result
result.test.file_in = xml_file;
result.test.file_out = result_filename(result.test.file_in);
result.test.datetime_ini = result.profiles.datetime(1);
result.test.datetime_fin = result.profiles.datetime(end);

%1.4. DECOMPOSE IN PHASES
[phases] = split_phases(datetime,I,U,m,inher_options);
result.phases = phases;

%% 2. CONFIGURE
if ismember('c',options)
    config = config_soc(datetime,I,U,m,config0,inher_options);
    config = configurator(datetime,I,U,m,config,phases,inher_options);
    
    result.configuration = config;
else
    result.configuration = config0;
end
config = result.configuration;

%% 3. Capacity measurements at different C-rates 1C, C/2, C/5....
if ismember('C',options)
    [capacity] = ident_capacity(config,phases,inher_options);
    result.capacity = capacity;
end

%% 5. soc
if ismember('S',options)
    [dod_ah, soc] = calcul_soc(datetime,I,config,inher_options);
    result.profiles.dod_ah = dod_ah;
    result.profiles.soc = soc;
end
% update test soc_ini and soc_fin: 
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
%% 6. Profile processing (datetime,U,I,m,dod_ah) >>> R, CPE, ICA, OCV, etc.

if any(ismember('PORZI',options))
    if isempty(dod_ah)
        %If  calcul_soc have not been processed correctly, none analysis is processed (and neither saved)
        fprintf('dattes: ERREUR il faut calculer le SoC de ce fichier:%s\n',...
            result.test.file_in);
        %         return
    else
        
        
        %6.1. pseudo ocv
        if ismember('P',options)
            [pseudo_ocv] = ident_pseudo_ocv(datetime,U,dod_ah,config,phases,inher_options);
            %save the results
            result.pseudo_ocv = pseudo_ocv;
            
        end
        
        %6.2. ocv by points
        if ismember('O',options)
            [ocv_by_points] = ident_ocv_by_points(datetime,U,dod_ah,m,config,phases,inher_options);
            %save the results
            result.ocv_by_points = ocv_by_points;
        end
        
        %6.3. impedances
        %6.3.1. resistance
        if ismember('R',options)
            [resistance] = ident_r(datetime,U,I,dod_ah,config,phases,inher_options);
            %save the results
            result.resistance = resistance;
        end
        %6.3.2. Impedance
        if ismember('Z',options)
            ident_z = config.impedance.ident_fcn;
            if ischar(ident_z)
               % function handle saved as string in octave and in json:
               ident_z = str2func(ident_z);
            end
            [impedance] = ident_z(datetime,U,I,dod_ah,config,phases,inher_options);
            result.impedance= impedance;
        end
        
        %6.4. ICA/DVA
        if ismember('I',options)
            ica = ident_ica(datetime,U,dod_ah,config,phases,inher_options);
            %sauvegarder les resultats
            result.ica = ica;
        end
    end
end

%% 7. Test temperature
% if ~isfield(result,'temperature')
%     result.temperature = 25;
% end


%% 8. Save results
if ismember('s',options)
    if ismember('v',options)
        fprintf('dattes: save result...');
    end
    %save outputs result,config and phases in a xml_file_result.mat
    save_result(result);
%     if ismember('S',options)
%         %save dod_ah and soc in the xml_file.mat
%         mat_file = regexprep(xml_file,'xml$','mat');
%         save(mat_file,'-v7','-append','dod_ah', 'soc');
%     end
    if ismember('v',options)
        fprintf('OK\n');
    end
end
%%
end

