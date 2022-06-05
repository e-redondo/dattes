function Y = fitting_pol2(xi,yi,X,w)
%fitting_pol2   Find a least-squares fit of 1D data y(x) with an 1st order polynomial weighted by w
%
% Usage
% Y = fitting_pol2(xi,yi,X,w)%
% Inputs :
% - xi [nx1 double]: x array for identification of the polynomial
% - yi [nx1 double]: y array for identification of the polynomial
% - X [nx1 double]:  X array for interpolation/extrapolation
% - w [nx1 double]: vector of weight
%
%  Outputs
% - Y : Coefficients of the polynomial 
% See also ident_r
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

if ~exist('w','var')
    if (max(yi)==min(yi) || max(xi)==min(xi))
        w = nan;
    else
        Xm = [xi yi];
        D = sqrt((Xm(:,1) - mean(Xm(:,1))).^2);%distance versus average value
        w = 1./D;
    end
end
ws = warning('off','all');
if max(isnan(w))
    p = polyfit(xi,yi,2);
    fprintf('fittingPol2: nan in weight vector\n')
else
    p = polyfitweighted(xi,yi,2,w);
end
warning(ws);
Y = polyval(p,X);

end