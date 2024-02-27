function ha = plot_bode_z(Z,f,h)

if ~exist('h','var')
    h = figure;
end
if strcmp(h(1).Type,'figure')
    ha = [subplot(211), subplot(212)];
elseif strcmp(h(1).Type,'axes')
    ha = h;
    h = ha(1).Parent;
else
    fprintf('plot_nyquist_z:h must be a figure or axis handle\n')
    return
end

semilogx(ha(1),f,abs(Z),'.-'); hold on;
semilogx(ha(2),f,angle(Z),'.-'); hold on;


%force log scale in X
%with multiple plots matlab deactivates semilogx becoming natural plot
set(ha(1),'XScale','log');
set(ha(2),'XScale','log');

end