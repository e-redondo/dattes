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

srcdir = fileparts(which('initpath_dattes'));

if ~exist('options','var')
    options = 'e';% default if no input parameter is given
end

if ismember('e',options)%enable = addpath
    addpath(srcdir);
    %subfolders
    addpath(fullfile(srcdir,'configs'));
    addpath(fullfile(srcdir,'data_tools'));
    addpath(fullfile(srcdir,'data_tools','arbin'));
    addpath(fullfile(srcdir,'data_tools','bitrode'));
    addpath(fullfile(srcdir,'data_tools','biologic'));
    addpath(fullfile(srcdir,'data_tools','metadata'));
    addpath(fullfile(srcdir,'ident'));
    addpath(fullfile(srcdir,'math_tools'));
    if isempty(which('butter'))
        fprintf('DATTES (initpath_dattes): Adding butter function from Octave signal package.\n')
        addpath(fullfile(srcdir,'math_tools','octave','signal'));
    end
    if isempty(which('x2mdate'))
        fprintf('DATTES (initpath_dattes): Adding x2mdate / m2xdate functions from Octave financial package.\n')
        addpath(fullfile(srcdir,'math_tools','octave','financial'));
    end
    addpath(fullfile(srcdir,'plots'));
    addpath(fullfile(srcdir,'results'));
    
    %if no VEHLIB is found in this computer add minimal dependencies
    if isempty(which('initpath'))
        fprintf('DATTES (initpath_dattes): No VEHLIB found in this computer. ');
        fprintf('Adding vehlib_minimal dependencies...\n');
        
        fprintf('If you are interested in energy management for electrified vehicles,\n')
        fprintf('please consider getting VEHLIB at https:/framagit.org/eco7/vehlib\n')
        addpath(fullfile(srcdir,'vehlib_minimal'));
    end
end
if ismember('d',options)%disable = rmpath
    rmpath(srcdir);
    rmpath(fullfile(srcdir,'configs'));
    rmpath(fullfile(srcdir,'data_tools'));
    rmpath(fullfile(srcdir,'data_tools','arbin'));
    rmpath(fullfile(srcdir,'data_tools','bitrode'));
    rmpath(fullfile(srcdir,'data_tools','biologic'));
    rmpath(fullfile(srcdir,'ident'));
    rmpath(fullfile(srcdir,'math_tools'));
    rmpath(fullfile(srcdir,'plots'));
    rmpath(fullfile(srcdir,'results'));
    
    %remove octave only if it was added before:
    P = path;
    if ~isempty(strfind(P,fullfile(srcdir,'math_tools','octave','signal')))
        rmpath(fullfile(srcdir,'math_tools','octave','signal'));
    end
    if ~isempty(strfind(P,fullfile(srcdir,'math_tools','octave','financial')))
        rmpath(fullfile(srcdir,'math_tools','octave','financial'));
    end
    %remove vehlib_minimal only if it was added before:
    if ~isempty(strfind(P,fullfile(srcdir,'vehlib_minimal')))
        rmpath(fullfile(srcdir,'vehlib_minimal'));
    end
    
end

end
