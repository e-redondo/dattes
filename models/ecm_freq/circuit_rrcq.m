function Z = circuit_rrcq(Zparams,f)
% function Z = circuit_rrcq(Zparams,f)
% Impedance spectrum for the following circuit:
% R + R//L + R//C + ... + R//C + Q + ... + Q
%
% Usage: Z = circuit_rrcrq(Zparams,f)
% - Zparams [1x1 struct] with fields
%     - R (1x1 double): real positive number, series resistance
%     - RL (1x1 double): real positive number, inductance resistor
%     - L (1x1 double): real positive number, inductance
%     - RC (mx1 double): real positive number, m_th capacitor resistor
%     - C (mx1 double): real positive number, m_th capacitor
%     - Q (px1 double): real positive number, CPE paramater
%     - a (px1 double): real number between 0 and 1, CPE parameter
% - f (nx1 double): frequences, real positive numbers
% - Z (nx1 double complex): impedance for given parameters and frequencies.
%
% See also circuit_rrc, circuit_rrcrq, circuit
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

Z = [];
%0.-check input types and sizes
if nargin<2
    fprintf('ERROR circuit_rrcrq: not enough inputs\n');
    return
end
if ~isstruct(Zparams) || ~isnumeric(f) || ~isreal(f)
    fprintf('ERROR circuit_rrcrq: not valid inputs. Zparams must be struct, f real number\n');
    return
end
if length(Zparams)~=1
    fprintf('ERROR circuit_rrcrq: Zparams must be 1x1 struct\n');
    return
end


% compute impedance if given parameters, set defaults for not given:
if isfield(Zparams,'R')
    ZR = Zparams.R;
else
    ZR = 0;
end
if all(isfield(Zparams,{'RL','L'}))
    ZL = circuit_rl(Zparams,f);% R//L
else
    ZL = 0;
end
if all(isfield(Zparams,{'C','RC'}))
    ZRC = circuit_rc(Zparams,f);%RC loops (several R//C are possible)
else
    ZRC = 0;
end
if all(isfield(Zparams,{'Q','a'}))
    ZQ = circuit_q(Zparams,f);%CPE
else
    ZQ = 0;
end
%0.3.-f




%series association of preceding elements:
Z = ZR+ZL+ZRC+ZQ;

end