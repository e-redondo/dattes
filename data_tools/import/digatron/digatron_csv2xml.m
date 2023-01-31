function [xml_list] = digatron_csv2xml(srcdir,options)
% digatron_csv2xml mass import of *.csv file (digatron) to *.xml
%
% Usage:
% [xml_list] = digatron_csv2xml(srcdir,options)
% Outputs:
% - srcdir [string]: source directory path to search csv files in.
%          [nx1 cell string]: file list instead srcdir
% - options :
%    - 'f' : 'force', write *.xml if it already exists
%    - 'v' : 'verbose', tells what it does
%    - 'm' : 'multicell', write *.xml separately for each cell
% Inputs:
% - xml_list [nx1 cell] : xml files list
%
% Examples
% digatron_csv2xml(srcdir) search all *.csv in srcdir and write a *.xml for every *.csv
% digatron_csv2xml(fileList) fileList is a cell string containing a list of *.csv
% files to convert
% digatron_csv2xml(...,'f') option 'force', write *.xml if it already exists
% digatron_csv2xml(...,'v') option 'verbose', tells what it does
%
% See also import_digatron
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

if ~exist('options','var')
    options='';
end
verbose = ismember('v',options);

if ~exist('srcdir','var')
    fprintf('ERROR: digatron_csv2xml needs at least one input\n')
    return
end

if iscell(srcdir)
    CSV = srcdir;
else
    CSV = lsFiles(srcdir,'.csv');
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
    xml = import_digatron(CSV{ind});
    if ~isempty(xml)
        ecritureXMLFile4Vehlib(xml,XML{ind});
        xml_list{end+1} = XML{ind};
    end
    fprintf('%d of %d OK\n',ind,length(CSV));
end
end