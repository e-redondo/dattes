function [xml_list] = arbin_xls2xml(dirname,options)
% arbin_xls2xml convert all arbin *.xls(x) files in dirname to VEHLIB's xml format
%
% Usage:
% [xml_list] = arbin_xls2xml(dirname,options)
% Inputs:
% - dirname [string]: source directory path to search xls files in
%           [nx1 cell string]: file list instead srcdir
% - options :
%    - 'f' : 'force', write *.xml if it already exists
% Output:
% - xml_list [1x,cell] : xml files list
%
% Examples
% arbin_xls2xml(dirname) search all *.res in srcdir and write a *.xml for every *.res
% arbin_xls2xml(dirname,'f') force: write *.xml even if it already exists
% arbin_xls2xml(fileList) with fileList a cell string containing a list of *.res files
%
% See also import_arbin_xls, arbin_res2xml
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
    XLS = dirname;
else
    %search for both *.xls and *.xlsx files
    XLS = lsFiles(dirname,'.xls');
    XLSX = lsFiles(dirname,'.xlsx');
    XLS = [XLS(:); XLSX(:)];
    
end
XML = regexprep(XLS,'xls$','xml');
XML = regexprep(XML,'xlsx$','xml');

if ~ismember('f',options)
    %ne pas refaire ceux qui sont deja faits
    I = ~cellfun(@(x) exist(x,'file'),XML);
    XLS = XLS(I);
    XML = XML(I);
end


%TODO: multicore
xml_list = cell(0);
for ind = 1:length(XLS)
    xml = import_arbin_xls(XLS{ind});
    if ~isempty(xml)
        ecritureXMLFile4Vehlib(xml,XML{ind});
        xml_list{end+1} = XML{ind};
    end
    fprintf('%d of %d OK\n',ind,length(XLS));
end
end
