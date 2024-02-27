function Z = circuit_q(Zparams,f)
% function Z = circuit_q(Zparams,f)
% Impedance spectrum for CPE (constant phase element) in series:
% Q + Q + ... + Q
%
% Usage: Z = circuit_q(Zparams,f)
% - Zparams [1x1 struct] with fields
%     - Q (px1 double): real positive number
%     - a (px1 double): real number between 0 and 1;
% - f (nx1 double): frequences, real positive numbers
% - Z (nx1 double complex): impedance for given parameters and frequencies.
%
% For each CPE element:
% Z = 1./(Q*(jw).^a);
%
% See also circuit_rq, circuit_rrq, circuit_rcq, circuit_rrcrq, circuit
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

Z = [];
%0.-check input types and sizes
if nargin<2
    fprintf('ERROR circuit_q: not enough inputs\n');
    return
end
if ~isstruct(Zparams) || ~isnumeric(f) || ~isreal(f)
    fprintf('ERROR circuit_q: not valid inputs. Zparams must be struct, f real number\n');
    return
end
if length(Zparams)~=1
    fprintf('ERROR circuit_q: Zparams must be 1x1 struct\n'); 
    return   
end
%0.2.-Q, a
if ~all(isfield(Zparams,{'Q','a'}))
    fprintf('ERROR circuit_q: not enough parameters in Zparams, needed Q and a\n');
    return
end
%0.3.-f

%extract parameters
Q = Zparams.Q;
a = Zparams.a;

%compute impedance for given parameters and frequencies
w = 2*pi*f;
p = 1i*w;


Z = 0;%initialise value

%for each Q,a value
for ind = 1:length(Q)
    Z = Z + 1./(Q(ind)*p.^a(ind));
end


end