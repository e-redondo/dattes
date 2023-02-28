clear all
close all

N = 100; %number of points on each test

%test 1: Resistance sweep from 1mOhm to 10 mOhm
R_min = 0.010;
R_max = 0.1;

R = linspace(R_min,R_max,N);
for ind = 1:length(R)
    %test ident_cpe
[R_id(ind)] = test_calcul_r(R(ind),1000,0.5,'');
%test_ident_rcpe
[R_id2(ind)] = test_calcul_r0(R(ind),1000,0.5,'');

fprintf('R sweep, %d of %d\n',ind,length(R));
end
err1 = 1-R_id./R;%calcul_r error
err2 = 1-R_id2./R;%calcul_r0 error

figure('Name','Accuracy comparison with different R values')
subplot(121),plot(R,err1,'bo')
hold on
plot(R,err2,'rx')
xlabel 'R (Ohm)'
ylabel '1-R identified / R'
title(sprintf('R from %g to %g',R_min,R_max))
subplot(122),boxchart([err1;err2]')

xticklabels({'calcul r','calcul r0'})
%test 2: Q sweep fromm 100 to 10000:
clearvars -except N

Q_min = 100;
Q_max = 10000;

Q = linspace(Q_min,Q_max,N);


for ind = 1:length(Q)
    %test ident_cpe
[R_id(ind)] = test_calcul_r(0.010,Q(ind),0.5,'');
%test_ident_rcpe
[R_id2(ind)] = test_calcul_r0(0.010,Q(ind),0.5,'');

    fprintf('Q sweep, %d of %d\n',ind,length(Q));
end
err1 = 1-R_id./0.010;%calcul_r error
err2 = 1-R_id2./0.010;%calcul_r0 error

figure('Name','Accuracy comparison with different Q values')
subplot(121),plot(Q,err1,'bo')
hold on
plot(Q,err2,'rx')
xlabel 'Q (1/Ohm^a)'
ylabel '1-R identified / R'
title 'R = 0.01 Ohm'
subplot(122),boxchart([err1;err2]')

xticklabels({'calcul r','calcul r0'})