function [result] = dattes_plot(file_in,options)
% dattes_plot calls plot functions
%
% [result] = dattes_plot(file_in,options)
% Read the *.xml file of a battery test and plot figures of
% characteristics analysed
%
% Usage:
% [result, config, phases] = dattes_plot(file_in,options)
% Inputs:
% - file_in:
%     -   [1xn string]: pathame to the mat file
%     -   [nx1 cell string]: mat file list
%     -   [1x1 struct]: DATTES result struct
%     -   [nx1 cell of struct]: DATTES result struct cell
% - options [string] containing:
%   - 'v': verbose, tell what you do
%   - 'x': plot extract_profiles result, i.e. datetime,U,I with colors depending
%   on mode (CC, CV, rest, EIS, profile)
%   - 'e': plot EIS, i.e. Nyquist plot of EIS results
%   - 'p': plot result from split_phases, i.e. cut datetime,U,I into phases
%   - 'c': plot result from dattes_configure, i.e. phase detection for
%   dattes_analyse
%   - 'S': plot result from calcul_soc
%   - 'C': plot capacity result from dattes_analyse
%   - 'O': plot ocv by points from dattes_analyse
%   - 'P': plot pseudo ocv result from dattes_analyse
%   - 'E': plot efficiency result from dattes_analyse (in pseudo_ocv tests)
%   - 'R': plot resistance result from dattes_analyse
%   - 'Z': plot impedance identification result from dattes_analyse
%   - 'I': plot ICA/DVA result from dattes_analyse
%
% Outputs : 
% - result: [1x1 struct] structure containing analysis results 
% - result: [nx1 struct] cell of structures containing analysis results 
%
% See also dattes_structure, dattes_configure, dattes_analyse
%
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

if iscell(file_in)
    [result] = cellfun(@(x) dattes_plot(x,options),file_in,'UniformOutput',false);
    return;
end
%% 0.1.- check inputs:
if ~ischar(file_in) && ~isstruct(file_in)
    error('dattes_plot: file_in must be a string (pathname) or a cell (filelist) or a struct (DATTES result)');
end

if ischar(file_in)
    if isfolder(file_in)
        if ismember('v',options)
            fprintf('dattes_plot: searching mat files in %s...\n',file_in);
        end
        %input is src_folder > get mat files in cellstr
        mat_list = lsFiles(file_in,'.mat');
        %call dattes_analyse with file_list
        result = dattes_plot(mat_list,options);
        % stop after
        return
    elseif ~exist(file_in,'file')
        error('dattes_plot: file not found');
    end
end

if ~ischar(options) 
    error('dattes_plot: options must be a string (actions/options list)');
end


%1.load results
if isstruct(file_in)
    result = file_in;
else
    [result] = dattes_load(file_in,options);
end

if isempty(fieldnames(result))
    fprintf('dattes_plot: Nothing to plot in %s\n',file_in);
    return;
end
%2.get profiles, config and phases
profiles = result.profiles;
config = result.configuration;
phases = result.phases;

%title for figures
[~, title_str, ~] = fileparts(result.test.file_in);
InherOptions = options(ismember(options,'hdD'));

%4. go for each action:
if ismember('x',options)
    %show result of 'x', i.e. profiles
    plot_profiles(profiles,title_str,InherOptions);
end
if ismember('e',options)%EIS
    if isfield(result,'eis')
        plot_eis(result.eis,title_str);
    end
end
if ismember('p',options)
    %show result of 'd', i.e. split_phases
    plot_phases(profiles,phases,title_str,InherOptions);
end
if ismember('c',options)
    %show result of 'c', i.e. configurator
    plot_config(profiles,config,phases,title_str,InherOptions);
end
if ismember('S',options)
    %show result of 'S', i.e. SOC
    plot_soc(profiles,config,title_str,InherOptions);
end
if ismember('C',options)
    %show result of 'C', i.e. Capacity
    if isfield(result,'capacity')
        plot_capacity(result.capacity,title_str);
%         title(title_str,'interpreter','none')
    else
        fprintf('no capacity result found in %s\n',result.test.file_in);
    end

end
if ismember('P',options)
    %show result of 'P', i.e pseudoOCV
    if isfield(result,'pseudo_ocv')
        if ~isempty(result.pseudo_ocv)
            plot_pseudo_ocv(result.pseudo_ocv, title_str);
        else
            fprintf('no pseudo_ocv result found in %s\n',result.test.file_in);
        end
    else
        fprintf('no pseudo_ocv result found in %s\n',result.test.file_in);
    end
end
if ismember('O',options)
    %show result of 'O', i.e. OCV by points
    if isfield(result,'ocv_by_points')
        plot_ocv_by_points(profiles, result.ocv_by_points, title_str,InherOptions);
    else
        fprintf('no ocv_by_points result found in %s\n',result.test.file_in);
    end
end
if ismember('E',options)
    %show result of 'E', i.e. Efficiency
    if isfield(result,'pseudo_ocv')
        if ~isempty(result.pseudo_ocv)
           plot_efficiency(result.pseudo_ocv,title_str);
        else
            fprintf('no efficiency (pseudo_ocv) result found in %s\n',result.test.file_in);
        end
    else
        fprintf('no efficiency (pseudo_ocv) result found in %s\n',result.test.file_in);
    end
end
if ismember('R',options)
    %show result of 'R', i.e. Resistance
    if isfield(result,'resistance')
        plot_r(result.resistance,title_str,InherOptions);
    else
        fprintf('no resistance result found in %s\n',result.test.file_in);
    end
    
end
if ismember('Z',options)
    %show result of 'Z', i.e. impedance
    if isfield(result,'impedance')
        plot_impedance(result.impedance,title_str);
    else
        fprintf('no impedance result found in %s\n',result.test.file_in);
    end
end
if ismember('I',options)
    %show result of 'I', i.e. ica
    if isfield(result,'ica')
        if ~isempty(result.ica)
            plot_ica(result.ica,title_str);
        else
            fprintf('no ica result found in %s\n',result.test.file_in);
        end
    else
        fprintf('no ica result found in %s\n',result.test.file_in);
    end
end

end
