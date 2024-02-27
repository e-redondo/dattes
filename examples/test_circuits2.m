% test circuits
f = logspace(-3,4,50);%from 1mHz to 10kHz 50 points

Zparams.RL = 10;
Zparams.L = 0.0000005;
Zparams.R = 0.01;
Zparams.RC = [0.02 0.03] ;
Zparams.C = [100 1000];
Zparams.RQ = [0.04 inf];
Zparams.Q = [500 5000];
Zparams.a = [0.7 0.5];


Z = cell(0);
% 'randles'
Z{1} = circuit_randles(Zparams,f);
% 'debye'
Z{2} = circuit_debey(Zparams,f);
% 'rrc'
Z{3} = circuit_rrc(Zparams,f);
% 'rrcq'
Z{4} = circuit_rrcq(Zparams,f);
% 'rrq'
Z{5} = circuit_rrq(Zparams,f);
% 'rrcrq'
Z{6} = circuit_rrcrq(Zparams,f);



ha = plot_nyquist_z(Z{1},f);
for ind = 2:length(Z)
    plot_nyquist_z(Z{ind},f,ha);
end

