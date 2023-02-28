function [R, Ip] = calcul_r0(t,U,I,rest_time_before, pulse_time, options)
%calcul_r0 Calculate series resistance thanks to profiles t,U and I
%
% Usage
%[R, Ip] = calcul_r0(t,U,I,rest_time_before, pulse_time, options)
%
% Inputs :
% - t [nx1 double]: time in s
% - U [nx1 double]: cell voltage in V
% - I [nx1 double]: cell current in A
% - rest_time_before [double]: seconds before pulse to take into account
% - pulse_time [double]: seconds after pulse start to take into account
% - options [char]:
%    - 'p': prolong pulse to rest end (t0 = max(t_rest))
%           (default): prolong rest to pulse (t0 = min(t_pulse))
%    - 'g': graphics, plot results
%
%  Outputs
% - R: Estimated resistance at the pulse in ohms
% - Ip: Current pulse amplitude (mean of current during pulse_time)
%
% See also calcul_r, calcul_rcpe_pulse
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.
if ~exist('options','var')
    options = '';%default: extend rest, not pulse
end
graphics = ismember('g',options);

%find pulse start:
didt = [0;diff(I)./diff(t)];
[~, ind_p] = max(abs(didt));
t_p = t(ind_p);

ind_rest = t<t_p & t>=t_p-rest_time_before;
ind_pulse = t>=t_p & t <=t_p+pulse_time;


t_rest = t(ind_rest);
I_rest = I(ind_rest);
U_rest = U(ind_rest);

t_pulse = t(ind_pulse);
I_pulse = I(ind_pulse);
U_pulse = U(ind_pulse);

%option 1: prolong rest, consider pulse starts at first measured I
if ~ismember('p',options)

    t_pulse_extended = t_pulse;
    t_rest_extended = [t_rest;t_p];

else

    %option2: prolong pulse, consider pulse start at last rest point
    t_p = t_rest(end);
    t_pulse_extended =  [t_p; t_pulse];
    t_rest_extended = t_rest;


end

w = 1./(abs(t_p-t_pulse)*3+1);
U_pulse_extended = fitting_pol2(t_pulse,U_pulse,t_pulse_extended,w);

%intepr1 spline not better, noisy signals make it very unstable
% U_pulse_extended = interp1(t_pulse,U_pulse,t_pulse_extended,"spline","extrap");
%high order polynomials are not better
% p = polyfit(t_pulse,U_pulse,6);
% U_pulse_extended = polyval(p,t_pulse_extended);

w = 1./(abs(t_p-t_rest)*3+1);
U_rest_extended = fitting_pol2(t_rest,U_rest,t_rest_extended,w);
%intepr1 spline not better, noisy signals make it very unstable
% U_rest_extended = interp1(t_rest,U_rest,t_rest_extended,"spline","extrap");

delta_U = U_pulse_extended(1)-U_rest_extended(end);

Ip = mean(I_pulse);
R = delta_U*Ip;

if graphics

    figure;
    subplot(211),plot(t,I,'b'),hold on
    plot(t_rest,I_rest,'g--')
    plot(t_pulse,I_pulse,'r--')

    subplot(212),plot(t,U),hold on
    plot(t_rest,U_rest,'g--')
    plot(t_pulse,U_pulse,'r--')
    plot(t_rest_extended,U_rest_extended,'go')
    plot(t_pulse_extended,U_pulse_extended,'ro')

    plot([t_p t_p],[U_rest_extended(end) U_pulse_extended(1)],'m-.')

end
end

