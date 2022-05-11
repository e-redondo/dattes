function [xi,yi,yf,dydx] = calcul_ica(x,y,dx,N,wn,options)
%funcion essaiICA2 - recoupe, filtre et derive
% -N: no filter
% -G: gaussian filter
% -M: mean filter
% -B: butter filter
% -b: balanced, i.e. filter à l'endroit et à l'envers, puis moyenner

if ~exist('options','var')
    options='N';%no filter
end

% xi = (min(x):dx:max(x))';
if x(1)<x(end)
    xi = (x(1):dx:x(end))';
else
    xi = (x(1):-dx:x(end))';
end
yi = interp1(x,y,xi);

%filtering:
if ismember('G',options)%gaussian filter
%     wn = 5;
%     N = 30;
    xx = linspace(-N / 2, N / 2, N);
    b = exp(-xx .^ 2 / (2 * (1/wn) ^ 2));
    b = b / sum (b); % normalize
    a = 1;
%     figure('name','Gauss');plot(b)
elseif ismember('M',options)%mean filter
    b = ones(1,N)/N;
    a = 1;
elseif ismember('B',options)%butter filter
    [b,a] =butter(N,wn,'low');
else%no filter
    a = 1;b = 1;
end
if ismember('b',options)%balanced
yf1 = filter(b,a,yi);
yf2 = filter(b,a,yi(end:-1:1));
yf2 = yf2(end:-1:1);

yf = (yf1.*(0:length(xi)-1)'+yf2.*(length(xi)-1:-1:0)')/length(xi);
else
    yf = filter(b,a,yi);
end
%derivate:
dydx = [0;diff(yf)./diff(xi)];
if ismember('g',options)
    showResults(x,y,xi,yi,yf,dydx)
end

end
function showResults(x,y,xi,yi,yf,dydx)

figure('name','calcul_ica');
subplot(221),plot(x,y,'b',xi,yi,'k.',xi,yf,'r'),legend('y','y interp','y filtered')
subplot(223),plot(xi, dydx,'b'),legend('dydx vs xi')
subplot(222),plot(1./dydx,yi,'b'),legend('dxdy vs yi')

end