function [xml_list] = arbin_csv2xml_files(dirname,options)
% arbin_csv2xml_files convert all arbin *.csv(x) files in dirname to VEHLIB's xml format
%
% This function search for csv files, read these files and convert each csv
% files in xml files.
%
% Usage:
% [xml_list] = arbin_csv2xml_files(dirname,options)
% Inputs:
% - dirname [string]: source directory path to search csv files in
%           [nx1 cell string]: file list instead srcdir
% - options :
%    - 'f' : 'force', write *.xml if it already exists
% Output:
% - xml_list [1x,cell] : xml files list
%
% Examples
% arbin_csv2xml_files(dirname) search all *.csv in srcdir and write a *.xml for every *.csv
% arbin_csv2xml_files(dirname,'f') force: write *.xml even if it already exists
% arbin_csv2xml_files(fileList) with fileList a cell string containing a list of *.csv files
%
% See also import_arbin_csv, arbin_csv2xml_folders
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

if ~exist('options','var')
    options='';
end
if nargin==0
    print_usage;
end

if iscell(dirname)
    %if dirname is a cell string, it is a filelist
    CSV = dirname;
else
    %search for *.csv files
    CSV = lsFiles(dirname,'.CSV');
    
end
XML = regexprep(CSV,'.CSV$','.xml');
XML = regexprep(XML,'.csv$','.xml');

if ~ismember('f',options)
    %ne pas refaire ceux qui sont deja faits
    I = ~cellfun(@(x) exist(x,'file'),XML);
    CSV = CSV(I);
    XML = XML(I);
end


%TODO: multicore
xml_list = cell(0);
for ind = 1:length(CSV)
    xml = import_arbin_csv(CSV{ind});
    if ~isempty(xml)
        ecritureXMLFile4Vehlib(xml,XML{ind});
        xml_list{end+1} = XML{ind};
    end
    fprintf('%d of %d OK\n',ind,length(CSV));
end
end
