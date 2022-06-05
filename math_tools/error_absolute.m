function err_abs = error_absolute(Um,Us)
% error_absolute Calculate absolute error between two vectors
%
% err_abs = error_absolute(Um,Us)
% Calculate absolute error between vectors Um and Us
%
% Usage:
% err_abs = error_absolute(Um,Us)
% Inputs:
% - Um [nx1 double]: First vector
% - Us [nx1 double]: Second vector
%
% Output:
% - err_abs [nx1 double]: Absolute error between vectors inputs
%
%See also calcul_r
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

if nargin<1 || nargin>2
    fprintf('error_absolute: wrong number of parameters, found %d\n',nargin);
    return;
end
if  ~isnumeric(Um) ||  ~isnumeric(Us)
    fprintf('error_absolute: wrong type of parametres\n');
    return;
end

err_abs = abs(Us-Um);
end