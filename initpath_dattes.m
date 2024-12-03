function initpath_dattes(options)
%initpath_dattes Add dattes folder and subfolders to MATLAB path.
%
% function initpath_dattes(options)
%
% Example:
% 
% initpath_dattes e     % add folders to path (default)
% initpath_dattes         % the same as above
% initpath_dattes d     % remove folders from path
%
% See also DATTES
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab:
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

srcdir = fileparts(which('initpath_dattes'));

if ~exist('options','var')
    options = 'e';% default if no input parameter is given
end

if ismember('e',options)%enable = addpath
    addpath(srcdir);
    %subfolders
    addpath(fullfile(srcdir,'configs'));
    addpath(fullfile(srcdir,'data_tools'));
    addpath(fullfile(srcdir,'data_tools','check_struct'));
    addpath(fullfile(srcdir,'data_tools','io'));
    addpath(fullfile(srcdir,'data_tools','import'));
    addpath(fullfile(srcdir,'data_tools','import','arbin'));
    addpath(fullfile(srcdir,'data_tools','import','bitrode'));
    addpath(fullfile(srcdir,'data_tools','import','biologic'));
    addpath(fullfile(srcdir,'data_tools','import','btsuite'));
    addpath(fullfile(srcdir,'data_tools','import','neware'));
    addpath(fullfile(srcdir,'data_tools','import','digatron'));
    addpath(fullfile(srcdir,'data_tools','export'));
    addpath(fullfile(srcdir,'data_tools','metadata'));
    addpath(fullfile(srcdir,'external_tools'));
    addpath(fullfile(srcdir,'ident'));
    addpath(fullfile(srcdir,'math_tools'));
    addpath(fullfile(srcdir,'models/ecm_freq'));
    addpath(fullfile(srcdir,'models/ecm_time'));
    if isempty(which('butter'))
        fprintf('DATTES (initpath_dattes): Adding butter function from Octave signal package.\n')
        addpath(fullfile(srcdir,'external_tools','octave','signal'));
    end
    if isempty(which('x2mdate'))
        fprintf('DATTES (initpath_dattes): Adding x2mdate / m2xdate functions from Octave financial package.\n')
        addpath(fullfile(srcdir,'external_tools','octave','financial'));
    end
    addpath(fullfile(srcdir,'plots'));
    
    %if no VEHLIB is found in this computer add minimal dependencies
    if isempty(which('initpath'))
        fprintf('DATTES (initpath_dattes): No VEHLIB found in this computer. ');
        fprintf('Adding vehlib_minimal dependencies...\n');
        
        fprintf('If you are interested in energy management for electrified vehicles,\n')
        fprintf('please consider getting VEHLIB at https://gitlab.univ-eiffel.fr/eco7/vehlib\n')
        addpath(fullfile(srcdir,'external_tools','vehlib_minimal'));
    end
end
if ismember('d',options)%disable = rmpath
    rmpath(srcdir);
    rmpath(fullfile(srcdir,'configs'));
    rmpath(fullfile(srcdir,'data_tools'));
    rmpath(fullfile(srcdir,'data_tools','check_struct'));
    rmpath(fullfile(srcdir,'data_tools','io'));
    rmpath(fullfile(srcdir,'data_tools','import'));
    rmpath(fullfile(srcdir,'data_tools','import','arbin'));
    rmpath(fullfile(srcdir,'data_tools','import','bitrode'));
    rmpath(fullfile(srcdir,'data_tools','import','biologic'));
    rmpath(fullfile(srcdir,'data_tools','import','btsuite'));
    rmpath(fullfile(srcdir,'data_tools','import','neware'));
    rmpath(fullfile(srcdir,'data_tools','import','digatron'));
    rmpath(fullfile(srcdir,'data_tools','export'));
    rmpath(fullfile(srcdir,'data_tools','metadata'));
    rmpath(fullfile(srcdir,'external_tools'));
    rmpath(fullfile(srcdir,'ident'));
    rmpath(fullfile(srcdir,'math_tools'));
    rmpath(fullfile(srcdir,'plots'));
    rmpath(fullfile(srcdir,'models/ecm_freq'));
    rmpath(fullfile(srcdir,'models/ecm_time'));
    
    %remove octave only if it was added before:
    P = path;
    if ~isempty(strfind(P,fullfile(srcdir,'external_tools','octave','signal')))
        rmpath(fullfile(srcdir,'external_tools','octave','signal'));
    end
    if ~isempty(strfind(P,fullfile(srcdir,'external_tools','octave','financial')))
        rmpath(fullfile(srcdir,'external_tools','octave','financial'));
    end
    %remove vehlib_minimal only if it was added before:
    if ~isempty(strfind(P,fullfile(srcdir,'external_tools','vehlib_minimal')))
        rmpath(fullfile(srcdir,'external_tools','vehlib_minimal'));
    end
    
end

end
