% test circuits
f = logspace(-3,3,100);%from 1mHz to 10kHz 50 points

figure;


Zparams.RC = [0.02, 0.03];
Zparams.C = [1 100];

Z = circuit_rc(Zparams,f);
plot_nyquist_z(Z,f);

% plot_bode_z(Z,f);


