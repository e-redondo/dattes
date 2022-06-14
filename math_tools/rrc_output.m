function U = rrc_output(t,I,Rs,R,C)
% rrc_output calculate the voltage response of a R+RC circuit
%
% Usage
% U = rrc_output(t,I,Rs,R,C)
% Inputs
% - t: [nx1 double] time vector in s
% - I: [nx1 double] current vector in A
% - Rs: [double] Ohmic resistance vector in Ohm
% - R: [double] Identified resistance R in Ohm
% - C: [double] Identified capacity C in Farad
% Outputs
% - U:[nx1 double] Voltage response of the R+RC circuit
%
% See also ident_rrc, rc_output
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

if ~isnumeric(Rs) || ~isnumeric(R) ||  ~isnumeric(C) ||  ~isnumeric(t) ||  ~isnumeric(I) 
    U = [];
    fprintf('rrc_output:Error, inputs must be numerical\n');
    return
end
if numel(R) ~= 1 || numel(C) ~= 1 
    U = [];
    fprintf('rrc_output:Error, R and C must be doubles (1x1)\n');
    return
end
if ~isequal(size(t),size(I)) || size(t,1)~=length(t)
    U = [];
    fprintf('rrc_output:Error, t and I must have the same size (nx1)\n');
    return
end

U = I.*Rs;
for ind = 1:length(R)
Urc = rc_output(t,I,R(ind),C(ind));
U = U+Urc;
end
end