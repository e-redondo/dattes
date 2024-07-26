function [xml_files, failed_filelist,ignored_list] = dattes_import(srcdir,cycler,options,dstdir, file_ext)
% dattes_import - Convert files from cycler to xml
%
% Usage: [xml_files, failed_filelist,ignored_list] = dattes_import(srcdir,cycler,options, dstdir)
%
% Inputs:
% - srcdir [char]: source folder to search cycler files
%          [cell]: file list of cycler files
% - cycler [char]: cycler name
%   - 'arbin_csv': search for arbin csv files
%   - 'arbin_res': search for arbin res files
%   - 'arbin_xls': search for arbin xls files
%   - 'biologic': search for biologic mpt files
%   - 'bitrode': search for bitrode csv files
%   - 'digatron': search for digatron csv files
%   - 'neware': search for neware csv files
% - options [char]:
%   - 'v': verbose, tell what you do
%   - 'f': force, export files even if xml files already exist
%   - 'u': update, export newer or non existent files
%   - 'n': dry run, perform a trial run with no import made
%   - 'm': merge, merge files in each folder into one single xml (only
%   arbin_csv and biologic)
%   - defaults: no verbose, no force
% - dstdir [char]: destination folder for xml files, if not given xml are
% written in srcdir
% - file_ext [char]: search for alternative extension (e.g. '.txt' instead
% '.mpt' for biologic files). Default extension is '.csv' for all cyclers,
% except or arbin_res ('.res' default), arbin_xls ('.xls' and '.xlsx') and
% biologic ('.mpt default) 
%
% See also import_arbin_csv, import_arbin_res, import_arbin_xls, import_biologic
% import_bitrode, import_digatron, import_neware
%
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

%TODO: flexible verbose options:
% Currently verbose is transmitted to lower level functions, to allow
% flexible verbose option, one could imagine:
% - 'v': verbose at this function, do not transmit to 2nd level functions
% - 'vv': verbose here and at second level functions
% - 'vvv': verbose here and at second and third level functions
% - 'vvvv': verbose to fourth level, and so on...
%
% verbose = ismember('v', options); true if 'v' in options
% options = options(1:end~=(find(options=='v',1))); error in no 'v' in options


% 0. check inputs
if nargin<2
    fprintf('dattes_import: Not enough parameters.\n');
    return
end
if ~ischar(srcdir) && ~iscell(srcdir)
    fprintf('dattes_import: srcdir must be a folder or a file list.\n');
    return
end
if ~ischar(cycler)
    fprintf('dattes_import: cycler must be char.\n');
    return
end

if ~exist('options','var')
    options = '';
end
if ~ischar(options)
    fprintf('dattes_import: options must be char.\n');
    return
end
if ~exist('dstdir','var')
    dstdir = '';
end
if ~ischar(dstdir)
    fprintf('dattes_import: dstdir must be char.\n');
    return
end
if ~exist('file_ext','var')
    file_ext = '';
end

%check options
verbose = ismember('v',options);
force = ismember('f',options);
% merge files in each folder (e.g. biologic, arbin) in one xml
merge = ismember('m',options);

% 1. default options depending on cycler
% merge_folder = false;

switch cycler
    case 'arbin_csv'
        import_fun = @import_arbin_csv;
        file_ext_default = '.csv';
        merge_possible = true;
    case 'arbin_res'
        import_fun = @import_arbin_res;
        file_ext_default = '.res';
        merge_possible = false;
    case 'arbin_xls'
        import_fun = @import_arbin_xls;
        file_ext_default = {'.xls','.xlsx'};
        merge_possible = false;
    case 'biologic'
        import_fun = @import_biologic;
        file_ext_default = '.mpt';
        merge_possible = true;
    case 'bitrode'
        import_fun = @import_bitrode;
        file_ext_default = '.csv';
        merge_possible = false;
    case 'digatron'
        import_fun = @import_digatron;
        file_ext_default = '.csv';
        merge_possible = false;
    case 'neware'
        import_fun = @import_neware;
        file_ext_default = '.csv';
        merge_possible = false;
    otherwise
        fprintf('Unknown cycler.\n');
        return
end

if merge && ~merge_possible
    merge = false;
    options = options(options~='m');
    warning('dattes_import: merge option not possible with %s, set to false',cycler);
end

if isempty(file_ext)
    %set default
    file_ext = file_ext_default;
end

% 2. get xml list to convert
% it's here that 'merge' option acts:
% if no merge: file_list are '.csv' (or whatever extension)
% if merge: file_list are folders contining '.csv' (or whatever extension)
[xml_list,file_list] = get_xml_list(srcdir,options,dstdir,file_ext);

if isempty(xml_list)
    fprintf('dattes_import: No %s files to import in folder "%s"\n',cycler,srcdir);
    return
end
% %remove files if they exist if not force option:
% if ~force
%     ind_existing = cellfun(@isfile,xml_list);
%     xml_list = xml_list(~ind_existing);
%     file_list = file_list(~ind_existing);
% end

% 3. main loop
[xml_files, failed_filelist,ignored_list] = main_loop(file_list, xml_list, import_fun, options);

% 4. information about results
%TODO: add performance measurements to main_loop:
% - timing: tic toc on each file,
% - file sizes
% - speed: MB/s
% - etc.
end

function [xml_list, file_list] = get_xml_list(srcdir,options,dstdir, file_ext)


% 1. find files to import
if iscell(srcdir)
    % no need to search, srcdir is a filelist
    file_list = srcdir;
else
    %FIX error when srcdir is './' or '.'
    if isequal(fileparts(srcdir),'.') || isequal(srcdir,'.')
        srcdir = pwd;
    end
    if iscell(file_ext)
        % more than one file extension to search e.g.: {'xls','xlsx'}
        file_list = cellfun(@(x) lsFiles(srcdir,x),file_ext,'UniformOutput',false);
        file_list = vertcat(file_list{:});
    else
        % just one file extension to search e.g.: 'csv'
        file_list = lsFiles(srcdir,file_ext);
    end
end

%2. get file parts to build xml pathnames
    [D,F,~] = cellfun(@fileparts,file_list,'UniformOutput',false);
%2.1 if merge option work at folder level, i.e. 2nd fileparts
if ismember('m',options)
    file_list = unique(D);
    [D,F,~] = cellfun(@fileparts,file_list,'UniformOutput',false);
end

%Two options:
[srcroot] = fileparts(srcdir);
[dstroot] = fileparts(dstdir);

if isequal(srcroot,dstroot)
% a) srcdir and dstdir are siblings (folders at same path and same level)

%Simply replace srcdir by dstdir:
xml_list = regexprep(file_list,regexptranslate('escape',srcdir),regexptranslate('escape',dstdir));
[D,F,~] = cellfun(@fileparts,xml_list,'UniformOutput',false);
xml_list = cellfun(@(x,y) fullfile(x,sprintf('%s.xml',y)),D,F,'UniformOutput',false);

else
% b) srcdir and dstdir are not siblings (folders at different paths)
%3. rebuild folder in tree in dstdir
if ~isempty(dstdir)
    % dstdir: change extension + search sourcefolder and make folder tree
    % in dstdir

    % 3.1 guess common root folder to all files in list:
    source_folder = find_common_ancestor(file_list);
    % 3.2 make valid regex expression:
    % 3.2.1 escape dots (current folder, parent folder)
    source_folder = regexprep(source_folder,'\.','\\.');
    % 3.2.1 escape fileseps
    source_folder = regexprep(source_folder,['\' filesep],['\\' filesep]);

    % 3.3 apply regexprep to reproduce file tree in destination_folder
    D = regexprep(D,['^' source_folder],dstdir);


end
%4. build xml_list
xml_list = cellfun(@(x,y) fullfile(x,sprintf('%s.xml',y)),D,F,'UniformOutput',false);

end

end

function [xml_files, failed_filelist,ignored_list] = main_loop(file_list, xml_list, import_fun, options)

verbose = ismember('v',options);
force = ismember('f',options);
update = ismember('u',options);
dryrun = ismember('n',options);

xml_files = cell(0);
failed_filelist = cell(0);
ignored_list = cell(0);

for ind = 1:length(file_list)
    force_this = force;
    %update option
    if isfile(xml_list{ind}) && update
        %check dates, if file_in newer, set force to true
        dir_in = dir(file_list{ind});
        dir_in = dir_in(~[dir_in.isdir]); % exclude folders, just check mod dates in files
        dir_out = dir(xml_list{ind});
        if any([dir_in.datenum]>dir_out.datenum)
            fprintf('dattes_import: Destination file exists, but input file is more recent, updating: %s\n',file_list{ind});
            force_this = true;
        end
    end
    if ~force_this
        if isfile(xml_list{ind})
            if verbose
                fprintf('dattes_import: %s ignored (already exists)\n',xml_list{ind});
            end
            ignored_list{end+1} = xml_list{ind};
            xml_files{end+1} = xml_list{ind};
            continue;
        end
    end
    try
        if verbose
            fprintf('dattes_import: %s ...\n',file_list{ind});
        end
        if dryrun
            %dry run (simulation), just print messages and imagine
            %xml_files are created
            xml_files{end+1} = xml_list{ind};
            if verbose
                fprintf('OK: %s\n',xml_list{ind});
            end
        else
            xml = import_fun(file_list{ind}, options);

            if isempty(xml)
                failed_filelist{end+1} = file_list{ind};
                if verbose
                    fprintf('not a valid file\n');
                end
            else
                D = fileparts(xml_list{ind});
                [~,~,~] = mkdir(D);
                ecritureXMLFile4Vehlib(xml,xml_list{ind});
                xml_files{end+1} = xml_list{ind};
                if verbose
                    fprintf('OK: %s\n',xml_list{ind});
                end
            end
        end
   catch
       failed_filelist{end+1} = file_list{ind};
       if verbose
           fprintf('FAILED\n');
       end
   end
end

end

