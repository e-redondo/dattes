function result = config_impedance_ocv(result,options,result2)
% config_impedance_ocv - Fill config.impedance.ocv for impedance from
% results.
%
% Usage (1): result = config_impedance_ocv(result,options)
% Take dod/ocv table in result.pseudo_ocv (or ocv_points) and put it in
% configuration.impedance
%
% Inputs:
% - result [1x1 struct]: DATTES structure
% - options [char]
%   - 'v': verbose
%   - 'g': graphics
%   - 's': save
%   - 'P': take dod/ocv table from pseudo_ocv result
%   - 'O': take dod/ocv table from ocv_points result
%   - 'F': take dod/ocv table from csv file (file_in2, in csv format)
% Ouputs:
% - result [1x1 struct]: DATTES structure updated with
% configuration.impedance.ocv
%
% Usage (2): result = config_impedance_ocv(result,options, result2)
% Take dod/ocv table in result2.pseudo_ocv (or ocv_points) instead result.
% - result [1x1 struct]: DATTES structure
% - options [char]
% - result2 [1x1 struct]: DATTES structure
%
% Usage (3): result = config_impedance_ocv(file_in,options)
% Load result from file_in.
% - file_in [char]: pathname to file
% - options [char]
%
% Usage (4): result = config_impedance_ocv(file_in,options,file_in2)
% Load result from file_in, result2 from file_in2.
% - file_in [char]: pathname to file containing result
% - options [char]
% - file_in2 [char]: pathname to file containing result2
%
% Usage (5): result = config_impedance_ocv(file_list,options,file_in2)
% Load result from file_in, result2 from file_in2.
% - file_list [nx1 cell]: file list of files containing results
% - options [char]
% - file_in2 [char]: pathname to file containing result2
%
% Usage (6): results = config_impedance_ocv(results,options,result2)
% Load result from file_in, result2 from file_in2.
% - results [nx1 cell]: cell containin DATTES structures
% - options [char]
% - result2 [1x1 struct]: DATTES structure
%
%
% See also iden_cpe, iden_rrc
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.


%0. manage inputs
if ~exist('result','var')
    error('config_impedance_ocv: not enough inputs')
end

if ~exist('options','var')
    options = 'P';%defaults: take ocv from result if result2 do not exist
end

if iscell(result)
    if ~exist('result2','var')
        result2 = result{1};%default: if no result2, take first result as result2
    end
    result = cellfun(@(x) config_impedance_ocv(x,options,result2),result,'UniformOutput',false);
    return
end

if ischar(result)
    result = dattes_load(result);
end

if ~exist('result2','var')
        result2 = result;%default: if no result2, take result as result2
end

if ischar(result2)
    %TODO manage 'F' option: file_in2 as csv file
    result2 = dattes_load(result2);
end

graphics = ismember('g',options);

% from now, result and result 2 are DATTES structures
dod = [];
ocv = [];
if ismember('P',options)
    %TODO: verbose
    if isfield(result2,'pseudo_ocv')
        dod = result2.pseudo_ocv.dod;
        ocv = result2.pseudo_ocv.ocv;
    end
elseif ismember('O',options)
    %TODO: verbose
    if isfield(result2,'pseudo_ocv')
        dod = result2.ocv_points.dod;
        ocv = result2.ocv_points.ocv;
    end
elseif ismember('F',options)
    %TODO MANAGE 'F' OPTION
    %TODO: verbose
end

if isempty(dod)
    fprintf('config_impedance_ocv: no ocv source found (P,O,F)? \n');
    return
end
result.configuration.impedance.dod = dod;
result.configuration.impedance.ocv = ocv;

%TODO: verbose
if ismember('s',options)
    dattes_save(result)
end

if graphics
    figure;
    plot(result.configuration.impedance.dod,result.configuration.impedance.ocv)
end
end