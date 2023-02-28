clear all
% close all

N = 10; %number of points on each test

%test 1: Resistance sweep from 1mOhm to 10 mOhm
R_min = 0.010;
R_max = 0.1;

R = linspace(R_min,R_max,N);
Q = 1000*ones(size(R));
a = 0.5*ones(size(R));

for ind = 1:length(R)
    %test ident_cpe
[R_id(ind), Q_id(ind), a_id(ind)] = test_calcul_cpe(R(ind),Q(ind),a(ind),'');
%test_ident_rcpe
[R_id2(ind), Q_id2(ind), a_id2(ind)] = test_calcul_rcpe(R(ind),Q(ind),a(ind),'');

fprintf('R sweep, %d of %d\n',ind,length(R));
end

err_id_R = R_id./R-1;
err_id_R2 = R_id2./R-1;
err_id_Q = Q_id./Q-1;
err_id_Q2 = Q_id2./Q-1;
err_id_a = a_id./a-1;
err_id_a2 = a_id2./a-1;

figure('Name','Accuracy comparison with different R values')
subplot(221),plot(R,err_id_R,'bo')
hold on
plot(R,err_id_R2,'rx')
xlabel 'R (Ohm)'
ylabel 'R identified / Q'
title(sprintf('R from %g to %g',R_min,R_max))

subplot(222),
plot(R,err_id_Q,'bo')
hold on
plot(R,err_id_Q2,'rx')
xlabel 'R (Ohm)'
ylabel 'Q identified / Q'
title 'Q = 1000'

subplot(224)
plot(R,err_id_a,'bo')
hold on
plot(R,err_id_a2,'rx')
xlabel 'R (Ohm)'
ylabel 'a identified / a'
title 'a = 0.5'


subplot(223)

ydata = [err_id_R,err_id_Q,err_id_a,err_id_R2,err_id_Q2,err_id_a2];

xdata = [repmat((1:3),N,1)];
xdata = repmat(xdata,1,2);
xdata = reshape(xdata,size(ydata));

cdata = ones(size(ydata));
cdata(end/2:end) = 2;
boxchart(xdata,ydata,'GroupByColor',cdata);

ylabel('error in parameter (p.u.)')

xticks(1:3)
xticklabels({'err R','err Q','err a'})
legend('calcul cpe','calcul rcpe')

%test 2: Q sweep fromm 100 to 10000:
clearvars -except N

Q_min = 100;
Q_max = 10000;

Q = linspace(Q_min,Q_max,N);
R = 0.01*ones(size(Q));
a = 0.5*ones(size(Q));


for ind = 1:length(Q)
    %test ident_cpe
    [R_id(ind), Q_id(ind), a_id(ind)] = test_calcul_cpe(R(ind),Q(ind),a(ind),'');
    %test_ident_rcpe
    [R_id2(ind), Q_id2(ind), a_id2(ind)] = test_calcul_rcpe(R(ind),Q(ind),a(ind),'');

    fprintf('Q sweep, %d of %d\n',ind,length(Q));
end

err_id_R = R_id./R-1;
err_id_R2 = R_id2./R-1;
err_id_Q = Q_id./Q-1;
err_id_Q2 = Q_id2./Q-1;
err_id_a = a_id./a-1;
err_id_a2 = a_id2./a-1;

figure('Name','Accuracy comparison with different Q values')
subplot(221),plot(Q,err_id_R,'bo')
hold on
plot(Q,err_id_R2,'rx')
xlabel 'Q (1/Ohm^a)'
ylabel 'R identified / Q'
title 'R = 0.01 Ohm'


subplot(222),
plot(Q,err_id_Q,'bo')
hold on
plot(Q,err_id_Q2,'rx')
xlabel 'Q (1/Ohm^a)'
ylabel 'Q identified / Q'
title(sprintf('Q from %g to %g',Q_min,Q_max))

subplot(224)
plot(Q,err_id_a,'bo')
hold on
plot(Q,err_id_a2,'rx')
xlabel 'Q (1/Ohm^a)'
ylabel 'a identified / a'
title 'a = 0.5'


subplot(223)

ydata = [err_id_R,err_id_Q,err_id_a,err_id_R2,err_id_Q2,err_id_a2];

xdata = [repmat((1:3),N,1)];
xdata = repmat(xdata,1,2);
xdata = reshape(xdata,size(ydata));

cdata = ones(size(ydata));
cdata(end/2:end) = 2;
boxchart(xdata,ydata,'GroupByColor',cdata);

ylabel('error in parameter (p.u.)')

xticks(1:3)
xticklabels({'err R','err Q','err a'})
legend('calcul cpe','calcul rcpe')