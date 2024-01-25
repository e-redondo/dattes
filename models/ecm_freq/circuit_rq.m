function Z = circuit_rq(Zparams,f)
% function Z = circuit_rq(Zparams,f)
% Impedance spectrum for R//CPE loops:
% R//Q + ... + R//Q
% Usage: Z = circuit_rq(Zparams,f)
% - Zparams [1x1 struct] with fields
%     - RQ (mx1 double): real positive number
%     - Q (mx1 double): real positive number
%     - a (mx1 double): real number between 0 and 1;
% - f (nx1 double): frequences, real positive numbers
% - Z (nx1 double complex): impedance for given parameters and frequencies.
%
% See also circuit_q, circuit_rrq, circuit_rrcrq, circuit
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

Z = [];
%0.-check input types and sizes
if nargin<2
    fprintf('ERROR circuit_rq: not enough inputs\n');
    return
end
if ~isstruct(Zparams) || ~isnumeric(f) || ~isreal(f)
    fprintf('ERROR circuit_rq: not valid inputs. Zparams must be struct, f real number\n');
    return
end
if length(Zparams)~=1
    fprintf('ERROR circuit_rq: Zparams must be 1x1 struct\n'); 
    return
end
%0.2.-RQ, Q
if ~all(isfield(Zparams,{'RQ','Q'}))
    fprintf('ERROR circuit_rq: not enough parameters in Zparams, needed RC and C\n');
    return
end
%0.3.-f

%extract parameters
RQ = Zparams.RQ;
Q = Zparams.Q;
a = Zparams.a;

w = 2*pi*f;
p = 1i*w;

Z = 0;%initialise value

%for each RC loop
for ind = 1:length(RQ)
    Zr =  RQ(ind)*ones(size(f));
    Zq = 1./(Q(ind)*p.^a(ind));
    Z = Z + 1./(1./Zr+1./Zq);%
end


end