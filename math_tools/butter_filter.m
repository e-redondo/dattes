function [xf] = butter_filter(x,N,wn)
% butter_filter Filter data with butter filter
%
% [xf] = butter_filter(x,N,wn)
% Filter x vector with a butter filter 
%
% Usage:
% [xf] = butter_filter(x,N,wn)
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

    [a, b] = butter(N, wn);
    xf = filter(b,a,x-x(1))+x(1);
    
    %saturation to range of x:
    xf(xf<min(x))=min(x);
    xf(xf>max(x))=max(x);
    
    figure;
    subplot(211), plot(x),hold on, plot(xf)
    subplot(212), plot(xf-x)
end