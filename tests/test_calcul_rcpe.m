function  [R_id2, Q_id2, a_id2] = test_ident_rcpe(R,Q,a,options)

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



%method2: ident_rcpe:
t_s2 = tic;
% [R_id2, Q_id2, a_id2, err_rel2, Ip_id] = calcul_rcpe_pulse(t,U,I,'a',a);
[R_id2, Q_id2, a_id2, err_rel2, Ip_id] = calcul_rcpe_pulse(t,U,I);
t_el2 = toc(t_s2);
U_s2 = response_rcpe_pulse(R_id2,Q_id2,a_id2,Ip,td,tf,t);
err_rel2 = mean(abs(error_relative(U,U_s2)));

%Report results:

if ismember('v',options)
    fprintf('calcul_rcpe:\t\t%.3fseconds, err_rel: %.3f, err_R: %.3f, err_Q: %.3f\n',t_el2, err_rel2,abs(1-R_id2/R),abs(1-Q_id2/Q));
end

if ismember('g',options)
    %show results:

    figure;
    subplot(311), plot(t,I);
    subplot(312), plot(t,U), hold on
    plot(t,U_s2,'g')
    subplot(313)
    plot(t,U_s2-U,'g','Displayname', sprintf('err rel = %.3f',err_rel2)),hold on

    legend show
end
end