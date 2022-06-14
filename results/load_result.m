function [result, config, phases] = load_result(XMLfile,options)
% load_result load the results of DATTES
%
%[result, config, phases] = load_result(XMLfile,options)
% load the results of DATTES
%
% Usage:
% [result, config, phases] = dattes(xml_file,options,cfg_file)
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
    [result, config, phases] = cellfun(@load_result,XMLfile,'UniformOutput',false);
    %mise en forme (cell 2 struct):
    [result, config, phases] = compil_result(result, config, phases);
    return;
end
%get file name
fileOut = result_filename(XMLfile);
%check if file exists
if exist(fileOut,'file')
    if ismember('v',options)
        fprintf('load_result:load results and config %s...',XMLfile);
    end
    %list variables in MAT file
    S = who('-file',fileOut);
    if ismember('config',S)
        %load config if it is in the MAT file
        load(fileOut,'config');
    end
    if ismember('result',S)
        %load resultat if it is in the MAT file
        load(fileOut,'result');
    end
    if ismember('phases',S)
        %load resultat if it is in the MAT file
        load(fileOut,'phases');
    end
    if ismember('v',options)
        fprintf('OK\n');
    end
else
    if ismember('v',options)
        fprintf('load_result: the file %s did not exist yet, variables initialized\n',fileOut);
    end
end
if ~exist('config','var')
    %if config was not in the file (or the file was not found)
    %create this variable
    config = struct;
end
if ~exist('result','var')
    %if resultat was not in the file (or the file was not found)
    %create this variable
    result = struct;
end
if ~exist('phases','var')
    %if resultat was not in the file (or the file was not found)
    %create this variable
    phases = struct;
end

end