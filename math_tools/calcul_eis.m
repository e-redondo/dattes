function Zparams = calcul_eis(Z,f)

% x = [RL L R R1 C1 Q a]
monCaller = @(x) error_eis(x(1),x(2),x(3),x(4),x(5),x(6),x(7),Z,f);
x0 = [100; 5e-09; 0.075; 0.01; .300; 1000; 0.5];


opts = optimset('TolX',1e-6,'TolFun',1e-6,'MaxFunEvals',1e4,'MaxIter',1e4);
[x,fval,exitflag,output] = fminsearch(monCaller,x0,opts);

%I tried fmincon but it converges to infeasible points.
% % all variables greater than 0
%  Apos = -eye(length(x0));
%  bpos = zeros(size(x0));
% % 
% % %sum of resistances lower than max real part of Z
%  Armax = [1,0,1,1,0,0,0];
%  brmax = max(real(Z));
%  A = [Apos;Armax];
%  b = [bpos;brmax];
% [x,fval,exitflag,output] = fmincon(monCaller,x0,A,b,[],[],[],[],[],opts);

Zparams.RL = x(1);
Zparams.L = x(2);
Zparams.R = x(3);
Zparams.RC = x(4);
Zparams.C = x(5);
Zparams.Q = x(6);
Zparams.a = x(7);

end

function err = error_eis(RL, L, R, R1, C1, Q, a,Z,f)
Zparams.RL = RL;
Zparams.L = L;
Zparams.R = R;
Zparams.RC = R1;
Zparams.C = C1;
Zparams.Q = Q;
Zparams.a = a;

Zs = circuit_rrcq(Zparams,f);


% I tried other distances but best resuls seemed come with:
err = mean(abs(Zs-Z));

% other distances I have tried:
% err = mean(abs(real(Zs)-real(Z)));
% err = mean(abs(imag(Zs)-imag(Z)));
% err = mean(abs(abs(Zs)-abs(Z)));
% err = mean(abs(real(Zs)-real(Z)))+mean(abs(imag(Zs)-imag(Z)));
% err = mean(max(abs(real(Zs)-real(Z)),abs(imag(Zs)-imag(Z))));

end

function err = error_eis2(Zparams,Z,f)
% Zparams.RL = RL;
% Zparams.L = L;
% Zparams.R = R;
% Zparams.RC = R1;
% Zparams.C = C1;
% Zparams.Q = Q;
% Zparams.a = a;

Zs = circuit_rrcq(Zparams,f);


% I tried other distances but best resuls seemed come with:
err = mean(abs(Zs-Z));

% other distances I have tried:
% err = mean(abs(real(Zs)-real(Z)));
% err = mean(abs(imag(Zs)-imag(Z)));
% err = mean(abs(abs(Zs)-abs(Z)));
% err = mean(abs(real(Zs)-real(Z)))+mean(abs(imag(Zs)-imag(Z)));
% err = mean(max(abs(real(Zs)-real(Z)),abs(imag(Zs)-imag(Z))));

end
