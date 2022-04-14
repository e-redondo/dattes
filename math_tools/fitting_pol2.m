function Y = fitting_pol2(xi,yi,X,w)
if ~exist('w','var')
    if (max(yi)==min(yi) || max(xi)==min(xi))
        w = nan;
    else
        Xm = [xi yi];
        D = sqrt((Xm(:,1) - mean(Xm(:,1))).^2);%distance par rapport a la moyenne (equivaut a mahal(x,x))
        w = 1./D;
    end
end
ws = warning('off','all');%TODO gerer ca un peu mieux...
if max(isnan(w))
    p = polyfit(xi,yi,2);
    fprintf('fittingPol2: nan in weight vector\n')
else
    p = polyfitweighted(xi,yi,2,w);
end
warning(ws);%TODO gerer ca un peu mieux...
Y = polyval(p,X);

end