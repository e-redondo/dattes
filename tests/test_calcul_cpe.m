function  [R_id, Q_id, a_id] = test_calcul_cpe(R,Q,a,options)

if ~exist('options','var')
    options = 'vg'; %default verbose and graphics
end
if ~exist('R','var')
    % circuit parameters
    R = 0.01*rand(1);
    Q = 10000*rand(1);
    a = 0.1 +rand(1)*0.8;
end
% a = 0.5;
% t,I,U profiles
t = (0:0.1:700)';
Ip = 1; %1A pulse
td = 100;%pulse start time
tf = 400;%pulse end time
I = zeros(size(t));
I(t>=td & t<tf) = Ip; %1A pulse 5min

A_noise = 0.001; %1mV noise

U_noise = A_noise*rand(size(t));
U_noise = U_noise-mean(U_noise);

% figure;
% plot(U_noise)
U = response_rcpe_pulse(R,Q,a,Ip,td,tf,t);
U = U+U_noise;


%dod profile, not important just to satisfy calcul_r inputs:
DoD = calcul_amphour(t,I);

%config:
config = cfg_default;
% identification of R:
%take just some second of pulse for R identification:
ind_p = t<td+10;
t_p = t(ind_p);
U_p = U(ind_p);
I_p = I(ind_p);
DoD_p = DoD(ind_p);

t_s = tic;
[R_id, this_crate, this_time, this_dod,this_delta_time, err] = calcul_r(t_p,U_p,I_p,DoD_p,td,9,inf ,0);

% R_id2 = calcul_r0(t_p,U_p,I_p,10, 10);
U_residual = U - R_id*I;
% identification of cpe:
% [Q_id, a_id, err_rel, Ip_id] = calcul_cpe_pulse(t,U_residual,I,'a',a);
[Q_id, a_id, err_rel, Ip_id] = calcul_cpe_pulse(t,U_residual,I);
t_el = toc(t_s);

%simulate identfied model:
U_s = response_rcpe_pulse(R_id,Q_id,a_id,Ip,td,tf,t);

%recalculate err_rel, because this did not contain err by R accuracy
err_rel = mean(abs(error_relative(U,U_s)));

%Report results:

if ismember('v',options)
    fprintf('calcul_r + calcul_cpe:\t%.3fseconds, err_rel: %.3f, err_R: %.3f, err_Q: %.3f\n',t_el, err_rel,abs(1-R_id/R),abs(1-Q_id/Q));
end

if ismember('g',options)
    %show results:

    figure;
    subplot(311), plot(t,I);
    subplot(312), plot(t,U), hold on
    plot(t,U_s,'r')
    subplot(313), plot(t,U_s-U,'r','Displayname', sprintf('err rel = %.3f',err_rel)),hold on

    legend show
end
end
