clear all
% close all

N = 100; %number of points on each test

%test 1: Resistance sweep from 1mOhm to 10 mOhm
Rs_min = 0.010;
Rs_max = 0.1;

Rs = linspace(Rs_min,Rs_max,N);
R = 0.05*ones(size(Rs));
C = 1000*ones(size(Rs));

for ind = 1:length(Rs)
    %test calcul_rrc
    [Rs_id(ind), R_id(ind), C_id(ind)] = test_calcul_rrc(Rs(ind),R(ind),C(ind),'');
    %test_calcul_rrc_pulse
    [Rs_id2(ind), R_id2(ind), C_id2(ind)] = test_calcul_rrc_pulse(Rs(ind),R(ind),C(ind),'');

    fprintf('Rs sweep, %d of %d\n',ind,length(Rs));
end

err_id_Rs = Rs_id./Rs-1;
err_id_Rs2 = Rs_id2./Rs-1;
err_id_R = R_id./R-1;
err_id_R2 = R_id2./R-1;
err_id_C = C_id./C-1;
err_id_C2 = C_id2./C-1;

figure('Name','Accuracy comparison with different Rs values')
subplot(221),plot(Rs,err_id_Rs,'bo')
hold on
plot(Rs,err_id_Rs2,'rx')
xlabel 'Rs (Ohm)'
ylabel 'error (p.u.)'
title(sprintf('R from %g to %g',Rs_min,Rs_max))

subplot(222),
plot(Rs,err_id_R,'bo')
hold on
plot(Rs,err_id_R2,'rx')
xlabel 'R (Ohm)'
ylabel 'error (p.u.)'
title(sprintf('R = %g',R(1)))

subplot(224)
plot(Rs,err_id_C,'bo')
hold on
plot(Rs,err_id_C2,'rx')
xlabel 'R (Ohm)'
ylabel 'error (p.u.)'
title(sprintf('C = %g',C(1)))


subplot(223)

ydata = [err_id_Rs,err_id_R,err_id_C,err_id_Rs2,err_id_R2,err_id_C2];

xdata = [repmat((1:3),N,1)];
xdata = repmat(xdata,1,2);
xdata = reshape(xdata,size(ydata));

cdata = ones(size(ydata));
cdata(end/2:end) = 2;
boxchart(xdata,ydata,'GroupByColor',cdata);

ylabel('error in parameter (p.u.)')

xticks(1:3)
xticklabels({'err Rs','err R','err C'})
legend('calcul rrc','calcul rrc pulse')

%test 2: Q sweep fromm 100 to 10000:
clearvars -except N

R_min = 0.010;
R_max = 0.1;

R = linspace(R_min,R_max,N);
Rs = 0.01*ones(size(R));
C = 1000*ones(size(R));


for ind = 1:length(R)
    %test ident_cpe
    [Rs_id(ind), R_id(ind), C_id(ind)] = test_calcul_rrc(Rs(ind),R(ind),C(ind),'');
    %test_ident_rcpe
    [Rs_id2(ind), R_id2(ind), C_id2(ind)] = test_calcul_rrc_pulse(Rs(ind),R(ind),C(ind),'');

    fprintf('R sweep, %d of %d\n',ind,length(R));
end

err_id_Rs = Rs_id./Rs-1;
err_id_Rs2 = Rs_id2./Rs-1;
err_id_R = R_id./R-1;
err_id_R2 = R_id2./R-1;
err_id_C = C_id./C-1;
err_id_C2 = C_id2./C-1;

figure('Name','Accuracy comparison with different Q values')
subplot(221),plot(R,err_id_Rs,'bo')
hold on
plot(R,err_id_Rs2,'rx')
xlabel 'R'
ylabel 'error (p.u.)'
title(sprintf('Rs = %g',Rs(1)))


subplot(222),
plot(R,err_id_R,'bo')
hold on
plot(R,err_id_R2,'rx')
xlabel 'R'
ylabel 'error (p.u.)'
title(sprintf('R from %g to %g',R_min,R_max))

subplot(224)
plot(R,err_id_C,'bo')
hold on
plot(R,err_id_C2,'rx')
xlabel 'R'
ylabel 'error (p.u.)'
title(sprintf('C = %g',C(1)))


subplot(223)

ydata = [err_id_Rs,err_id_R,err_id_C,err_id_Rs2,err_id_R2,err_id_C2];

xdata = [repmat((1:3),N,1)];
xdata = repmat(xdata,1,2);
xdata = reshape(xdata,size(ydata));

cdata = ones(size(ydata));
cdata(end/2:end) = 2;
boxchart(xdata,ydata,'GroupByColor',cdata);

ylabel('error in parameter (p.u.)')

xticks(1:3)
xticklabels({'err Rs','err R','err C'})
legend('calcul rrc','calcul rrc pulse')