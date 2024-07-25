function [Rp, R_I,R_datetime,RDoD,Rdt,U_sim,err_U,err] = calcul_r(datetime,U,I,DoDAh,datetime_end_rest,duration_rest,delta_time,graph)
%calcul_r Calculate resistance thanks to profiles t,U and I
%
% Usage
%[Rp, R_I,Rt,RDoD,Rdt,err] = calcul_r(t,U,I,DoDAh,instant_end_rest,duration_pulse,duration_rest,delta_time,graph)
%
% Inputs :
% - t [nx1 double]: datetime in s since 1/1/2000
% - U [nx1 double]: cell voltage in V
% - I [nx1 double]: cell current in A
% - DoDAh [nx1 double]: depth of discharge in Ah
% - datetime_end_rest [1x1 double]: Last rest instant before a pulse in s
% - duration_rest [1x1 double]: Rest duration to be considered for
% interpolation  in s
% - graph:[char] 'g' to show result
%
%  Outputs
% - Rp [px1 double]: Estimated resistance at the pulse in ohms
% - R_I [px1 double]: Current pulse at which resistance has been calculated in A
% - R_datetime [px1 double]:  Datetime at which resistance has been calculated in s since 1/1/2000
% - RDoD [px1 double]:Depth of discharge at which resistance has been calculated in Ah
% - Rdt [px1 double] :  Instant at which resistance is calculated since the beginning of
% the pulse in s (delta_time)
% - U_sim [px1 double]: Voltage calculated based on resistance Rp
% - err_U [px1 double]: difference between measured voltage and U_sim
% - err [1x1 double]:  error code
%
% See also ident_r
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab:
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.


Rp = 0; %resistance values
R_I = 0; % pulse c_rates
R_datetime = 0; % datetime
RDoD = 0; % dod
Rdt = 0;  % delta time
% Ural_pul=0; %
U_sim = 0; % simulated voltage with calculated resistance
err_U = 0; % error between voltage simulation and measurement


if (isempty(datetime) || isempty(U) || isempty(I))
    fprintf('calcul_r : input arrays empty\n');
    err = -1;
    return
elseif all(I == 0)
    fprintf('calcul_r : current array is zero\n');
    err = -2;
    return
elseif any(diff(datetime)<= 0)
    fprintf('calcul_r :  t is not monotonously increasing \n');
    err = -3;
    return
end

rest = (datetime<=datetime_end_rest & datetime>=(datetime_end_rest - duration_rest));
trest = datetime(rest);
Urest = U(rest);
Irest = I(rest);



pulse = (datetime>datetime_end_rest);    % on s'interesse a la periode de temps du pulse: (instant_end_rest)<t<=(instant_end_rest + duration_rest)
tpulse = datetime(pulse);
Upulse = U(pulse);
Ipulse = I(pulse);



Rp = []; %resistance values
R_I = []; % pulse c_rates
R_datetime = []; % datetime
RDoD = []; % dod
Rdt = [];  % delta time
Ural_pul=[]; %
U_sim = []; % simulated voltage with calculated resistance
err_U = []; % error between voltage simulation and measurement


for ind = 1:length(delta_time)
    if max(tpulse)-min(tpulse)<delta_time(ind)
        %DEBUG
        %fprintf('Pulse is not long enough, DoD: %.1f Ah, pulse length: %.1f s, R delta time: %.1f s.\n',DoDAh(1),max(tpulse)-min(tpulse), delta_time(ind));
        continue
    else
        %U ralonge pour le rest,ont extrapole le point a l'instant de l'impulse
        % polynomial fit weigthned by distance to end of rest
        w = 1./(abs(datetime_end_rest-trest)+1);
        Ural_rep = fitting_pol2(trest,Urest,datetime_end_rest+delta_time(ind),w);

        if  delta_time(ind) == 0
            Ural_pul(ind) = Upulse(1);
            %                             w2 = 1./(abs(instant_end_rest-tpulse)+1);
            %              Ural_pul = fitting_pol2(tpulse,Upulse,instant_end_rest+delta_time(ind),w2);%U ralonge pour le pulse, ont extrapole le point a l'instant de l'impulse
        else

            %  Upulse is estimated withitn a window
            instant = tpulse(1) + delta_time(ind);          % Instant de calcul de la résistance
            lower_limit = instant - 1.1;                           % Lower limit of the window
            upper_limit = instant + 1.1;                          % Upper Limit of the window
            
            window = tpulse >= lower_limit & tpulse <= upper_limit;
            % Ural_pul (ind) = interp1(tpulse(window), Upulse(window), instant);
            p = polyfit(tpulse(window),Upulse(window),1);
            Ural_pul(ind) = polyval(p,instant);
        end

        R_I(end+1) = mean(Ipulse);                                 %le courant d'estimation de la resistance est la moyenne du courant (filtrer le bruit)
        Rp(end+1) = (Ural_pul(ind)-Ural_rep)/R_I(end);                       %la resistance est la difference de potentiel entre le rest et le pulse divise par le courant
        R_datetime(end+1) = datetime_end_rest;                                                   %instant of measurement
        RDoD(end+1) = DoDAh(1);
        Rdt(end+1) = delta_time(ind);                                           % Delta time
        U_sim(end+1) = Ural_rep+R_I(end)*Rp(end);
        U_meas = U(find(datetime>=R_datetime(end) & datetime<=R_datetime(end)+1,1));
        if isempty(U_meas)
            U_meas = nan;
        end
        err_U(end+1) = U_sim(end)-U_meas;

    end
end

% error codes for each pulse:
% infinite resistance: err = -10
% nan resistance: err = -20
% negative resistance: err = -30
err = zeros(size(Rp))-10*ones(size(Rp)).*isinf(Rp)-20*ones(size(Rp)).*isnan(Rp)-30*ones(size(Rp)).*(Rp<0);

if (any(Rp<0) || any(isnan(Rp)))
    fprintf('calcul_r : Error R negative or NAN\n');

end
if exist('graph','var')
    if graph
        show_result(datetime,U,I,datetime_end_rest,Ural_pul,Ural_rep,R_I,tpulse,Upulse,trest,Urest,delta_time)
    end
end

%DEBUG
% show_result(t,U,I,instant_end_rest,Ural_pul,Ural_rep,R_I,tpulse,Upulse,trest,Urest,delta_time)

end


function show_result(t,U,I,instant_end_rest,Ural_pul,Ural_rep,R_I,tpulse,Upulse,trest,Urest,delta_time)
figure,
w = abs(tpulse-tpulse(end));
Ural_pul_syn = fitting_pol2(tpulse,Upulse,tpulse+delta_time,w);%U ralonge pour le pulse
w = abs(trest-trest(1));
Ural_rep_syn = fitting_pol2(trest,Urest,trest+delta_time,w);%U ralonge pour le rest

subplot(211),plot(t-instant_end_rest,U,'.-',0,Ural_pul,'r^',0,Ural_rep,'rs'),hold on
subplot(211),plot(tpulse-instant_end_rest,Ural_pul_syn,'m.-',trest-instant_end_rest+delta_time,Ural_rep_syn,'c.-'),hold on
subplot(212),plot(t-instant_end_rest,I,'.-',0,R_I,'r^'),hold on

subplot(211),xlim([min(trest-instant_end_rest) max(tpulse-instant_end_rest)])
xlabel('Time[s]'), ylabel('Voltage U[V]')
legend('Experimental points U','U extrapolated pulse','U extrapolated rest','projection U pulse','projection U rest');
subplot(212),xlim([min(trest-instant_end_rest) max(tpulse-instant_end_rest)])
xlabel('Time[s]'), ylabel('Current I[A]')
legend(' Measures points I','R_I');
end
