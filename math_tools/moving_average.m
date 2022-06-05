function [xm] = moving_average(t,x,T)
% moving_average Filter data with a moving average filter
%
% [xm] = moving_average(t,x,T)
% Filter x vector with a moving average filter
%
% Usage:
% [xm] = moving_average(t,x,T)
% Inputs:
% - x [nx1 double]: Vector to filter
% - N [double]: Filter order vector
% - wn [double]: Filter cut frequency
%
% Output:
% - xm [nx1 double]: Filtered vector
%
%See also 
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

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