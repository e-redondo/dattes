function U = response_rcpe_pulse(R,Q,alpha,Ip,td,tf,t)
%response_cpe_pulse simule la reponse d'un R+CPE a un pulse de  courant constant.
%
% U = response_rcpe_pulse(R,Q,alpha,Ip,td,tf,t)
% -R,Q,alpha [1x1 double]: parametres du R+CPE
% -Ip, td, tf [1x1 double]: parametres du pulse
% -tm,Um [nx1 double]: vecteurs temps et tension (mesures)
%
% Utilise l'expression donne dans:
% Lario-García, J. & Pallàs-Areny, R. Constant-phase element identification
% in conductivity sensors using a single square wave Sensors and Actuators
% A: Physical , 2006, 132, 122 - 128,
% http://dx.doi.org/10.1016/j.sna.2006.04.014
% 
if ~isnumeric(R) ||  ~isnumeric(Q) ||  ~isnumeric(alpha) ||...
        ~isnumeric(Ip) ||  ~isnumeric(td) ||  ~isnumeric(tf) ||...
        ~isnumeric(t)
    U = [];
    fprintf('response_rcpe_pulse: ERROR, all inputs must be numeric\n');
    return
end
if numel(R) ~= 1 || numel(Q) ~= 1 || numel(alpha) ~= 1
    U = [];
    fprintf('response_rcpe_pulse:ERROR, Q and alpha must be scalars (1x1)\n');
    return
end
if numel(Ip) ~= 1 || numel(td) ~= 1 || numel(tf) ~= 1 
    U = [];
    fprintf('response_rcpe_pulse:ERROR, Ip, td and tf must be scalars (1x1)\n');
    return
end
if size(t,1)~=length(t)
    U = [];
    fprintf('response_rcpe_pulse:ERROR; t must be a vector (nx1)\n');
    return
end

Utd = echelon(t,td).*(t-td).^alpha/gamma(alpha+1);
Utf = echelon(t,tf).*(t-tf).^alpha/gamma(alpha+1);
Ur = R*Ip*(echelon(t,td)-echelon(t,tf));
U = (Ip/Q)*(Utd-Utf)+Ur;
end

function x = echelon(t,td)
    x = zeros(size(t));
    x(t>=td)=1;
end
