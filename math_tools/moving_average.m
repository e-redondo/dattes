function [xm] = moving_average(t,x,T)
%function xm = moving_average(t,x,T)
%ATTENTION, Ts du signal doit etre constant
indDebut = find(t-t(1)>=T,1);
indFin = find(t>=t(end)-T,1);
t1 = t(indDebut+1:end);
t0 = t(1:end-indDebut);
x1 = x(indDebut+1:end);
x0 = x(1:end-indDebut);
%%espace en memoire
xm = zeros(size(x));

%partie milieu
%moyenne = sum(x)/length(x): L = length(x) = 2*indDebut-1
L1 = indDebut-1;
for ind = indDebut:indFin
%         xm(ind) = mean(x(ind-indDebut+1:ind+indDebut-1));
    xm(ind) = sum(x(ind-L1:ind+L1));
%     xm(ind) = sum(x(ind-indDebut+1:ind+indDebut-1));
end
%premiere partie
xm(1:indDebut-1) = xm(indDebut);
%derniere partie
xm(indFin+1:end) = xm(indFin);
%completion avec des zeros au debut
L = 2*indDebut-1;
xm = xm/L;
end