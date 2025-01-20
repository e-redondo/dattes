function result = dattes_configure(result,options,custom_cfg_script)
% dattes_configure - DATTES Configuration function
%
% 
% Usage:
% (1) result = dattes_configure(result,options,custom_cfg_script)
% (2) result = dattes_configure(file_in,options,custom_cfg_script)
% (3) result = dattes_configure(file_list,options,custom_cfg_script)
% (4) result = dattes_configure(src_folder,options,custom_cfg_script)
%
% Input:
% - file_in [1xp string] DATTES mat file pathname
% - result [1x1 struct] DATTES result structure
% - file_list [nx1 cellstr] DATTES mat file list of pathnames
% - src_folder [1xp string] folder to search DATTES mat files in
% - options [1xn string]:
%    - 's': save result
%    - 'v': verbose
% - custom_cfg_script [1xp string]: (optional) 
%
%
% See also dattes_structure, dattes_analyse
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

%% 0 check inputs:

%0.1 1st paramater is mandatory
if ~exist('result','var')
    fprintf('ERROR dattes_configure: result input struct is mandatory\n');
    result = [];
    return
end
%0.2 if 2nd not given, set defaults:
if ~exist('options','var')
    options = '';
elseif ~ischar(options)
    fprintf('ERROR dattes_configure: options must be string\n');
%     result = [];
    return
end
%0.3 if 3rd not given, set defaults:
if ~exist('custom_cfg_script','var')
    custom_cfg_script = '';
end

%0.4 1st paramater may be result/file_in/file_list/src_folder
if ischar(result)
    if isfolder(result)
        %input is src_folder > get mat files in cellstr
        mat_list = lsFiles(result,'.mat');
        %call dattes_configure with file_list
        result = dattes_configure(mat_list,options,custom_cfg_script);
        % stop after
        return
    elseif exist(result,'file')
        %file_in mode
        result = dattes_load(result);
    end
end

if iscell(result)
    %file_list mode
    result = cellfun(@(x) dattes_configure(x,options,custom_cfg_script),result,'Uniformoutput',false);
    % stop after
    return
end

%0.5 check result struct
[info,err] = check_result_struct(result);
if err<0
    fprintf('ERROR dattes_configure: input result is not a valid DATTES struct\n');
%     result = [];
    return
end

%% 1 load cfg_script
%1.1 load config0
if isempty(custom_cfg_script)
    config0 = cfg_default;
elseif ischar(custom_cfg_script)
    if  ~isempty(which(custom_cfg_script))
        config0 = eval(custom_cfg_script);
        config0.test.cfg_file = custom_cfg_script;
    else
        error('dattes_configure: custom_cfg_script not a valid script name');
    end
elseif isstruct(custom_cfg_script)
    config0 = custom_cfg_script;
    config0.test.cfg_file = 'custom configuration in dattes_configure';
else
    error('dattes_configure: custom_cfg_script must be a string (pathname to custom_cfg_script) or a struct (configuration struct)');
end
%1.2 check config0
%TODO: check structure in two levels (sections / fields)
%TODO: check every section/fields is allowed
%TODO: check every fields is of correct type (numeric, char, etc.)

%1.3 merge config0 with result.configuration
% configs must be two level structs (config/sections/fields)
config = result.configuration;

%field in config0 will overwrite those in config
config = merge_struct(config,config0);


%1.4 check config struct
%TODO: check_configuration_struct: mandatory/allowed/types
[info,err] = check_configuration_struct(config);
if err<0
    fprintf('ERROR dattes_configure: configuration struct is not valid (before configurator)\n');
    result = [];
    return
end


%% 2 configurator
%2.1 run configurator
datetime = result.profiles.datetime;
t = result.profiles.t;
I = result.profiles.I;
U = result.profiles.U;
m = result.profiles.mode;
phases = result.phases;
[config] = configurator(datetime,I,U,m,config,phases,options);
%2.2 check config struct
[info,err] = check_configuration_struct(config);
if err<0
    fprintf('ERROR dattes_configure: configuration struct is not valid (after configurator)\n');
    result = [];
    return
end

%% 3 put config back into result.configuration
result.configuration = config;

%% 4 save option
if ismember('s',options)
    if ismember('v',options)
        fprintf('dattes_configure: save result...');
    end
    dattes_save(result);
    if ismember('v',options)
        fprintf('OK\n');
    end
end
end