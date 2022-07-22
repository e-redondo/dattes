function [xml_list] = arbin_csv2xml_folders(srcdir,options)
% arbin_csv2xml_folders  mass import of *.csv files (Arbin) to *.xml
%
% This funciton search on each subfolder for csv files, read these files and
% merge them into one xml file.
%
% Usage:
% [xml_list] = arbin_csv2xml_folders(srcdir,options)
% Outputs:
% - srcdir [string]: source directory path to search .csv files in.
% - options :
%    - 'f' : 'force', write *.xml if it already exists
%    - 'v' : 'verbose', tells what it does
% Output:
% - xml_list [nx1 cell] : xml files list
%
% Examples
% arbin_csv2xml_folders(srcdir) search all folders containing *.csv in srcdir and write
% a *.xml for each folder
%    - if srcdir contains csv files AND does not contain any subfolder an
%    xmlfile wil be created at the same place that srcdir with same name
%    and '.xml' extension
% 
% arbin_csv2xml_folders(srcdir,'v') , verbose: tells what it does
% arbin_csv2xml_folders(srcdir,'f') , force: write *.xml even if it already exists
%
% See also import_arbin_csv, arbin_csv2xml_files
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

if nargin==0
    error('arbin_csv2xml_folders: at least one input must be given')
end

if ~isdir(srcdir)
    error('arbin_csv2xml_folders: srcdir must be a folder path')
end

if ~exist('options','var')
    options = '';
end

if ~ischar(options)
    error('arbin_csv2xml_folders: options must be a string')
end

%options d'execution
force = ismember('f',options);
verbose = ismember('v',options);

%liste de repertoires
D = lsDirs(srcdir);

if isempty(D)
    CSV = lsFiles(srcdir,'.csv');
    if ~isempty(CSV)
        D = unique(cellfun(@fileparts,CSV,'UniformOutput',false));
    end
end
%les fichiers XML s'appelent comme les repertoires, avec extension .xml
XML = cellfun(@(x) [x '.xml'],D,'uniformoutput',false);


if ~force %cf. options
    %ne pas refaire ceux qui sont deja faits
    I = ~cellfun(@(x) exist(x,'file'),XML);
    D = D(I);
    XML = XML(I);
end

%TODO: multicore
xml_list = cell(0);

for ind = 1:length(D)
    %for each folder containing CSV files:
    csv_list = lsFiles(D{ind},'.CSV',true);%toponly, do not search on subfolders
    %get a cell of xml structs:
    xml = cellfun(@import_arbin_csv, csv_list, 'UniformOutput', false);
    % remove empty values (not compatible csv files):
    Ie = cellfun(@isempty,xml);
    xml = xml(~Ie);
    %merge all elements into first one:
    for ind2 = 2:length(xml)
        xml{1} = XMLFusion(xml{1},xml{ind2});
    end
    % keep just first (merged element):
    xml =  xml{1};
    if ~isempty(xml)
        ecritureXMLFile4Vehlib(xml,XML{ind});
        xml_list{end+1} = XML{ind};
    end
    if verbose %cf. options
        fprintf('>>>>>>>>>>>>>>>%.1f%% OK\n',ind*100/length(D));
    end
end
end
