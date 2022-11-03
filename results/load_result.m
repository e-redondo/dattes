function [result] = load_result(file_in,options)
% load_result load the results of DATTES
%
% This function loads a mat file and make some checks for validation.
% If input file is not a mat file, the function uses result_filename to
% guess the corresponding mat file:
% e.g. file_in.xml >>> file_in_dattes.mat
%
% Usage:
% [result] = load_result(file_in,options)
% Inputs : 
% - file_in:
%     -   [1xn string]: input file
%     -   [nx1 cell string]: filelist
% - options  [string, optional]:
%    - 'v': verbose
%
% Outputs : 
% - result: [1x1 struct] structure containing analysis results 
%
% See also dattes, save_result, edit_result
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

if ~exist('options','var')
    options = '';
end
if iscell(file_in)
    [result] = cellfun(@load_result,file_in,'UniformOutput',false);
%     %mise en forme (cell 2 struct):
%     [result] = compil_result(result, config, phases);
    return;
end

%get mat file name
[D,F,E] = fileparts(file_in);
if strcmp(E,'.mat')
    %if input file is mat, keep it
    file_mat = file_in;
else
    %if input file is not mat, try to find a logical name for it
    file_mat = result_filename(file_in);
end
%check if file exists
if exist(file_mat,'file')
    if ismember('v',options)
        fprintf('load_result:load results %s...',file_in);
    end
    %list variables in MAT file
    S = who('-file',file_mat);
%     if ismember('config',S)
%         %load config if it is in the MAT file
%         load(fileOut,'config');
%         %convert strings back to function handlers (see save1result in save_result):
%         config.impedance.ident_fcn = str2func(config.impedance.ident_fcn);
%     end
    if ismember('result',S)
        %load resultat if it is in the MAT file
        load(file_mat,'result');
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
        fprintf('load_result: the file %s did not exist yet, variables initialized\n',file_mat);
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
result = str2func_struct(result);

% if ~exist('phases','var')
%     %if resultat was not in the file (or the file was not found)
%     %create this variable
%     phases = struct;
% end

end
