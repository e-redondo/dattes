function Z = circuit_rc(Zparams,f)
% function Z = circuit_rc(Zparams,f)
% Impedance spectrum for the following circuit:
%  R//C + ... + R//C
%
% Usage: Z = circuit_rc(Zparams,f)
% - Zparams [1x1 struct] with fields
%     - RC (mx1 double): real positive number
%     - C (mx1 double): real positive number
% - f (nx1 double): frequences, real positive numbers
% - Z (nx1 double complex): impedance for given parameters and frequencies.
%
% Z = 1./(1/RC+C*(jw)); % for one RC loop
%
% See also circuit_rrc, circuit_rrcq, circuit_rrcrq, circuit
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

Z = [];
%0.-check input types and sizes
if nargin<2
    fprintf('ERROR circuit_rc: not enough inputs\n');
    return
end
if ~isstruct(Zparams) || ~isnumeric(f) || ~isreal(f)
    fprintf('ERROR circuit_rc: not valid inputs. Zparams must be struct, f real number\n');
    return
end
if length(Zparams)~=1
    fprintf('ERROR circuit_rc: Zparams must be 1x1 struct\n'); 
    return
end
%0.2.-RC, C
if ~all(isfield(Zparams,{'RC','C'}))
    fprintf('ERROR circuit_rc: not enough parameters in Zparams, needed RC and C\n');
    return
end
%0.3.-f

%extract parameters
RC = Zparams.RC;
C = Zparams.C;

if length(RC)~=length(C)
    fprintf('ERROR circuit_rc: not enough parameters in Zparams, needed RC and C\n')
end

w = 2*pi*f;
p = 1i*w;

Z = 0;%initialise value

%for each RC loop
for ind = 1:length(RC)
    Z = Z + 1./(1/RC(ind)+C(ind)*p);
end


end