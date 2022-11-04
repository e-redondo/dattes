function dattes_export(dattes_struct,options,dst_folder,file_out)
% dattes_export - DATTES Export function
%
% 
% Usage:
% (1) dattes_export(dattes_struct,options,dst_folder,file_out)
% (2) dattes_export(file_in,options,dst_folder,file_out)
% (3) dattes_export(file_list,options,dst_folder,file_out)
% (4) dattes_export(src_folder,options,dst_folder,file_out)
%
% Input:
% - dattes_struct [1x1 struct] DATTES result structure
% - options [1xn string]:
%    - 'A': export all the result (profiles, eis, phases, metadata, config)
%    - 'P': profiles
%    - 'E': eis
%    - 'p': phases
%    - 'M': metadata
%    - 'C': configuration
%    - 'j': json
%    - 'c': csv
%    - 's': M-File script (for configuration or metadata)
%    - 'm': include metadata in csv files
% - dst_folder [1xp string]: (optional) 
% - file_out [1xp string]: (optional) 
%
%
% See also dattes_import, export_result_csv, export_result_json
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

if ~exist('options','var')
    options = 'Aj';%default: export all in json format
end
%Valid options:
%1. with 'A':
%1.1. 'Aj': export all to a json file
%1.2. 'Ac': export all to csv files, create a folder containing them
%2. with 'P':
%2.1. 'Pj(m)': export profiles to a json file, optionnaly include metadata as substructure
%2.2. 'Pc(m)': export profiles to a csv file, optionnaly include metadata
% as commented json code in csv header lines
%3. with 'E':
%3.1. 'Ej(m)':export EIS to a json file, optionnaly include metadata as substructure
%3.2. 'Ec(m)': export EIS to a csv file, optionnaly include metadata
% as commented json code in csv header lines
%4. with 'p':
%4.1. 'pj(m)':export phases to a json file, optionnaly include metadata as substructure
%4.2. 'pc(m)': export phases to a csv file, optionnaly include metadata
% as commented json code in csv header lines
%5. with 'M':
%5.1. 'Mj':export metadata to a json file
%5.2. 'Ms':export metadata to a M-file script
%6. with 'C':
%6.1. 'Cj':export configuration to a json file
%6.2. 'Cs':export configuration to a M-file script

if ~exist('file_out','var')
    file_out = '';%empty string = default = generate file_out
end
if ~exist('dst_folder','var')
    dst_folder = '';%empty string = default = keep src_folder
end

[export_mode, export_format, include_metadata] = check_options_string(options);
if isempty(export_mode)
    %not valid options
    return;
end

if include_metadata
    inher_options = 'm';
else
    inher_options = '';
end

if iscellstr(dattes_struct)
    %filelist
    filelist = dattes_struct;
    %TODO find_common_ancestor
    cellfun(@(x) dattes_export(x,options,dst_folder,file_out),filelist,'UniformOutput',false);
    return;
elseif ischar(dattes_struct)
    %file_in or src_folder
    if isfolder(dattes_struct)
        mat_list = lsFiles(dattes_struct,'.mat');
        dattes_export(mat_list,options,dst_folder,file_out);
        return;
    end
    if exist(dattes_struct,'file')
        file_in = dattes_struct;
        dattes_struct = load_result(file_in);
    end
end


%'all'
if strcmp(export_mode,'all')
    fprintf('DATTES export all to %s\n',export_format)
    if strcmp(export_format,'csv')
        export_result_csv(dattes_struct, inher_options, dst_folder, file_out)
    elseif strcmp(export_format,'json')
        export_result_json(dattes_struct, inher_options,dst_folder,file_out);
    end
end
%'profiles'
if strcmp(export_mode,'profiles')
    fprintf('DATTES export profiles to %s\n',export_format)
    if strcmp(export_format,'csv')
        export_profiles_csv(dattes_struct, inher_options,dst_folder,file_out);
    elseif strcmp(export_format,'json')
        export_profiles_json(dattes_struct, inher_options,dst_folder,file_out);
    end
        
end
%'eis'
if strcmp(export_mode,'eis')
    fprintf('DATTES export eis to %s\n',export_format)
    if strcmp(export_format,'csv')
        export_eis_csv(dattes_struct, inher_options,dst_folder,file_out);
    elseif strcmp(export_format,'json')
        export_eis_json(dattes_struct, inher_options,dst_folder,file_out);
    end
end
%'phases'
if strcmp(export_mode,'phases')
    fprintf('DATTES export phases to %s\n',export_format)
    if strcmp(export_format,'csv')
        export_phases_csv(dattes_struct, inher_options,dst_folder,file_out);
    elseif strcmp(export_format,'json')
        export_phases_json(dattes_struct, inher_options,dst_folder,file_out);
    end
end
%'metadata'
if strcmp(export_mode,'metadata')
    fprintf('DATTES export metadata to %s\n',export_format)
    if strcmp(export_format,'script')
        export_metadata_script(dattes_struct, inher_options,dst_folder,file_out);
    elseif strcmp(export_format,'json')
        export_metadata_json(dattes_struct, inher_options,dst_folder,file_out);
    end
end
%'configuration'
if strcmp(export_mode,'configuration')
    fprintf('DATTES export configuration to %s\n',export_format)
    if strcmp(export_format,'script')
        export_configuration_script(dattes_struct, inher_options,dst_folder,file_out);
    elseif strcmp(export_format,'json')
        export_configuration_json(dattes_struct, inher_options,dst_folder,file_out);
    end
end

end

function [export_mode, export_format, include_metadata] = check_options_string(options)

% 0.1 input format 
if ~ischar(options) || length(options)<2 || length(options)>3
    export_mode = '';
    export_format = '';
    include_metadata = false;
    return
end
% 0.2 invalid first letters:
if ~ismember('APEpMC',options(1))
    %error
    fprintf('ERROR dattes_export:Invalid options string, first letter must be one of these "APEpMC", found "%s"\n',options(1));
    export_mode = '';
    export_format = '';
    include_metadata = false;
    return
end
% 0.3 invalid second letters:
if ~ismember('jcs',options(2))
    fprintf('ERROR dattes_export:Invalid options string, second letter must be one of these "jcs", found "%s"\n',options(2));
    export_mode = '';
    export_format = '';
    include_metadata = false;
    return
end
% 0.4 invalid third letter:
if length(options)==3
    if options(end)~='m'
        fprintf('ERROR dattes_export:Invalid options string, (optional) third letter must be "m", found "%s"\n',options(3));
        export_mode = '';
        export_format = '';
        include_metadata = false;
        return
    end
end

% 1. get export mode
switch options(1)
    case 'A'
        export_mode = 'all';
    case 'P'
        export_mode = 'profiles';
    case 'E'
        export_mode = 'eis';
    case 'p'
        export_mode = 'phases';
    case 'M'
        export_mode = 'metadata';
    case 'C'
        export_mode = 'configuration';
    otherwise
        export_mode = '';
end

% 2. get export format
switch options(2)
    case 'j'
        export_format = 'json';
    case 'c'
        export_format = 'csv';
    case 's'
        export_format = 'script';
    otherwise
        export_format = '';
end
% 3. get metada include
include_metadata =  length(options)==3 && options(end)=='m';

% 4. check invalid options:
%4.1 one option not recognised
if isempty(export_mode) || isempty(export_format)
    export_mode = '';
    export_format = '';
    include_metadata =  false;
    return
end
%4.2 all/profiles/eis/phases to script not possible
if ismember(options(1),'APEp') && strcmp(export_format,'script')
    export_mode = '';
    export_format = '';
    include_metadata = false;
    return
end
%4.3 metadata or configuration to csv not possible
if ismember(options(1),'MC') && strcmp(export_format,'csv')
    export_mode = '';
    export_format = '';
    include_metadata = false;
    return
end
%4.3 include metadata in metadata or configuration not possible
if ismember(options(1),'MC') && include_metadata
    export_mode = '';
    export_format = '';
    include_metadata = false;
    return
end
end