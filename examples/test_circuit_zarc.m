% test circuits
f = logspace(-10,10,100);%from 1mHz to 10kHz 50 points

figure;
a = [0.25 0.5 0.75 0.9 1];

for ind = 1:length(a)

Zparams.RQ = [0.02, 0.03];
Zparams.Q = [1 100];
Zparams.a = a(ind)*ones(size(Zparams.Q));


Z = circuit_rq(Zparams,f);
plot_nyquist_z(Z,f,gcf);

end
% plot_bode_z(Z,f);


