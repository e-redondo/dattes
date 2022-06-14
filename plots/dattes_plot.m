function [result, config, phases] = dattes_plot(xml_file,options)
% dattes_plot calls plot functions
%
% [result, config, phases] = dattes_plot(xml_file,options)
% Read the *.xml file of a battery test and plot figures of
% characteristics analysed
%
% Usage:
% [result, config, phases] = dattes_plot(xml_file,options)
% Inputs:
% - xml_file:
%     -   [1xn string]: pathame to the xml file
%     -   [nx1 cell string]: xml filelist
% - options [string] containing:
%   - 'v': verbose, tell what you do
%
% Outputs : 
% - result: [1x1 struct] structure containing analysis results 
% - config:  [1x1 struct] function name used to configure the behavior (see configurator)
% - phases: [1x1 struct] structure containing information about the different phases of the test
%
%See also dattes, calcul_soc, configurator, extract_profiles
%
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

if iscell(xml_file)
    [result, config, phases] = cellfun(@(x) dattes_plot(x,options),xml_file,'UniformOutput',false);
    %mise en forme (cell 2 struct):
    [result, config, phases] = compil_result(result, config, phases);
    return;
end
%% 0.1.- check inputs:
if ~ischar(xml_file) && ~iscell(xml_file)
    error('dattes_plot: xml_file must be a string (pathname) or a cell (filelist)');
end

if ischar(xml_file)
    if ~exist(xml_file,'file')
        error('dattes_plot: file not found');
    end
end

if ~ischar(options) 
    error('dattes_plot: options must be a string (actions/options list)');
end


%1.load results
[result, config, phases] = load_result(xml_file,options);
if isempty(fieldnames(result))
    fprintf('dattes_plot: Nothing to plot in %s\n',xml_file);
    return;
end
%2.load profiles
[t,U,I,m,DoDAh,SOC,T] = extract_profiles(xml_file,options,config);

%title for figures
[~, title, ~] = fileparts(result.test.file_in);
InherOptions = options(ismember(options,'hdD'));

if ismember('x',options)
    %show result of 'x', i.e. profiles
    plot_profiles(t,U,I,m,title,InherOptions);
end
if ismember('e',options)%EIS
    if isfield(result,'eis')
        plot_eis(result.eis,title);
    end
end
if ismember('p',options)
    %show result of 'd', i.e. split_phases
    plot_phases(t,U,I,phases,title,InherOptions);
end
if ismember('c',options)
    %show result of 'c', i.e. configurator
    plot_config(t,U,config,phases,title,InherOptions);
end
if ismember('S',options)
    %show result of 'S', i.e. SOC
    plot_soc(t,I, DoDAh, SOC,config,title,InherOptions);
end
if ismember('C',options)
    %show result of 'C', i.e. Capacity
    if isfield(result,'capacity')
        plot_capacity(result.capacity.cc_capacity, result.capacity.cc_crate);
        title(xml_file,'interpreter','none')
    else
        fprintf('no capacity result found in %s\n',result.test.file_in);
    end

end
if ismember('P',options)
    %show result of 'P', i.e pseudoOCV
    if isfield(result,'pseudo_ocv')
        if ~isempty(result.pseudo_ocv)
            plot_pseudo_ocv(result.pseudo_ocv)
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
        plot_ocv_by_points(t,U, DoDAh, result.ocv_by_points)
    else
        fprintf('no ocv_by_points result found in %s\n',result.test.file_in);
    end
end
if ismember('E',options)
    %show result of 'E', i.e. Efficiency
    plot_efficiency(result.pseudo_ocv.dod,result.pseudo_ocv.efficiency);
end
if ismember('R',options)
    %show result of 'R', i.e. Resistance
    if isfield(result,'resistance')
        plot_r(result.resistance);
    else
        fprintf('no resistance result found in %s\n',result.test.file_in);
    end
    
end
if ismember('Z',options)
    %show result of 'Z', i.e. impedance
    if isfield(result,'impedance')
        plot_impedance(result.impedance,title);
    else
        fprintf('no impedance result found in %s\n',result.test.file_in);
    end
end
if ismember('I',options)
    %show result of 'I', i.e. ica
    if isfield(result,'ica')
        if ~isempty(result.ica)
            plot_ica(result.ica);
        else
            fprintf('no ica result found in %s\n',result.test.file_in);
        end
    else
        fprintf('no ica result found in %s\n',result.test.file_in);
    end
end

end
