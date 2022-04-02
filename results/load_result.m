function [result, config, phases] = load_result(XMLfile,options)
%load_result load the results of DATTES
%[resultat, config, phases] = load_result(XMLfile [,options])
%
% INPUTS:
% - XMLfile [string or cell string]: pathname or filelist
% - options  [string, optional]:
%    - 'v': verbose
%
%See also dattes, save_result, edit_result
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
        fprintf('load_result:charger resultats et config %s...',XMLfile);
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
        fprintf('load_result:le fichier %s n''existe pas, variables initialisées\n',fileOut);
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