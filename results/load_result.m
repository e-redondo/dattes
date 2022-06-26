function [result] = load_result(XMLfile,options)
% load_result load the results of DATTES
%
%[result] = load_result(XMLfile,options)
% load the results of DATTES
%
% Usage:
% [result] = load_result(XMLfile,options)
% Inputs : 
% - xml_file:
%     -   [1xn string]: pathame to the xml file
%     -   [nx1 cell string]: xml filelist
% - options  [string, optional]:
%    - 'v': verbose
%
% Outputs : 
% - result: [1x1 struct] structure containing analysis results 
% - config:  [1x1 struct] function name used to configure the behavior (see configurator)
% - phases: [1x1 struct] structure containing information about the different phases of the test
%
% See also dattes, save_result, edit_result
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

if ~exist('options','var')
    options = '';
end
if iscell(XMLfile)
    [result] = cellfun(@load_result,XMLfile,'UniformOutput',false);
%     %mise en forme (cell 2 struct):
%     [result] = compil_result(result, config, phases);
    return;
end
%get file name
fileOut = result_filename(XMLfile);
%check if file exists
if exist(fileOut,'file')
    if ismember('v',options)
        fprintf('load_result:load results %s...',XMLfile);
    end
    %list variables in MAT file
    S = who('-file',fileOut);
%     if ismember('config',S)
%         %load config if it is in the MAT file
%         load(fileOut,'config');
%         %convert strings back to function handlers (see save1result in save_result):
%         config.impedance.ident_fcn = str2func(config.impedance.ident_fcn);
%     end
    if ismember('result',S)
        %load resultat if it is in the MAT file
        load(fileOut,'result');
    end
%     if ismember('phases',S)
%         %load resultat if it is in the MAT file
%         load(fileOut,'phases');
%     end
    if ismember('v',options)
        fprintf('OK\n');
    end
else
    if ismember('v',options)
        fprintf('load_result: the file %s did not exist yet, variables initialized\n',fileOut);
    end
end
% if ~exist('config','var')
%     %if config was not in the file (or the file was not found)
%     %create this variable
%     config = struct;
% end
if ~exist('result','var')
    %if resultat was not in the file (or the file was not found)
    %create this variable
    result = struct;
end

%convert strings back to function handlers (see save1result in save_result):
if isfield(result,'configuration')
    if isfield(result.configuration,'impedance')
        if isfield(result.configuration.impedance,'ident_fcn')
            if ischar(result.configuration.impedance.ident_fcn)
                result.configuration.impedance.ident_fcn = str2func(result.configuration.impedance.ident_fcn);
            end
        end
    end
end

% if ~exist('phases','var')
%     %if resultat was not in the file (or the file was not found)
%     %create this variable
%     phases = struct;
% end

end
