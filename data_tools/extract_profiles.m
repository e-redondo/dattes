function [profiles, eis, err] = extract_profiles(xml_file,options,config)
%extract_profiles extract important variables from a battery test bench file.
%
%[t,U,I,m,dod_ah,soc,T, eis, err] = extract_profiles(xml_file,options,config)
% 1.- Read a .xml file (Biologic,Arbin, Bitrode...), if a dattes' results
% file exists this latter will be read (faster)
% 2.- Extract important vectors: t,U,I,m,DoDAh,SOC,T
% 3.- Save the important vectors in a dattes' results file (if 's' in
% options)
%
% Usage:
%[t,U,I,m,dod_ah,soc,T, eis, err] = extract_profiles(xml_file,options,config)
% Inputs : 
% - xml_file:
%     -   [1xn string]: pathame to the xml file
%     -   [nx1 cell string]: xml filelist
% - options:  [1xn string] string containing execution options:
%     -   's' :  'save' the extracted vectors in a dattes'
%     -   'v' :  'verbose', tell what you do
%     -   'f' :  'force', read XML even if result file exists
%     -   'u' :  'update', read XML if result file is older
% - config:  [1x1 struct] function name used to configure the behavior (see configurator)
%
% Outputs : 
% - t [nx1 double]: time in seconds
% - U [nx1 double]: cell voltage in V
% - dod_ah [nx1 double]: depth of discharge in AmpHours
% - m [nx1 double]: mode
% - soc [nx1 double]: state of charge in %
% - T [nx1 double] Temperature in °C
% -  err [nx1 double] error codes
%   - err = 0: OK
%   - err = -1: xml_file file does not exist
%   - err = -2: dattes' result file is wrong
%   - err = -3: some vectors are missing (t,U,I,m)
%
% Examples:
% extract_profiles(xml_file, 's') 'save' the extracted vecors in a dattes'
% result file
% extract_profiles(xml_file, 'g') 'graphic', show figures
% extract_profiles(xml_file, 'v') 'verbose', tell what you do
% extract_profiles(xml_file, 'f') 'force', read XML even if result file exists
% extract_profiles(xml_file, 'u') 'update', read XML if result file is older
%
% extract_profiles(this_result_file) works also
% See also dattes, which_mode, split_phases
%
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

if ~exist('config','var')
    Uname = 'U';
    Tname = '';
elseif isfield(config,'test')
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
else
    Uname = 'U';
    Tname = '';
end
if ~exist('options','var')
    options = '';
end

thisMAT = regexprep(xml_file,'xml$','mat');

% if ismember('f',options) || ~exist(thisMAT,'file')
%     xml_read = true;
% elseif ismember('u',options)
%     xml_dir = dir(xml_file);
%     mat_dir = dir(thisMAT);
%     if isempty(mat_dir)
%         %xml_read true if thisMAT does not exist
%         xml_read = true;
%     else
%         %xml_read true if mat older than xml
%         %xml_read false if mat newer than xml
%         xml_read = mat_dir.datenum<xml_dir.datenum;
%     end
% else
%     xml_read = false;
% end

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
%     [xmlD, xmlF] = fileparts(xml_file);
%     xmlF = sprintf('%s.xml',xmlF);
if ismember('v',options) && ~ismember('s',options)
    fprintf('l''option ''s'' est fortement conseillee lecture du XML,...');
end
[xml] = lectureXMLFile4Vehlib(xml_file);
%     if err
%         t = [];U = [];I = [];m = [];DoDAh = [];SOC = [];
%         fprintf('Bad XML file: %s\n',xml_file);
%         return;
%     end
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

t = cellfun(@(x) x.tabs.vector,xml.table,'uniformoutput',false);
if any(cellfun(@(x) isnan(max(x)),t))
    t = cellfun(@(x) x.tc.vector,xml.table,'uniformoutput',false);
end

U = cellfun(@(x) x.(Uname).vector,xml.table,'uniformoutput',false);
I = cellfun(@(x) x.I.vector,xml.table,'uniformoutput',false);
m = cellfun(@(x) x.mode.vector,xml.table,'uniformoutput',false);
%decapsuler les cellules
t = vertcat(t{:});
U = vertcat(U{:});
I = vertcat(I{:});
m = vertcat(m{:});
%doublons
[t, Iu] = unique(t);
U = U(Iu);
I = I(Iu);
m = m(Iu);

if all(cellfun(@(x) isfield(x,Tname),xml.table))
    %extraire
    T = cellfun(@(x) x.(Tname).vector,xml.table,'uniformoutput',false);
    %decapsuler les cellules
    T = vertcat(T{:});
    %doublons
    T = T(Iu);
else
    T = [];
end
if isnan(max(t+I+U+m))%gestion d'erreurs
    error('Oups! extract_profiles a trouve des nans: %s\n',xml_file);
end
%     if ismember('s',options)
%         saveMAT(t,U,I,m,T,thisMAT);
%     end
if ismember('v',options)
    fprintf('OK (XML file)\n');
end
% compile profiles
profiles(1).t = t;
profiles.U = U;
profiles.I = I;
profiles.m = m;
profiles.T = T;
profiles.dod_ah = [];
profiles.soc = [];

%read EIS
eis = extract_eis(xml,options);

% else
%     %list variables in MAT file
%     S = who('-file',thisMAT);
%     if ~ismember('t',S) || ~ismember('U',S) || ~ismember('I',S) || ~ismember('m',S)
%         err = -2;
%         fprintf('Bad MAT file: %s\n',thisMAT);
%         return;
%     end
%     % read profiles
% %     load(thisMAT);
%     if ismember('v',options)
%         fprintf('OK (MAT file)\n');
%     end
%     %read EIS
%     thisMAT_result = result_filename(thisMAT);
%     
%     if exist(thisMAT_result,'file')
%         load(thisMAT_result);
%         if isfield(result,'eis')
%             eis = result.eis;
%         else
%             eis = [];
%         end
%     else
%         eis = [];
%     end
% end

if ismember('g',options)
    showResult(t,U,I,m,thisMAT,options);
end

err=0;
% if ~exist('dod_ah','var')
%     dod_ah = [];
% end
% if ~exist('soc','var')
%     soc = [];
% end
% if ~exist('T','var')
%     T = [];
% end
end

function saveMAT(t,U,I,m,T,thisMAT)
save(thisMAT,'-v7','t','U','I','m','T');
end

function showResult(t,U,I,m,thisMAT,options)

[~, titre, ~] = fileparts(thisMAT);
InherOptions = options(ismember(options,'hj'));
h = plot_profiles(t,U,I,m,titre,InherOptions);
set(h,'name','extract_profiles');

end

function showResulteis(eis)

h = plot_eis(eis,'extract_eis');
set(h,'name','extract_eis');

end

function [eis] = extract_eis(xml,options)
%extract_eis extraire les variables importantes d'un essai d'impedancemetrie.
% 1.- Detecte s'il y a ReZ, ImZ, f dans la structure xml
% 2.- Extrait les vecteurs importants: t,U,I,m,ReZ, ImZ, f
%
% [t,U,I,m,ReZ, ImZ, f, err] = extract_eis(xml,thisMAT): utilisation normale, codes
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
%decapsuler les cellules
t = vertcat(t{:});
U = vertcat(U{:});
I = vertcat(I{:});
m = vertcat(m{:});
ReZ = vertcat(ReZ{:});
ImZ = vertcat(ImZ{:});
f = vertcat(f{:});
% non eis (f==0)
Is = f~=0;
t = t(Is);
U = U(Is);
I = I(Is);
m = m(Is);
ReZ = ReZ(Is);
ImZ = ImZ(Is);
f = f(Is);

%sort by time
[t, Is] = sort(t);
U = U(Is);
I = I(Is);
m = m(Is);
ReZ = ReZ(Is);
ImZ = ImZ(Is);
f = f(Is);

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
    for ind = 1:length(Istart)
        tc{ind} = ReZ(Istart(ind):Iend(ind));
        Uc{ind} = ReZ(Istart(ind):Iend(ind));
        Ic{ind} = ReZ(Istart(ind):Iend(ind));
        mc{ind} = ReZ(Istart(ind):Iend(ind));
        ReZc{ind} = ReZ(Istart(ind):Iend(ind));
        ImZc{ind} = ImZ(Istart(ind):Iend(ind));
        fc{ind} = f(Istart(ind):Iend(ind));
    end
    
    
    
    eis(1).t = tc;
    eis.U = Uc;
    eis.I = Ic;
    eis.m = mc;
    eis.ReZ = ReZc;
    eis.ImZ = ImZc;
    eis.f = fc;
    if ismember('v',options)
        fprintf('OK (EIS file)\n');
    end
    if ismember('g',options)
        showResulteis(eis);
    end
end

end
