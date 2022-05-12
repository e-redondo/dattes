function [dqdu,dudq,qf,uf] = calcul_ica(t,q,u,N,wn,options)
%funcion calcul_ica2 - recoupe, filtre et derive
% -N: no filter
% -G: gaussian filter
% -M: mean filter
% -B: butter filter
% -b: balanced, i.e. filter à l'endroit et à l'envers, puis moyenner

if ~exist('options','var')
    options = '';%no filter
end
%0. constant sampling:
Ts = min(unique(diff(t)));

ti = (t(1):Ts:t(end))';
qi = interp1(t,q,ti);
ui = interp1(t,u,ti);

%1. filtering
if ismember('G',options)%gaussian filter
    uf = gauss_filter(ui,N,wn);
    qf = gauss_filter(qi,N,wn);
    title_str = sprintf('gauss filter\n N=%d, wn=%g',N,wn);
elseif ismember('B',options)%butter filter
    uf = butter_filter(ui,N,wn);
    qf = butter_filter(qi,N,wn);
    title_str = sprintf('butterworth filter\n N=%d, wn=%g',N,wn);
elseif ismember('A',options)%average filter
    uf = moving_average(ti,ui,N);
    qf = moving_average(ti,qi,N);
    title_str = sprintf('average filter\n N=%d',N,wn);
else%no filtering!
    uf = ui;
    qf = qi;
    title_str = sprintf('no filter');
end
dudt = moving_derivative(ti,uf,100*Ts);
dqdt = moving_derivative(ti,qf,100*Ts);

dudq = dudt./dqdt;
dqdu = dqdt./dudt;

if ismember('g',options)
    figure;
    subplot(221),plot(qf,uf),xlabel('Ah'),ylabel('V')
    title(title_str)
    subplot(222),plot(dqdu,uf),title('ICA plot'),xlabel('Ah/V'),ylabel('V')
    subplot(223),plot(qf,dudq),title('DVA plot'),xlabel('Ah'),ylabel('V/Ah')
end

end