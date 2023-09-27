function [dqdu,dudq,qf,uf] = calcul_ica(t,q,u,N,wn,options)
% calcul_ica2 resample, filter et derivate data for ica
%
% Usage 
% [dqdu,dudq,qf,uf] = calcul_ica(t,q,u,N,wn,options)
% Inputs :
% - t [nx1 double]: time in seconds
% - q [nx1 double]: cell capacity in Ah
% - u [nx1 double]: cell voltage in V
% - N: [double] Filter order
% - wn: [double] filter frequency cut
% - options : 
%   -N: Filter type : no filter
%   -G: Filter type : gaussian filter
%   -M: Filter typestr : mean filter
%   -B: Filter type :  butter filter
%   -b: Filter type : balanced, i.e. filter à l'endroit et à l'envers, puis moyenner
%   -g : show figures
% Outputs
% - dqdu [nx1 double]: derivative of capacity over voltage in Ah/V
% - dudq [nx1 double]: derivative of voltage over capacity in V/Ah
% - q [nx1 double]: filtered cell capacity in Ah
% - u [nx1 double]: filtered cell voltage in V
%
% See also moving_derivative, gauss_filter, moving_average, butter_filter
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

if ~exist('options','var')
    options = '';%no filter
end
%0. constant sampling:
Ts = max(1,min(unique(diff(t))));

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

dudq = -dudt./dqdt;
dqdu = -dqdt./dudt;

if ismember('g',options)
    figure;
    subplot(221),plot(qf,uf),xlabel('Ah'),ylabel('V')
    title(title_str)
    subplot(222),plot(dqdu,uf),title('ICA plot'),xlabel('Ah/V'),ylabel('V')
    subplot(223),plot(qf,dudq),title('DVA plot'),xlabel('Ah'),ylabel('V/Ah')
end

end