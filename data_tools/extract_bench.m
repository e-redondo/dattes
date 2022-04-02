function [t,U,I,m,DoDAh,SOC,T, err] = extract_bench(thisXML,options,config)
%extract_bench extract important variables from a battery test bench file.
% 1.- Read a .xml file (Biologic,Arbin, Bitrode...), if a dattes' results
% file exists this latter will be read (faster)
% 2.- Extract important vectors: t,U,I,m,DoDAh,SOC,T
% 3.- Save the important vectors in a dattes' results file (if 's' in
% options)
%
% [t,U,I,m,DoDAh,SOC,T, err] = extract_bench(thisXML): normal operation,
% error codes:
% err = 0: OK
% err = -1: thisXML file does not exist
% err = -2: dattes' result file is wrong
% err = -3: some vectors are missing (t,U,I,m)
%
% extract_bench(thisXML, 's') 'save' the extracted vecors in a dattes'
% result file
% extract_bench(thisXML, 'g') 'graphic', show figures
% extract_bench(thisXML, 'v') 'verbose', tell what you do
% extract_bench(thisXML, 'f') 'force', read XML even if result file exists
% extract_bench(thisXML, 'u') 'update', read XML if result file is older
%
% extract_bench(this_result_file) works also
% See also mode_bench2, decompose_bench

if ~exist('config','var')
    Uname = 'U';
else
    if ~isfield(config,'Uname')
        Uname = 'U';
    else
        Uname = config.Uname;
    end
    if ~isfield(config,'Tname')
        Tname = '';
    else
        Tname = config.Tname;
    end
end
if ~exist('options','var')
    options = '';
end

thisMAT = regexprep(thisXML,'xml$','mat');

if ismember('f',options) || ~exist(thisMAT,'file')
    xml_read = true;
elseif ismember('u',options)
    xml_dir = dir(thisXML);
    mat_dir = dir(thisMAT);
    if isempty(mat_dir)
        %xml_read true if thisMAT does not exist
        xml_read = true;
    else
        %xml_read true if mat older than xml
        %xml_read false if mat newer than xml
        xml_read = mat_dir.datenum<xml_dir.datenum;
    end
else
    xml_read = false;
end

if ismember('v',options)
    fprintf('extract_bench: %s ....',thisXML);
end
if xml_read
    if ~exist(thisXML,'file')
        t = [];
        U = [];
        I = [];
        m = [];
        err = -1;
        fprintf('File not found: %s\n',thisXML);
        return;
    end
    %     [xmlD, xmlF] = fileparts(thisXML);
    %     xmlF = sprintf('%s.xml',xmlF);
    if ismember('v',options) && ~ismember('s',options)
        fprintf('l''option ''s'' est fortement conseillee lecture du XML,...');
    end
    [xml] = lectureXMLFile4Vehlib(thisXML);
    %     if err
    %         t = [];U = [];I = [];m = [];DoDAh = [];SOC = [];
    %         fprintf('Bad XML file: %s\n',thisXML);
    %         return;
    %     end
    %extraire les vecteurs
    %verifier si les champs existent (tabs,U,I,mode)
    if any(cellfun(@(x) ~isfield(x,'tabs'),xml.table)) ||...
            any(cellfun(@(x) ~isfield(x,Uname),xml.table)) ||...
            any(cellfun(@(x) ~isfield(x,'I'),xml.table)) ||...
            any(cellfun(@(x) ~isfield(x,'mode'),xml.table))
        
        t = [];U = [];I = [];m = [];DoDAh = [];SOC = [];err = -3;
        fprintf('Bad XML file: %s\n',thisXML);
        return;
    end
    
    t = cellfun(@(x) x.tabs.vector,xml.table,'uniformoutput',false);
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
        error('Oups! extract_bench a trouve des nans: %s\n',thisXML);
    end
    if ismember('s',options)
        saveMAT(t,U,I,m,T,thisMAT);
    end
    if ismember('v',options)
        fprintf('OK (XML file)\n');
    end
else
    %list variables in MAT file
    S = who('-file',thisMAT);
    if ~ismember('t',S) || ~ismember('U',S) || ~ismember('I',S) || ~ismember('m',S)
        err = -2;
        t = [];U = [];I = [];m = [];DoDAh = [];SOC = [];
        fprintf('Bad MAT file: %s\n',thisMAT);
        return;
    end
    load(thisMAT);
    if ismember('v',options)
        fprintf('OK (MAT file)\n');
    end
end
if ismember('g',options)
    showResult(t,U,I,m,thisMAT,options);
end

err=0;
if ~exist('DoDAh','var')
    DoDAh = [];
end
if ~exist('SOC','var')
    SOC = [];
end
if ~exist('T','var')
    T = [];
end
end

function saveMAT(t,U,I,m,T,thisMAT)
save(thisMAT);
end

function showResult(t,U,I,m,thisMAT,options)

[~, titre, ~] = fileparts(thisMAT);
InherOptions = options(ismember(options,'hj'));
h = plotBanc(t,U,I,m,titre,InherOptions);
set(h,'name','extract_bench');

end
