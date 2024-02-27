function Z = circuit_rl(Zparams,f)
% function Z = circuit_rl(Zparams,f)
% Impedance spectrum for the following circuit:
% R//L + ... + R//L
%
% Usage: Z = circuit_rl(Zparams,f)
% - Zparams [1x1 struct] with fields
%     - R (1x1 double): real positive number
%     - RL (mx1 double): real positive number
%     - L (mx1 double): real positive number
% - f (nx1 double): frequences, real positive numbers
% - Z (nx1 double complex): impedance for given parameters and frequencies.
%
% Z = RL*(jw)); % for one RC loop
%
% See also circuit_rc, circuit
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

Z = [];
%0.-check input types and sizes
if nargin<2
    fprintf('ERROR circuit_rl: not enough inputs\n');
    return
end
if ~isstruct(Zparams) || ~isnumeric(f) || ~isreal(f)
    fprintf('ERROR circuit_rl: not valid inputs. Zparams must be struct, f real number\n');
    return
end
if length(Zparams)~=1
    fprintf('ERROR circuit_rl: Zparams must be 1x1 struct\n');  
    return  
end
%0.2.-RC, C
if ~all(isfield(Zparams,{'RL','L'}))
    fprintf('ERROR circuit_rl: not enough parameters in Zparams, needed RL and L\n');
    return
end
%0.3.-f

w = 2*pi*f;
p = 1i*w;


%extract parameters
RL = Zparams.RL;
L = Zparams.L;

%initialise 
Z = 0;
%for each RL loop
for ind = 1:length(RL)
    Z = Z + 1./(1/RL(ind) + 1./(p*L(ind)));
end



end