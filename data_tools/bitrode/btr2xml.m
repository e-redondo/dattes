function [xml_list] = btr2xml(srcdir,options)
% btr2xml mass import of *.csv file (Bitrode) to *.xml
%
% Usage:
% btr2xml(srcdir) search all *.csv in srcdir and write a *.xml for every *.csv
%
% btr2xml(fileList) fileList is a cell string containing a list of *.csv
% files to convert
%
% btr2xml(...,'f') option 'force', write *.xml if it already exists
% btr2xml(...,'v') option 'verbose', tells what it does
% btr2xml(...,'m') option 'multicell', write *.xml separately for each cell
%
%
% See also import_bitrode, read_bitrode_log, write_bitrode_log
%
%   IFSTTAR/LTE  - E. REDONDO
%   $Created: 2015/09/08, Modified: 2022/04/01$

%2015/09/09 4 fichiers CSV (178Mo), multiCell > 12 fichiers XML (459Mo),
%111sec. (1.6Mo/sec. lecture)

if ~exist('options','var')
    options='';
end
verbose = ismember('v',options);

if ~exist('srcdir','var')
    fprintf('ERROR: btr2xml needs at least one input\n')
    return
end

multicell = ismember('m',options);

if iscell(srcdir)
    CSV = srcdir;
else
    CSV = lsFiles(srcdir,'.csv');
end

if ~ismember('f',options)
    if ~multicell
        XML = regexprep(CSV,'csv$','xml');
    else
        XML = regexprep(CSV,'.csv$','_el1.xml');
    end
    %ne pas refaire ceux qui sont deja faits
    I = ~cellfun(@(x) exist(x,'file'),XML);
    CSV = CSV(I);
end
XML = regexprep(CSV,'csv$','xml');

%TODO: multicore
xml_list = cell(0);

for ind = 1:length(CSV)
    xml = import_bitrode(CSV{ind});
    
    if isempty(xml.table{end}.metatable.date)
        %    if isempty('')%DEBUG
        if iscell(srcdir)
            % if a file list is provided, take the parent folder of each
            % CSV file
            Date = read_bitrode_log(fileparts(CSV{ind}),CSV{ind});%from user created log file
        else
            % if a srcdir is provided, take it to search bitrode.log file
            Date = read_bitrode_log(srcdir,CSV{ind});%from user created log file
        end
        
        if isempty(Date)
            fprintf('No test date found for %s\n',CSV{ind});
            Date = '2000/1/1 00:00';
        end
        Datem = datenum(Date,'yyyy/mm/dd HH:MM');%format MATLAB
    else
        Date = xml.table{end}.metatable.date;%from Bitrode metadata
        Datem = datenum(Date,'dd/mm/yyyy HH:MM');%format MATLAB
    end
    Datee = m2edate(Datem);%format 'Eduardo'
    %ajouter la date
    tabs = xml.table{end}.tc.vector + Datee;
    tabs = makeXMLVariable('tabs', 's', '%f', 'temps absolu', tabs);
    xml.table{end}.tabs = tabs;
    xml.table{end} = sort_bench_variables(xml.table{end});
    if ~isempty(xml)
        if ~multicell
            ecritureXMLFile4Vehlib(xml,XML{ind});
             xml_list{end+1} = XML{ind};
        else
            xmls = extraitMultiCell(xml);
            for ind2 = 1:length(xmls)
                ceXML = xmls{ind2};
                XMLfile = regexprep(XML{ind},'.xml$',sprintf('_el%d.xml',ind2));
                ecritureXMLFile4Vehlib(ceXML,XMLfile);
                xml_list{end+1} = XMLfile;
            end
        end
    end
    if verbose
        fprintf('%d sur %d OK\n',ind,length(CSV));
    end
end
end


function xmls = extraitMultiCell(xml)
%TODO: choisir quelle cellules exporter (capteurs branches)
listeChamps = fieldnames(xml.table{end});
[varCell, autresVars] = regexpFiltre(listeChamps,'(U|T)[1-9]');
[UCell, TCell] = regexpFiltre(varCell,'U');
xmls = cell(size(UCell));
for ind = 1:length(UCell)
    xmls{ind} = xml;
    xmls{ind}.table{end} = rmfield(xmls{ind}.table{end},UCell);
    xmls{ind}.table{end} = rmfield(xmls{ind}.table{end},TCell);
    %je prends la tension de la cellule
    xmls{ind}.table{end}.U = xml.table{end}.(UCell{ind});
    xmls{ind}.table{end}.U.name = 'U';
    xmls{ind}.table{end}.U.longname = 'U';
end
for ind = 1:length(TCell)%TODO: verifier que T1 correspond a U1, etc.
    %je prends la temperature de la cellule
    xmls{ind}.table{end}.T = xml.table{end}.(TCell{ind});
    xmls{ind}.table{end}.T.name = 'T';
    xmls{ind}.table{end}.T.longname = 'T';
end

end