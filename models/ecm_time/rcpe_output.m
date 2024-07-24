function U = rcpe_output(t,I,R,Q,alpha)
% rcpe_output calculate the voltage response of a R+CPE circuit
%
% Usage
% U = rcpe_output(t,I,Q,alpha)
% Inputs
% - t: [nx1 double] time vector in s
% - I: [nx1 double] current vector in A
% - R [1x1 double]: series resistance
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

Uw = cpe_output(t,I,Q,alpha);
U = I.*R+Uw;
end