 function U = rc_output(t,I,R,C)
% rc_output calculate the voltage response of a RC circuit
%
% Usage
% U = rc_output(t,I,Rs,R,C)
% Inputs
% - t: [nx1 double] time vector in s
% - I: [nx1 double] current vector in A
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

if ~isnumeric(R) ||  ~isnumeric(C) ||  ~isnumeric(t) ||  ~isnumeric(I) 
    U = [];
    fprintf('rc_output:Error, inputs must be numerical\n');
    return
end
if numel(R) ~= 1 || numel(C) ~= 1 
    U = [];
    fprintf('rc_output:Error, R and C must be doubles (1x1)\n');
    return
end
if ~isequal(size(t),size(I)) || size(t,1)~=length(t)
    U = [];
    fprintf('rc_output:Error, t and I must have the same size (nx1)\n');
    return
end
R = R(1);
C = C(1);


dI = [I(1); diff(I)];
indices = find(dI);

U = zeros(size(t));
for ind = 1:length(indices)
    xe = echelon(t,dI(indices(ind)),t(indices(ind)));
    xtd =(t-t(indices(ind)));xtd(xtd<0)=0;

    U = U+R*xe.*(1-exp(-(xtd)/(R*C)));
    if isnan(U(1))
        fprintf('rc_output : found NAN in U vector \n');
    end
end
end

function x = echelon(t,I,td)
    x = zeros(size(t));
    x(t>=td)=I;
end


