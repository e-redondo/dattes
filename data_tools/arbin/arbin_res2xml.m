function res2xml(dirname,options)
% RES2XML mass import of  *.res (Arbin) to *.xml
% Usage:
% RES2XML(dirname) search all *.res in srcdir and write a *.xml for every *.res
%
% RES2XML(dirname,'f') force: write *.xml even if it already exists
%
% RES2XML(fileList) with fileList a cell string containing a list of *.res files
%
% See also import_arbin_res
%
%   IFSTTAR/LTE  - E. REDONDO
%   $Revision: 0.1 $  $Created: 2015/08/12, Modified: 2015/08/12$


if ~exist('options','var')
    options='';
end
if nargin==0
    print_usage;
end

if iscell(dirname)
    RES = dirname;
else
    RES = lsFiles(dirname,'.res');
end
XML = regexprep(RES,'res$','xml');

if ~ismember('f',options)
    %ne pas refaire ceux qui sont deja faits
    I = ~cellfun(@(x) exist(x,'file'),XML);
    RES = RES(I);
    XML = XML(I);
end


%TODO: multicore

for ind = 1:length(RES)
    xml = import_arbin_res(RES{ind});
    if ~isempty(xml)
        ecritureXMLFile4Vehlib(xml,XML{ind});
    end
    fprintf('%d of %d OK\n',ind,length(RES));
end
end