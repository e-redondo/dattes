function [xml_list, xls_failed] = arbin_xls2xml(srcdir,options)
% arbin_xls2xml  mass import of *.xls(x) files (Arbin) to *.xml
%
% This function search on each subfolder for xls files, convert them to csv
% and convert them to xml file.
%
% Usage:
% [xml_list] = arbin_xls2xml(srcdir,options)
% Inputs:
% - srcdir [string]: source directory path to search .xls files in.
% - srcdir [cell]: list of .xls(x) files
% - options :
%    - 'f' : 'force', write *.xml if it already exists
%    - 'v' : 'verbose', tells what it does
% Output:
% - xml_list [nx1 cell] : xml files list
%
% Examples
% arbin_xls2xml(srcdir) search all folders containing *.xls(x) in srcdir and write
% a *.xml for each *.xls(x) file
% arbin_xls2xml(srcdir,'v') , verbose: tells what it does
% arbin_xls2xml(srcdir,'f') , force: write *.xml even if it already exists
%
% See also import_arbin_csv, arbin_csv2xml_folders
%
% Copyright 2023 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab:
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

if nargin==0
    error('arbin_xls2xml: at least one input must be given')
end

if ~ischar(srcdir) && ~iscell(srcdir)
    error('arbin_xls2xml: srcdir must be a folder path (char) or a file list (cell)')
end

if ~exist('options','var')
    options = '';
end

if ~ischar(options)
    error('arbin_xls2xml: options must be a string')
end

%options d'execution
force = ismember('f',options);
verbose = ismember('v',options);

%filelist
if iscell(srcdir)
    %filelist given in input, keep just xls(x) extensions:
    XLS = regexpFiltre(srcdir,'\.xlsx*$');
else
    %srcdir given in input, search for xls(x) files:
    XLS = lsFiles(srcdir,'.xls');
    XLSX = lsFiles(srcdir,'.xlsx');
    XLS = [XLS(:); XLSX(:)];
end

XML = regexprep(XLS,'xls$','xml');
XML = regexprep(XML,'xlsx$','xml');
xml_already_existing = cell(0);

if ~force %cf. options
    %do not convert xls(x) files when corresponding xml already existing
    I = ~cellfun(@(x) exist(x,'file'),XML);
    xml_already_existing = XML(~I);
    XLS = XLS(I);
    XML = XML(I);
end

%TODO: multicore
xml_list = cell(0);
xls_failed = cell(0);

%for each xls file:
for ind = 1:length(XLS)
    D = dir(XLS{ind});
    fprintf('arbin_xls2xml:%s (%g MB)\n',XLS{ind},D.bytes/(1024*1024))
    try
        ts = tic;
        %convert to csv
        csv_folder = xls2csv(XLS{ind});


        [xml_list] = arbin_csv2xml_folders(csv_folder,options);

        %delete csv folder
        delete(fullfile(csv_folder,'*.csv'));
        rmdir(csv_folder)

        t_elapsed = toc(ts);
        if verbose
            %         fprintf('%d of %d OK\n',ind,length(XLS));
            fprintf('%d of %d OK (%g MB/s)\n',ind,length(XLS),D.bytes/(t_elapsed*1024*1024));
        end
    catch e
        xls_failed{end+1} = XLS{ind};
        fprintf('%d of %d FAILED\n',ind,length(XLS));
    end
end
xml_list = [xml_list(:); xml_already_existing(:)];
end
