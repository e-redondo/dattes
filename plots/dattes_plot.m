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
[t,U,I,m,DoDAh,SOC,T] = extract_bench(XMLfile,options,config);

%title for figures
[~, titre, ~] = fileparts(result.fileIn);
InherOptions = options(ismember(options,'hdD'));

if ismember('x',options)
    %show result of 'x', i.e. profiles
    plot_bench(t,U,I,m,titre,InherOptions);
end
if ismember('e',options)%EIS
    if isfield(result,'eis')
        plot_eis(result.eis,titre);
    end
end
if ismember('p',options)
    %show result of 'd', i.e. decompose_bench
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
    plot_capacity(result.Capa, result.CapaRegime);
    title(XMLfile,'interpreter','none')
end
if ismember('P',options)
    %show result of 'P', i.e pseudoOCV
    plot_pocv(result.pDoD, result.pOCV, result.pUCi, result.pUDi)
end
if ismember('O',options)
    %show result of 'O', i.e. OCV by points
    plot_ocvp(t,U, DoDAh, result.tOCVp, result.OCVp, result.DoDp, result.Ipsign)
end
if ismember('E',options)
    %show result of 'E', i.e. Efficiency
    plot_eff(result.pDoD,result.pEff);
end
if ismember('R',options)
    %show result of 'R', i.e. Resistance
    %TODO: InherOptions
    plot_r(result.R, result.RDoD,result.RRegime);
end
if ismember('Z',options)
    %show result of 'Z', i.e. impedance
    plot_cpe(result.CPEQ, result.CPEalpha,result.CPEDoD, result.CPERegime);
end
if ismember('I',options)
    %show result of 'I', i.e. ica
    plot_ica(result.ica);
end

end