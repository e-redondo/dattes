function mpt2xmlf(srcdir,options)
% MPT2XML  mass import of *.mpt files (Biologic) to *.xml
% Usage:
% MPT2XML(srcdir) search all folders containing *.mpt in srcdir and write
% a *.xml for every folder
%
% mpt2xmlf(srcdir,'v') , verbose: tells what it does
% mpt2xmlf(srcdir,'f') , force: write *.xml even if it already exists
%
% See also import_biologic, mpt2xml
%
%   IFSTTAR/LTE  - E. REDONDO
%   $Revision: 0.1 $  $Created: 2015/09/08, Modified: 2022/04/01$

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
%les fichiers XML s'appelent comme les repertoires, avec extension .xml
XML = cellfun(@(x) [x '.xml'],D,'uniformoutput',false);


if ~force %cf. options
    %ne pas refaire ceux qui sont deja faits
    I = ~cellfun(@(x) exist(x,'file'),XML);
    D = D(I);
    XML = XML(I);
end

%TODO: multicore
for ind = 1:length(D)
    xml = import_biologic(D{ind});
    if ~isempty(xml)
        ecritureXMLFile4Vehlib(xml,XML{ind});
    end
    if verbose %cf. options
        fprintf('>>>>>>>>>>>>>>>%.1f%% OK\n',ind*100/length(D));
    end
end
end