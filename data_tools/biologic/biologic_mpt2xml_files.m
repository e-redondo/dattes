function [xml_list] = biologic_mpt2xml_files(srcdir,options)
% biologic_mpt2xml_files  mass import of *.mpt files (Biologic) to *.xml
% Usage:
% biologic_mpt2xml_files(srcdir) search all *.mpt in srcdir and write a *.xml for every *.mpt
%
% biologic_mpt2xml_files(fileList) fileList is a cell string containing a list of *.mpt
% files to convert
%
% biologic_mpt2xml_files(srcdir,'v') , verbose: tells what it does
% biologic_mpt2xml_files(srcdir,'t') , txt: search *.txt files instead *.mpt
% biologic_mpt2xml_files(srcdir,'f') , force: write *.xml even if it already exists
%
% WARNING! this function creates one *.xml per *.mpt file.
% If you want one *.xml per folder (multi-mpt test) use biologic_mpt2xml_folders
%
% See also import_biologic, biologic_mpt2xml_folders
%
%   IFSTTAR/LTE  - E. REDONDO
%   $Revision: 0.1 $  $Created: 2015/08/12, Modified: 2022/04/01$

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
