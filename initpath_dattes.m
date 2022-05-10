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
    addpath(fullfile(srcdir,'ident'));
    addpath(fullfile(srcdir,'math_tools'));
    addpath(fullfile(srcdir,'plots'));
    addpath(fullfile(srcdir,'results'));
    
    %if no VEHLIB is found in this computer add minimal dependencies
    if isempty(which('initpath'))
        msg = ['No VEHLIB found in this computer. '...
              'Adding vehlib_minimal dependencies'];
        
        warning(msg)
        
        fprintf('Please consider getting VEHLIB at https:/framagit.org/vehlib\n')
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
    
    %remove vehlib_minimal only if it was added before:
    P = path;
    if ~isempty(strfind(P,fullfile(srcdir,'vehlib_minimal')))
        rmpath(fullfile(srcdir,'vehlib_minimal'));
    end
end

end
