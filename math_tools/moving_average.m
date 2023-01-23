function [xm] = moving_average(t,x,T)
% moving_average Filter data with a moving average filter
%
% [xm] = moving_average(t,x,T)
% Filter x vector with a moving average filter
% sample time is supposed to be constant
%
% Usage:
% [xm] = moving_average(t,x,T)
% Inputs:
% - x [nx1 double]: Vector to filter
% - T [double]: Filter order (period for moving average in units of t)
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
index_start = find(t-t(1)>=T,1);
index_end = find(t>=t(end)-T,1)-1;

if isempty(index_start) || isempty(index_end) || index_start>index_end
    xm = [];
    return
end

%%espace en memoire
xm = zeros(size(x));

%partie milieu
%moyenne = sum(x)/length(x): L = length(x) = 2*indDebut-1
L1 = index_start-1;
for ind = index_start:index_end
%         xm(ind) = mean(x(ind-indDebut+1:ind+indDebut-1));
    xm(ind) = sum(x(ind-L1:ind+L1));
%     xm(ind) = sum(x(ind-indDebut+1:ind+indDebut-1));
end
%premiere partie
xm(1:index_start-1) = xm(index_start);
%derniere partie
xm(index_end+1:end) = xm(index_end);
%completion avec des zeros au debut
L = 2*index_start-1;
xm = xm/L;

end