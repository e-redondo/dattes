function Z = circuit(Zparams,f,topology)
% function Z = circuit(Zparams,f,topology)
% Impedance spectrum for different circuits.
% R + R//L + R//C + ... + R//C + Q
%
% Usage: Z = circuit_rrcrq(Zparams,f)
% - Zparams [1x1 struct] with fields
%     - R (1x1 double): real positive number, series resistance
%     - RL (1x1 double): real positive number, inductance resistor
%     - L (1x1 double): real positive number, inductance
%     - RC (mx1 double): real positive number, m_th capacitor resistor
%     - C (mx1 double): real positive number, m_th capacitor
%     - RQ (px1 double): real positive number, CPE paramater
%     - Q (px1 double): real positive number, CPE paramater
%     - a (px1 double): real number between 0 and 1, CPE parameter
% - f (nx1 double): frequences, real positive numbers
% - Z (nx1 double complex): impedance for given parameters and frequencies.
%
%
% See also circuit_randles, circuit_debey ,circuit_rrcq, circuit_rrcrqq
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

switch topology
    case 'randles'
        Z = circuit_randles(Zparams,f);
    case 'debye'
        Z = circuit_debey(Zparams,f);
    case 'rrc'
        Z = circuit_rrc(Zparams,f);
    case 'rrcq'
        Z = circuit_rrcq(Zparams,f);
    case 'rrq'
        Z = circuit_rrq(Zparams,f);
    case 'rrcrq'
        Z = circuit_rrcrq(Zparams,f);
    otherwise
        fprintf('ERROR circuit: unknown topology: %s',topology);
        Z = [];
end

end
