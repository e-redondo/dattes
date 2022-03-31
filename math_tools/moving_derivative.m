function [dxdt] = moving_derivative(t,x,T)
%function dxdt = moving_derivative(t,x,T)
%ATTENTION, Ts du signal doit etre constant
indDebut = find(t-t(1)>=T,1);
t1 = t(indDebut+1:end);
t0 = t(1:end-indDebut);
x1 = x(indDebut+1:end);
x0 = x(1:end-indDebut);
%calcul de la derive moyenne entre t1 et t0 (dt = T)
dxdt = (x1-x0)./(t1-t0);
%completion avec des zeros au debut

dxdt  = [zeros(ceil((length(t)-length(dxdt))/2),1);dxdt;zeros(floor((length(t)-length(dxdt))/2),1)];

% %derive en temps inverse
% [ti I] = sort(t(end)-t);
% xi = x(I);
% 
% t1 = ti(indDebut+1:end);
% t0 = ti(1:end-indDebut);
% x1 = xi(indDebut+1:end);
% x0 = xi(1:end-indDebut);
% %calcul de la derive moyenne entre t1 et t0 (dt = T)
% dxdt2 = (x1-x0)./(t1-t0);
% %completion avec des zeros au debut
% dxdt2  = [zeros(length(t)-length(dxdt2),1);dxdt2];
% %je remet a l'envers:
% dxdt2 = -dxdt2(end:-1:1);
end