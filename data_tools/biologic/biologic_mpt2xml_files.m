function [xml_list] = biologic_mpt2xml_files(srcdir,options)
% biologic_mpt2xml_files  mass import of *.mpt files (Biologic) to *.xml
%
% Usage:
% [xml_list] = biologic_mpt2xml_files(srcdir,options)
% Inputs:
% - xml_list [1x,cell] : xml files list
% Outputs:
% - srcdir [string]: source directory path
% - options :
%    - 'f' : 'force', write *.xml if it already exists
%    - 'v' : 'verbose', tells what it does
%    - 'm' : 'multicell', write *.xml separately for each cell
%
% Examples
% biologic_mpt2xml_files(srcdir) search all *.mpt in srcdir and write a *.xml for every *.mpt
% biologic_mpt2xml_files(fileList) fileList is a cell string containing a list of *.mpt
% files to convert
% biologic_mpt2xml_files(srcdir,'v') , verbose: tells what it does
% biologic_mpt2xml_files(srcdir,'t') , txt: search *.txt files instead *.mpt
% biologic_mpt2xml_files(srcdir,'f') , force: write *.xml even if it already exists
%
% WARNING! this function creates one *.xml per *.mpt file.
% If you want one *.xml per folder (multi-mpt test) use biologic_mpt2xml_folders
%
% See also import_biologic, biologic_mpt2xml_folders
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
txt = ismember('t',options);
%lister les fichiers
if txt
    ext = '.txt';
else
    ext = '.mpt';
end

if iscell(srcdir)
    MPT = srcdir;
else
    MPT = lsFiles(srcdir,ext);
end
XML = regexprep(MPT,[ext '$'],'.xml');

if ~force %cf. options
    %ne pas refaire ceux qui sont deja faits
    I = ~cellfun(@(x) exist(x,'file'),XML);
    MPT = MPT(I);
    XML = XML(I);
end


%TODO: multicore
xml_list = cell(0);

if verbose %cf. options
    fprintf('biologic_mpt2xml_files: trouve %d fichiers\n',length(MPT));
end
for ind = 1:length(MPT)
    xml = import_biologic({MPT{ind}});
    if ~isempty(xml)
        ecritureXMLFile4Vehlib(xml,XML{ind});
        xml_list{end+1} = XML{ind};
    end
    if verbose %cf. options
        fprintf('>>>>>>>>>>>>>>>%.1f%% OK\n',ind*100/length(MPT));
    end
end
end
