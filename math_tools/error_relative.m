function err_rel = error_relative(Um,Us)
% error_relative Calculate relative error between two vectors
%
% err_rel = error_relative(Um,Us)
% Calculate relative error between vectors Um and Us
%
% Usage:
% err_rel = error_relative(Um,Us)
% Inputs:
% - Um [nx1 double]: First vector
% - Us [nx1 double]: Second vector
%
% Output:
% - err_rel [nx1 double]: Relative error between vectors inputs
%
%See also calcul_r
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

if nargin<1 || nargin>2
    fprintf('error_relative: wrong number of parameters, found %d\n',nargin);
    return;
end
if  ~isnumeric(Um) ||  ~isnumeric(Us)
    fprintf('error_relative: wrong type of parametres\n');
    return;
end


err_rel = (Us-Um)./max(abs(Um));
end
