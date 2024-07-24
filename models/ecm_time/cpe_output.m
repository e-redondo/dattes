function U = cpe_output(t,I,Q,alpha)
% cpe_output calculate the voltage response of a CPE circuit
%
% Usage
% U = cpe_output(t,I,Q,alpha)
% Inputs
% - t: [nx1 double] time vector in s
% - I: [nx1 double] current vector in A
% - Q, alpha [1x1 double]: parametres du CPE
%
% Outputs
% - U:[nx1 double] Voltage response of the CPE circuit
%
% Using equation from:
% Lario-García, J. & Pallàs-Areny, R. Constant-phase element identification
% in conductivity sensors using a single square wave Sensors and Actuators
% A: Physical , 2006, 132, 122 - 128,
% http://dx.doi.org/10.1016/j.sna.2006.04.014
% 
% See also  rcpe_output, rrc_output
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.


if ~isnumeric(Q) ||  ~isnumeric(alpha) ||  ~isnumeric(t) ||  ~isnumeric(I) 
    U = [];
    fprintf('cpe_output:ERREUR, toutes les entrees doivent etre numeriques\n');
    return
end
if numel(Q) ~= 1 || numel(alpha) ~= 1 
    U = [];
    fprintf('cpe_output:ERREUR, Q et alpha doivent etre scalaires (1x1)\n');
    return
end
if ~isequal(size(t),size(I)) || size(t,1)~=length(t)
    U = [];
    fprintf('cpe_output:ERREUR; t et I doivent etre vecteurs de la meme taille (nx1)\n');
    return
end
%Q [1x1]
Q = Q(1);
%alpha [1x1]
alpha = alpha(1);


dI = [I(1); diff(I)];
indices = find(dI);

U = zeros(size(t));
for ind = 1:length(indices)
    xe = echelon(t,dI(indices(ind)),t(indices(ind)));
    xtd =(t-t(indices(ind))).^alpha;
    U = U + (1/Q)*xe.*xtd/gamma(alpha+1);
end
end

function x = echelon(t,I,td)
    x = zeros(size(t));
    x(t>=td)=I;
end


function x = ttd_alpha(t,alpha,td)
%t [1xm]
x = (t-td).^alpha;

end
