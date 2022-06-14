function err_qua = error_quadratic(Um,Us)
% error_relative Calculate quadratic error between two vectors
%
% err_rel = error_quadratic(Um,Us)
% Calculate quadratic error between vectors Um and Us
%
% Usage:
% err_rel = error_quadratic(Um,Us)
% Inputs:
% - Um [nx1 double]: First vector
% - Us [nx1 double]: Second vector
%
% Output:
% - err_rel [nx1 double]: Quadratic error between vectors inputs
%
%See also calcul_r
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

if nargin<1 || nargin>2
    fprintf('error_quadratic: wrong number of parameters, found %d\n',nargin);
    return;
end
if  ~isnumeric(Um) ||  ~isnumeric(Us)
    fprintf('error_quadratic: wrong type of parametres\n');
    return;
end

err_qua = abs(Us-Um).^2;
end