function [profiles, eis, metadata, config, err] = extract_profiles(xml_file,options,config)
%extract_profiles extract important variables from a battery test bench file.
% Also read metadata in '.meta' files
%
%[profiles, eis, metadata, err] = extract_profiles(xml_file,options,config)
% 1.- Read a .xml file (Biologic,Arbin, Bitrode...), if a dattes' results
% file exists this latter will be read (faster)
% 2.- Extract important vectors: t,U,I,m,DoDAh,SOC,T
%
% Usage:
%[t,U,I,m,dod_ah,soc,T, eis, err] = extract_profiles(xml_file,options,config)
% Inputs : 
% - xml_file:
%     -   [1xn string]: pathame to the xml file
%     -   [nx1 cell string]: xml filelist
% - options:  [1xn string] string containing execution options:
%     -   'v' :  'verbose', tell what you do
% - config:  [1x1 struct] function name used to configure the behavior (see configurator)
%
% Outputs : 
% - profiles [1x1 struct] with fields:
%     - datetime [mx1 double]: time in seconds from 1/1/2000 00:00
%     - t [mx1 double]: test time in seconds (0 to test duration)
%     - U [mx1 double]: cell voltage in V
%     - I [mx1 double]: cell current in A
%     - m [mx1 double]: mode
%     - dod_ah [mx1 double]: depth of discharge in AmpHours
%     - soc [mx1 double]: state of charge in %
%     - T [mx1 double] Temperature in °C (empty if no probe)
% - eis [1x1 struct] with fields: (empty if no EIS found in test)
%     - t [nx1 cell of [px1 double]]: time in seconds from 1/1/2000 00:00
%     - U [nx1 cell of [px1 double]]: cell voltage in V
%     - I [nx1 cell of [px1 double]]: cell current in A
%     - m [nx1 cell of [px1 double]]: mode
%     - ReZ [nx1 cell of [px1 double]]: real part of impedance (Ohm)
%     - ImZ [nx1 cell of [px1 double]]: imaginary part of impedance (Ohm)
%     - f [nx1 cell of [px1 double]]: frequency (Hz)
% - metadata: [1x1 struct] with metadata from metadata_collector
% - config:  [1x1 struct] generated config from metadata (if it was empty input)
% -  err [1x1 double] error codes
%   - err = 0: OK
%   - err = -1: xml_file file does not exist
%   - err = -2: dattes' result file is wrong
%   - err = -3: some vectors are missing (t,U,I,m)
%
% Examples:
% extract_profiles(xml_file, 'g') 'graphic', show figures
% extract_profiles(xml_file, 'v') 'verbose', tell what you do
%
% extract_profiles(this_result_file) works also
% See also dattes, metadata_collector
%
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

% Read metadata files (if they exist)
[metadata, meta_list,errors] = metadata_collector(xml_file);

% Some values initialization:
max_voltage = [];
min_voltage = [];
capacity = [];
Uname = 'U';
Tname = '';
 
% Get values from metadata:
if isfield(metadata,'cell')
    % U_min, U_max, capacity for calcul_soc
    if isfield(metadata.cell,'max_voltage')
        max_voltage = metadata.cell.max_voltage;
    end
    if isfield(metadata.cell,'min_voltage')
        min_voltage = metadata.cell.min_voltage;
    end
    if isfield(metadata.cell,'nom_capacity')
        capacity = metadata.cell.nom_capacity;
    end
end
if isfield(metadata,'cycler')
    % names for columns contaning cell voltage and temperature
    if isfield(metadata.cycler,'cell_voltage_name')
        Uname = metadata.cycler.cell_voltage_name;
    end
    if isfield(metadata.cycler,'cell_temperature_name')
        Tname = metadata.cycler.cell_temperature_name;
    end
end

% Overwrite values if they are in config:
if exist('config','var')
    if isfield(config,'test')
        if isfield(config.test,'max_voltage')
            max_voltage = config.test.max_voltage;
        end
        if isfield(config.test,'min_voltage')
            min_voltage = config.test.min_voltage;
        end
        if isfield(config.test,'capacity')
            capacity = config.test.capacity;
        end
        if isfield(config.test,'Uname')
            Uname = config.test.Uname;
        end
        if isfield(config.test,'Tname')
            Tname = config.test.Tname;
        end
    end
else
    config = struct([]);
end

if ~exist('options','var')
    options = '';
end

% thisMAT = regexprep(xml_file,'xml$','mat');

if ismember('v',options)
    fprintf('extract_profiles: %s ....',xml_file);
end

profiles = struct([]);
eis = ([]);

% if xml_read
if ~exist(xml_file,'file')
    err = -1;
    fprintf('File not found: %s\n',xml_file);
    return;
end

[xml] = lectureXMLFile4Vehlib(xml_file);

%extraire les vecteurs
%verifier si les champs existent (tabs,U,I,mode)
if any(cellfun(@(x) ~isfield(x,'tabs'),xml.table)) ||...
        any(cellfun(@(x) ~isfield(x,Uname),xml.table)) ||...
        any(cellfun(@(x) ~isfield(x,'I'),xml.table)) ||...
        any(cellfun(@(x) ~isfield(x,'mode'),xml.table))
    
    err = -3;
    fprintf('Bad XML file: %s\n',xml_file);
    return;
end

datetime = cellfun(@(x) x.tabs.vector,xml.table,'uniformoutput',false);
if any(cellfun(@(x) isnan(max(x)),datetime))
    datetime = cellfun(@(x) x.tc.vector,xml.table,'uniformoutput',false);
end

U = cellfun(@(x) x.(Uname).vector,xml.table,'uniformoutput',false);
I = cellfun(@(x) x.I.vector,xml.table,'uniformoutput',false);
m = cellfun(@(x) x.mode.vector,xml.table,'uniformoutput',false);
%decapsuler les cellules
datetime = vertcat(datetime{:});
U = vertcat(U{:});
I = vertcat(I{:});
m = vertcat(m{:});
%doublons
[datetime, Iu] = unique(datetime);
U = U(Iu);
I = I(Iu);
m = m(Iu);

T = [];

if all(cellfun(@(x) isfield(x,Tname),xml.table))
    %extraire
    T = cellfun(@(x) x.(Tname).vector,xml.table,'uniformoutput',false);
    %decapsuler les cellules
    T = vertcat(T{:});
    %doublons
    T = T(Iu);
elseif isfield(metadata,'test')
    if isfield(metadata.test,'temperature')
        %TODO metadata struct and data types validation (new function)
        T = metadata.test.temperature*ones(size(datetime));
    end
end
if isnan(max(datetime+I+U+m))%gestion d'erreurs
    error('Oups! extract_profiles a trouve des nans: %s\n',xml_file);
end

if ismember('v',options)
    fprintf('OK (XML file)\n');
end

% compile profiles
profiles(1).datetime = datetime;
profiles.t = datetime-datetime(1);
profiles.U = U;
profiles.I = I;
profiles.mode = m;
profiles.T = T;
profiles.dod_ah = [];
profiles.soc = [];

%read EIS
eis = extract_eis(xml,options);
% 
% if ismember('g',options)
%     showResult(profiles,xml_file,options);
%     showResulteis(eis,xml_file);
% end

%AUTO generate config
if isempty(max_voltage)%not found in metadata:
    max_voltage = max(U);
end
if isempty(min_voltage)%not found in metadata:
    min_voltage = min(U);
end
if isempty(capacity)%not found in metadata:
    amp_hours = calcul_amphour(datetime,I);
    capacity = max(amp_hours)-min(amp_hours);
end


% if config is empty, create a config from metadata
if isempty(config)
    % create config struct with minimal info (U_max, U_min, capacity):
    config(1).test.max_voltage = max_voltage;
    config.test.min_voltage = min_voltage;
    config.test.capacity = capacity;
    %Load defaults:
    config = cfg_default(config);
    %Update Uname, Tname:
    config.test.Uname = Uname;
    config.test.Tname = Tname;
    
    %traceability:
    config.test.cfg_file = 'autogenerated from extract_profiles';
end

% if metadata is empty, fill corresponding fields
if ~isfield(metadata,'cell')
    metadata.cell = struct;
end
% U_min, U_max, capacity for calcul_soc
if ~isfield(metadata.cell,'max_voltage')
    metadata.cell.max_voltage = max_voltage;
end
if ~isfield(metadata.cell,'min_voltage')
    metadata.cell.min_voltage = min_voltage;
end
if ~isfield(metadata.cell,'nom_capacity')
    metadata.cell.nom_capacity = capacity;
end

if ~isfield(metadata,'cycler')
    metadata.cycler = struct;
end
% names for columns contaning cell voltage and temperature
if ~isfield(metadata.cycler,'cell_voltage_name')
   metadata.cycler.cell_voltage_name = Uname;
end
if ~isfield(metadata.cycler,'cell_temperature_name')
   metadata.cycler.cell_temperature_name = Tname;
end



err=0;

end


% function showResult(profiles,xml_file,options)
% 
% [~, title_str, ~] = fileparts(xml_file);
% InherOptions = options(ismember(options,'hj'));
% h = plot_profiles(profiles,title_str,InherOptions);
% set(h,'name','extract_profiles');
% 
% end
% 
% function showResulteis(eis,xml_file)
% 
% if ~isempty(eis)
%     [~, title_str, ~] = fileparts(xml_file);
%     h = plot_eis(eis,title_str);
%     set(h,'name','extract_eis');
% end
% 
% end

function [eis] = extract_eis(xml,options)
%extract_eis extraire les variables importantes d'un essai d'impedancemetrie.
% 1.- Detecte s'il y a ReZ, ImZ, f dans la structure xml
% 2.- Extrait les vecteurs importants: t,U,I,m,ReZ, ImZ, f
%
% [t,U,I,m,ReZ, ImZ, f, err] = extract_eis(xml): utilisation normale, codes
% d'erreur:
% err = 0: tout est OK
% err = -1: le fichier xml_file n'existe pas
% err = 1: des NaNs sont presents dans les vecteurs (t,U,I,m)
%

eis = struct([]);

if ~exist('config','var')
    Uname = 'U';
else
    if ~isfield(config.test,'Uname')
        Uname = 'U';
    else
        Uname = config.test.Uname;
    end
    if ~isfield(config.test,'Tname')
        Tname = '';
    else
        Tname = config.test.Tname;
    end
end

if ismember('v',options)
    fprintf('extract_eis ....');
end


Is = cellfun(@(x) isfield(x,'freq'),xml.table);
t = cellfun(@(x) x.tabs.vector,xml.table(Is),'uniformoutput',false);
U = cellfun(@(x) x.(Uname).vector,xml.table(Is),'uniformoutput',false);
I = cellfun(@(x) x.I.vector,xml.table(Is),'uniformoutput',false);
m = cellfun(@(x) x.mode.vector,xml.table(Is),'uniformoutput',false);
ReZ = cellfun(@(x) x.ReZ.vector,xml.table(Is),'uniformoutput',false);
ImZ = cellfun(@(x) x.ImZ.vector,xml.table(Is),'uniformoutput',false);
f = cellfun(@(x) x.freq.vector,xml.table(Is),'uniformoutput',false);
Iavg = cellfun(@(x) x.Iavg.vector,xml.table(Is),'uniformoutput',false);
Iamp = cellfun(@(x) x.Iamp.vector,xml.table(Is),'uniformoutput',false);
%decapsuler les cellules
t = vertcat(t{:});
U = vertcat(U{:});
I = vertcat(I{:});
m = vertcat(m{:});
ReZ = vertcat(ReZ{:});
ImZ = vertcat(ImZ{:});
f = vertcat(f{:});
Iavg = vertcat(Iavg{:});
Iamp = vertcat(Iamp{:});
% non eis (f==0)
Is = f~=0;
t = t(Is);
U = U(Is);
I = I(Is);
m = m(Is);
ReZ = ReZ(Is);
ImZ = ImZ(Is);
f = f(Is);
Iavg = Iavg(Is);
Iamp = Iamp(Is);

%sort by time
[t, Is] = sort(t);
U = U(Is);
I = I(Is);
m = m(Is);
ReZ = ReZ(Is);
ImZ = ImZ(Is);
f = f(Is);
Iavg = Iavg(Is);
Iamp = Iamp(Is);

if ~isempty(t)
    if isnan(max(t+I+U+m))%gestion d'erreurs
        error('Oups! extract_eis found some nans\n');
    end
    %     %doublons
    %     [t, Iu] = unique(t);
    %     U = U(Iu);
    %     I = I(Iu);
    %     m = m(Iu);
    % cut vectors into individual EIS (diff(f)>0 = new EIS):
    
    % frequency sweep can be positive (low to high frequencies) >> Iend1
    % or negative (low to high frequencies) Iend2
    % Keep shortest vector (most probable situation)
    Iend1 = [diff(f)>0; true];
    Iend2 = [diff(f)<0; true];
    if length(find(Iend1))< length(find(Iend2))
        Iend = Iend1;
    else
        Iend = Iend2;
    end
    
    % Iend = [diff(f)>0; true];
    Istart = [true; Iend(1:end-1)];
    
    % Iend = [diff(f)>0; true];
    % Istart = [true; Iend(1:end-1)];
    Iend = find(Iend);
    Istart = find(Istart);
    tc = cell(size(Istart));
    Uc = cell(size(Istart));
    Ic = cell(size(Istart));
    mc = cell(size(Istart));
    ReZc = cell(size(Istart));
    ImZc = cell(size(Istart));
    fc = cell(size(Istart));
    Iavgc = cell(size(Istart));
    Iampc = cell(size(Istart));

    for ind = 1:length(Istart)
        tc{ind} = t(Istart(ind):Iend(ind));
        Uc{ind} = U(Istart(ind):Iend(ind));
        Ic{ind} = I(Istart(ind):Iend(ind));
        mc{ind} = m(Istart(ind):Iend(ind));
        ReZc{ind} = ReZ(Istart(ind):Iend(ind));
        ImZc{ind} = ImZ(Istart(ind):Iend(ind));
        fc{ind} = f(Istart(ind):Iend(ind));
        Iavgc{ind} = Iavg(Istart(ind):Iend(ind));
        Iampc{ind} = Iamp(Istart(ind):Iend(ind));

    end
    
    
    
    eis(1).datetime = tc;
    eis.U = Uc;
    eis.I = Ic;
    eis.mode = mc;
    eis.ReZ = ReZc;
    eis.ImZ = ImZc;
    eis.f = fc;
    eis.Iavg = Iavgc;
    eis.Iamp = Iampc;
    if ismember('v',options)
        fprintf('OK (EIS file)\n');
    end
    if ismember('g',options)
        showResulteis(eis);
    end
end

end
