function result = dattes_structure(file_in, options, destination_folder, read_mode)
% dattes_structure - DATTES Import function
%
% This function read .xml (or .json, or .csv) files, read metadata files
% (.meta) and performs some basic calculations (which_mode, split_phases,
% calcul_soc). The results are given as output and can be stored in mat
% files.
%
% Usage:
% result = dattes_structure(file_in)
% - read single file (json, csv, or xml), default options
% result = dattes_structure(file_in, 's')
% - read single file, MAT file will be saved beside file_in (same pathname, different extension)
% result = dattes_structure(file_in,'s',destination_folder)
% - read single file, MAT file will be saved in destination_folder
% result = dattes_structure(file_list,...)
% - read each file in file_list, result is [mx1 cell struct]
% result = dattes_structure(source_folder,options,destination_folder, read_mode)
% - read each file in source_folder result is [mx1 cell struct],
% read_mode must be specified ('json', 'csv' or 'xml')
%
% Inputs:
% - file_in [1xp string]: filename to read , or
% - file_list [mx1 cell string]: file list to read, or
% - source_folder [1xp string]: source folder to search files to read
% - options [1xn string]:
%    - 'S': run calcul_soc (default if no soc vector is in file_in)
%    - 'm': run which_mode (default if no mode vector is in file_in)
%    - 'v': verbose, tell what you do
%    - 's': save result(s) in mat file(s)
%    - 'f': force, read file_in even if mat file exists, otherwise read mat file instead
%    - 'u': update, read if mat file exists but is older than file_in
% - destination_folder [1xp string]: folder to store mat files.
%     If not given, mat files will be stored beside file_in
% - read_mode [1x3 or 1x4 string]: needed if source_folder, optional if not
%    - xml: read xml files
%    - json: read json files
%    - csv: read csv files
% Output:
% - result [1x1 struct] DATTES result structure
% - result [mx1 cell struct] DATTES result cell structure if multiple files read
%
% See also dattes_import, dattes_configure
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab:
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

%TODO: verbose messages
%TODO?: v = verbose, vvv = very verbose (transmit 'v' to child functions)
%TODO: read_mode vs. file_ext: dattes_import(src_folder, options, dest_folder, read_mode, file_ext)
% - enable file_ext search in src_folder
% - enable read mode different from file ext
% Example: 'search for .txt files and read them as csv:
%            dattes_import(src_folder, options, dest_folder, 'csv', '.txt') 
% Example: 'search for .json files (and read them as json):
%            dattes_import(src_folder, options, dest_folder, 'json') 
% Example: (DEFAULT) 'search for .xml files (and read them as xml)'
%            dattes_import(src_folder, options, dest_folde) 




%0.1 check inputs:
if ~exist('file_in','var')
    fprintf('ERROR dattes_structure: file_in is mandatory\n');
    result = [];
    return
end
if ~ischar(file_in) && ~iscell(file_in)
    fprintf('ERROR dattes_structure: file_in must be string or cell string\n');
    result = [];
    return
end
if ~exist('options','var')
    options = '';
elseif ~ischar(options)
    fprintf('ERROR dattes_structure: options must be string\n');
    result = [];
    return
end

verbose = ismember('v',options);
force = ismember('f',options);
update = ismember('u',options);

% inherit some options to some functions
inher_options = options(ismember(options,'v'));


if ~exist('destination_folder','var')
    destination_folder = '';
elseif ~ischar(destination_folder)
    fprintf('ERROR dattes_structure: destination_folder must be string\n');
    result = [];
    return
end
if ~exist('read_mode','var')
    read_mode = '';
elseif ~ischar(read_mode)
    fprintf('ERROR dattes_structure: read_mode must be string\n');
    result = [];
    return
end

%0.2. check file_in (file list in cell string)
if iscellstr(file_in)
    if length(file_in)==1
        %singular case returning errors, treat 1 element cell as char
        file_in = file_in{1};
    elseif isempty(destination_folder)
        result = cellfun(@(x) dattes_structure(x, options, '', read_mode),file_in,'uniformoutput',false);
        return
    else
        %0.2.1 guess common root folder to all files in list:
        source_folder = find_common_ancestor(file_in);
        %0.2.2 make valid regex expression:
        % escape dots (current folder, parent folder)
        source_folder = regexprep(source_folder,'\.','\\.');
        % escape fileseps
        source_folder = regexprep(source_folder,['\' filesep],['\\' filesep]);

        %0.2.3 reproduce file tree in destination_folder
        src_folders = cellfun(@fileparts,file_in,'Uniformoutput',false);
        dest_folders = regexprep(src_folders,['^' source_folder],destination_folder);
        %0.2.4 run dattes_structure for each element in file list
        result = cellfun(@(x,y) dattes_structure(x, options, y, read_mode),file_in,dest_folders,'uniformoutput',false);
        return;
    end
end

%0.3 read_mode:
[file_in_folder, file_in_name, file_in_ext] = fileparts(file_in);
switch read_mode
    case 'mat'
        file_ext = '.mat';
    case 'json'
        file_ext = '.json';
    case 'csv'
        file_ext = '.csv';
    case 'xml'
        file_ext = '.xml';
    otherwise
        if isempty(file_in_ext)
            %no extension, must be a folder, default extension: '.xml'
            file_ext = '.xml';
        else
            %try to deduct from file_in_ext
            file_ext = file_in_ext;
        end
end

if ~ismember(file_ext,{'.mat','.json','.csv','.xml'})
    fprintf('ERROR dattes_structure: not valid file extension, found "%s"\n',file_ext);
    result = [];
    return;
end

%0.4 get file list if file_in is source folder:
if isfolder(file_in)
    source_folder = file_in;
    file_list = lsFiles(source_folder,file_ext);
    result = dattes_structure(file_list, options, destination_folder, read_mode);
    return;
end

%0.5 file_out
file_out = result_filename(file_in,destination_folder);

%0.6 update option
if isfile(file_out) && update
    %check dates, if file_in newer, set force to true
    dir_in = dir(file_in);
    dir_out = dir(file_out);
    if dir_out.datenum<dir_in.datenum
        fprintf('dattes_structure: Destination file exists, but input file is more recent, updating: %s\n',file_in);
        force = true;
    end
end

%1. read file
if isfile(file_out) && ~force
    %1.0 read mat file if it exists and no force or update
    fprintf('dattes_structure: File exists: %s, loading result from mat\n',file_out);
    result = dattes_load(file_out);
else
    %1.0 mat mode (incomplete structure)
    if strcmp(file_ext,'.mat')
        result = dattes_load(file_in);
    %1.1 json mode (import_json)
    elseif strcmp(file_ext,'.json')
        [result, err] = read_json_struct(file_in);

        %TODO: error management
        if err
            result = [];
            return
        end
    else
        %1.2 csv mode (import_csv + metadata_collector)
        if strcmp(file_ext,'.csv')
            [profiles, eis, metadata, configuration, err] = extract_profiles_csv(file_in,inher_options);
            %TODO: error management
            if err
                result = [];
                return
            end
        end
        %1.3 xml mode (extract_profiles)
        if strcmp(file_ext,'.xml')

            %TODO: options 'f','u'and 's' now in dattes_structure, just inherit 'v':
            [profiles, eis, metadata, configuration, err] = extract_profiles(file_in,inher_options);
            %TODO error management
            if err
                result = [];
                return
            end
        end
        %2. compile results
        if isempty(profiles)
            % no data found in xml_file
            return
        end
        result.profiles = profiles;
        if ~isempty(eis)
            result.eis = eis;
        end
        if ~isempty(metadata)
            result.metadata = metadata;
        end
        result.configuration = configuration;

        if ~isfield(result.profiles, 'mode')
            options = [options, 'm'];
        end
    end
end
%3. which mode (if mode not in file_in or if 'm' in options)
if ismember('m',options)
    I_threshold = 5*min(diff(unique(result.profiles.I)));
    U_threshold = 5*min(diff(unique(result.profiles.U)));
    Step = result.profiles.mode;
    m = which_mode(result.profiles.t,result.profiles.I,result.profiles.U,...
                   Step,I_threshold,U_threshold,inher_options);
    result.profiles.mode = m;
end

%4. split phases (if mode not in file_in or if 'm' in options)
if ~isfield(result, 'phases') || ismember('m', options)
    result.phases = split_phases(result.profiles.datetime,result.profiles.I,...
                                 result.profiles.U,result.profiles.mode);
end

%5. calcul_soc (if soc not in file_in or if 'S' in options)
if isempty(result.profiles.soc) || ismember('S',options)
    %5.1 config_soc (detect soc100)
    result.configuration = config_soc(result.profiles.datetime,result.profiles.I,...
                                      result.profiles.U,result.profiles.mode,...
                                      result.configuration,inher_options);
    %5.2 calcul_soc
    [dod_ah, soc] = calcul_soc(result.profiles.datetime,result.profiles.I,...
        result.configuration,inher_options);
    result.profiles.dod_ah = dod_ah;
    result.profiles.soc = soc;

    % TODO: calcul_soc_patch
end

%6.- result.test
result.test.file_in = file_in;
result.test.file_out = file_out;
result.test.datetime_ini = result.profiles.datetime(1);
result.test.datetime_fin = result.profiles.datetime(end);
% update test soc_ini and soc_fin:
if isempty(result.profiles.dod_ah)
    result.test.dod_ah_ini = [];
    result.test.soc_ini = [];
    result.test.dod_ah_fin = [];
    result.test.soc_fin = [];
else
    result.test.dod_ah_ini = result.profiles.dod_ah(1);
    result.test.soc_ini = result.profiles.soc(1);
    result.test.dod_ah_fin = result.profiles.dod_ah(end);
    result.test.soc_fin = result.profiles.soc(end);
end

%7. check result structure:
[info, err] = check_result_struct(result);
if err<0
    fprintf('ERROR dattes_structure: not valid result structure error code: %d (see check_result_struct)\n',err);
    return
end

%8. save mat file (if 's' in options)
if ismember('s',options)
    dattes_save(result);
end
end
