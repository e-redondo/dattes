function ha = plot_nyquist_z(Z,f,h)

if ~exist('h','var')
    h = figure;
end
if strcmp(h.Type,'figure')
    ha = get(h,'children');
    if isempty(ha)
    ha = axes;
    else
        ha = ha(1);
    end
elseif strcmp(h.Type,'axes')
    ha = h;
    h = ha.Parent;
else
    fprintf('plot_nyquist_z:h must be a figure or axis handle\n')
    return
end

plot(ha,conj(Z),'.-'), hold on
ha.DataAspectRatio = [1 1 1];
ha.PlotBoxAspectRatio = [1 1 1];
end