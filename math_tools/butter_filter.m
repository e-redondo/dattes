function [xf] = butter_filter(x,N,wn)
% function [xf] = butter_filter(t,x,N,wn)

    [a, b] = butter(N, wn);
    xf = filter(b,a,x-x(1))+x(1);
    
    %saturation to range of x:
    xf(xf<min(x))=min(x);
    xf(xf>max(x))=max(x);
    
    figure;
    subplot(211), plot(x),hold on, plot(xf)
    subplot(212), plot(xf-x)
end