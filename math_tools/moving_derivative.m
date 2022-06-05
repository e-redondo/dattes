function [dxdt] = moving_derivative(t,x,T)
% moving_derivative Calculate moving derivative of two vectors
%
% [dxdt] = moving_derivative(t,x,T)
% Calculate moving derivative of vectors x and t  with a step time of T
%
% Usage:
% [dxdt] = moving_derivative(t,x,T)
% Inputs:
% - t [nx1 double]: First vector for derivative
% - x [double]: Second  vector for derivative
% - T [double]: Step time for derivation
%
% Output:
% - dxdt [nx1 double]: Derivative of x over t
%
%See also 
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.


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


end