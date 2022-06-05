function [xf] = gauss_filter(x,N,wn)
% gauss_filter Filter data with gaussian filter
%
% [xf] = gauss_filter(x,N,wn)
% Filter x vector with a gaussian filter 
%
% Usage:
% [xf] = gauss_filter(x,N,wn)
% Inputs:
% - x [nx1 double]: Vector to filter
% - N [double]: Filter order vector
% - wn [double]: Filter cut frequency
%
% Output:
% - xf [nx1 double]: Filtered vector
%
%See also 
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

    xx = linspace(-N / 2, N / 2, N);
    b = exp(-xx .^ 2 / (2 * (1/wn) ^ 2));
    b = b / sum (b); % normalize
    a = 1;
    xf = filter(b,a,x-x(1))+x(1);
    
    %saturation to range of x:
    xf(xf<min(x))=min(x);
    xf(xf>max(x))=max(x);
    

end