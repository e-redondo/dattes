function [xf] = spike_filter(x, N)
% spike_filter Finds the average value of spiky data, removing extreme
% points
%
% [xf] = spike_filter(x, N)
%
% Inputs:
% - x [nx1 double]: Vector to filter
% - N [double]: Percentage of points to be filtered
%
% Ex: spike_filter(x,20). If x has 10 elements, 2 (highest and lowest) will
% be removed and the average will be calculated with the remainder.
%
% Output:
% - xf [1x1 double]: Average of the filtered vector
%
% See also butter_filter, gauss_filter
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

if nargin < 2
    error(message('Too Few Inputs'));
elseif ~isscalar(N) || N >= 100 || N < 0
    error(message('Invalid Percent value'));
end

% Orders input vector 
x_med = median(x);
x_dist = abs(x-x_med);
[~, ind_sort] = sort(x_dist);


% Find how many data points to remove
n = length(x);
k = n*N/100;     % desired k to trim
k0 = floor(k);   % integer 

xf = mean(x(ind_sort(1:end-k0)));
end
