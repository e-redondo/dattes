function Z = circuit_rrc(Zparams,f)
% function Z = circuit_rrc(Zparams,f)
% Impedance spectrum for the following circuit:
% R + R//C + ... + R//C
%
% Usage: Z = circuit_rrc(Zparams,f)
% - Zparams [1x1 struct] with fields
%     - R (1x1 double): real positive number
%     - RC (mx1 double): real positive number
%     - C (mx1 double): real positive number
% - f (nx1 double): frequences, real positive numbers
% - Z (nx1 double complex): impedance for given parameters and frequencies.
%
% See also circuit_rc, circuit_rrcq, circuit_rrcrq, circuit
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

%0.-check input types and sizes
if nargin<2
    fprintf('ERROR circuit_rrc: not enough inputs\n');
end
if ~isstruct(Zparams) || ~isnumeric(f) || ~isreal(f)
    fprintf('ERROR circuit_rrc: not valid inputs. Zparams must be struct, f real number\n');
end
if length(Zparams)~=1
    fprintf('ERROR circuit_rrc: Zparams must be 1x1 struct\n');    
end
%0.2.-RC, C
if ~all(isfield(Zparams,{'RC','C'}))
    fprintf('ERROR circuit_rrc: not enough parameters in Zparams, needed RC and C\n')
end
%0.3.-f



%series association of R and RC loops
Z = Zparams.R + circuit_rc(Zparams,f);

end