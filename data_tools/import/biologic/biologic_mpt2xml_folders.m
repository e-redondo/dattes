function [xml_list] = biologic_mpt2xml_folders(srcdir,options)
% biologic_mpt2xml_folders  mass import of *.mpt files (Biologic) to *.xml
%
% Usage:
% [xml_list] = biologic_mpt2xml_folders(srcdir,options)
% Outputs:
% - srcdir [string]: source directory path to search .mpt files in.
%          [nx1 cell string]: file list instead srcdir
% - options :
%    - 'f' : 'force', write *.xml if it already exists
%    - 'v' : 'verbose', tells what it does
% Output:
% - xml_list [nx1 cell] : xml files list
%
% Examples
% biologic_mpt2xml_folders(srcdir) search all folders containing *.mpt in srcdir and write
% a *.xml for every folder
%    - if srcdir contains mpt files AND does not contain any subfolder an
%    xmlfile wil be created at the same place that srcdir with
% 
% biologic_mpt2xml_folders(srcdir,'v') , verbose: tells what it does
% biologic_mpt2xml_folders(srcdir,'f') , force: write *.xml even if it already exists
%
% See also import_biologic, biologic_mpt2xml_files
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

if nargin==0
    error('at least one input must be given')
end
if ~exist('options','var')
    options = '';
end
%options d'execution
force = ismember('f',options);
verbose = ismember('v',options);

%liste de repertoires
D = lsDirs(srcdir);

if isempty(D)
    MPT = lsFiles(srcdir,'.mpt');
    if ~isempty(MPT)
        D = unique(cellfun(@fileparts,MPT,'UniformOutput',false));
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
    xml = import_biologic(D{ind});
    if ~isempty(xml)
        ecritureXMLFile4Vehlib(xml,XML{ind});
        xml_list{end+1} = XML{ind};
    end
    if verbose %cf. options
        fprintf('>>>>>>>>>>>>>>>%.1f%% OK\n',ind*100/length(D));
    end
end
end
