function [xf] = gauss_filter(x,N,wn)
% function [xf] = gauss_filter(x,N,wn)

    xx = linspace(-N / 2, N / 2, N);
    b = exp(-xx .^ 2 / (2 * (1/wn) ^ 2));
    b = b / sum (b); % normalize
    a = 1;
    xf = filter(b,a,x-x(1))+x(1);
    
    %saturation to range of x:
    xf(xf<min(x))=min(x);
    xf(xf>max(x))=max(x);
    
%     figure;
%     subplot(211), plot(x),hold on, plot(xf)
%     subplot(212), plot(xf-x)
end