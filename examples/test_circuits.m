% test circuits
f = logspace(-3,4,50);%from 1mHz to 10kHz 50 points

Zparams.RL = 10;
Zparams.L = 0.0000005;
Zparams.R = 0.015;
Zparams.RC = 0.01;
Zparams.C = 100;
Zparams.Q = 500;
Zparams.a = 0.5;
%RL
Zrl =  circuit_rl(Zparams,f);
%RC
Zrc =  circuit_rc(Zparams,f);
%RRC
Zrrc =  circuit_rrc(Zparams,f);
%RRCQ
Zrrcq = circuit(Zparams,f,'rrcq');


ha = plot_nyquist_z(Zrl,f);
plot_nyquist_z(Zrc,f,ha);
plot_nyquist_z(Zrrc,f,ha);
plot_nyquist_z(Zrrcq,f,ha);

figure;
ha = [subplot(211), subplot(212)];
subplot(211), title amplitude,hold on
subplot(212), title angle, hold on

plot_bode_z(Zrl,f,ha);
plot_bode_z(Zrc,f,ha);
plot_bode_z(Zrrc,f,ha);
plot_bode_z(Zrrcq,f,ha);

% 
% figure;
% ha(1) = subplot(121), hold on;
% ha(2) = subplot(222), hold on;
% ha(3) = subplot(224), hold on;
% plot_nyquist_z(Z,f,ha(1));
% plot_bode_z(Z,f,ha(2:3));
