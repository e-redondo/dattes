function [result, config, phases] = dattes_plot(XMLfile,options)

if iscell(XMLfile)
    [result, config, phases] = cellfun(@(x) dattes_plot(x,options),XMLfile,'UniformOutput',false);
    %mise en forme (cell 2 struct):
    [result, config, phases] = compil_result(result, config, phases);
    return;
end
%1.load results
[result, config, phases] = load_result(XMLfile,options);
if isempty(fieldnames(result))
    fprintf('dattes_plot: Nothing to plot in %s\n',XMLfile);
    return;
end
%2.load profiles
[t,U,I,m,DoDAh,SOC,T] = extract_profiles(XMLfile,options,config);

%title for figures
[~, titre, ~] = fileparts(result.test.file_in);
InherOptions = options(ismember(options,'hdD'));

if ismember('x',options)
    %show result of 'x', i.e. profiles
    plot_profiles(t,U,I,m,titre,InherOptions);
end
if ismember('e',options)%EIS
    if isfield(result,'eis')
        plot_eis(result.eis,titre);
    end
end
if ismember('p',options)
    %show result of 'd', i.e. split_phases
    plot_phases(t,U,I,phases,titre,InherOptions);
end
if ismember('c',options)
    %show result of 'c', i.e. configurator
    plot_config(t,U,config,phases,titre,InherOptions);
end
if ismember('S',options)
    %show result of 'S', i.e. SOC
    plot_soc(t,I, DoDAh, SOC,config,titre,InherOptions);
end
if ismember('C',options)
    %show result of 'C', i.e. Capacity
    if isfield(result,'capacity')
        plot_capacity(result.capacity.cc_capacity, result.capacity.cc_crate);
        title(XMLfile,'interpreter','none')
    else
        fprintf('no capacity result found in %s\n',result.test.file_in);
    end

end
if ismember('P',options)
    %show result of 'P', i.e pseudoOCV
    plot_pseudo_ocv(result.pDoD, result.pOCV, result.pUCi, result.pUDi)
end
if ismember('O',options)
    %show result of 'O', i.e. OCV by points
    plot_ocv_by_points(t,U, DoDAh, result.tOCVp, result.OCVp, result.DoDp, result.Ipsign)
end
if ismember('E',options)
    %show result of 'E', i.e. Efficiency
    plot_efficiency(result.pDoD,result.pEff);
end
if ismember('R',options)
    %show result of 'R', i.e. Resistance
    %TODO: InherOptions
    plot_r(result.R, result.RDoD,result.RRegime);
end
if ismember('Z',options)
    %show result of 'Z', i.e. impedance
    if isfield(result,'impedance')
        plot_impedance(result.impedance,titre);
    else
        fprintf('no impedance result found in %s\n',result.test.file_in);
    end
end
if ismember('I',options)
    %show result of 'I', i.e. ica
    plot_ica(result.ica);
end

end