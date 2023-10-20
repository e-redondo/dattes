function [Rp, R_I,Rt,RDoD,Rdt,U_sim,err_U,err] = calcul_r(t,U,I,DoDAh,instant_end_rest,duration_pulse,duration_rest,delta_time,graph)
%calcul_r Calculate resistance thanks to profiles t,U and I
%
% Usage
%[Rp, R_I,Rt,RDoD,Rdt,err] = calcul_r(t,U,I,DoDAh,instant_end_rest,duration_pulse,duration_rest,t_calcul_R,graph)
%
% Inputs :
% - t [nx1 double]: datetime in s since 1/1/2000
% - U [nx1 double]: cell voltage in V
% - I [nx1 double]: cell current in A
% - DoDAh [nx1 double]: depth of discharge in Ah
% - instant_end_rest [1x1 double]: Last rest instant before a pulse in s
% - duration_pulse [1x1 double]: Pulse duration to be considered for
% interpolation in s
% - duration_rest [1x1 double]: Rest duration to be considered for
% interpolation  in s
% - t_calcul_R [px1 double]: Intants for R calculation (delta times from
% beggining of the pulse)
% - graph:[char] 'g' to show result
%
%  Outputs
% - Rp [px1 double]: Estimated resistance at the pulse in ohms
% - R_I [px1 double]: Current rate at which resistance has been calculated in C
% - Rt [px1 double]:  Datetime at which resistance has been calculated in s
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

Rp = 0;
R_I = 0;%(crate)
Rt = 0;%(datetime)
RDoD = 0;%(dod)
Rdt = 0;%(delta_time)
err = 0;

if (isempty(t) || isempty(U) || isempty(I))
    fprintf('calcul_r : input arrays empty\n');    
    error('$')
elseif all(I == 0)
    fprintf('calcul_r : current array is zero\n');                  
    error('$')
elseif any(diff(t)<= 0)
    fprintf('calcul_r :  t is not monotonously growing \n');  
    error('$')       
end

 rest = (t<=instant_end_rest & t>=(instant_end_rest - duration_rest)); 
    trest = t(rest);  
    Urest = U(rest); 
    Irest = I(rest);  
    
    if length(trest)<3
        err=-1;
        Rp = nan;
        R_I = nan;
        Rt = nan;
        RDoD = nan;
        Rdt = nan;
        return;
    end
    
    pulse = (t>instant_end_rest);    % on s'interesse a la periode de temps du pulse: (instant_end_rest)<t<=(instant_end_rest + duration_rest)
    tpulse = t(pulse);
    Upulse = U(pulse);
    Ipulse = I(pulse);
    if length(tpulse)<3
        err=-2;
        Rp = nan;
        R_I = nan;
        Rt = nan;
        RDoD = nan;
        Rdt = nan;
        return;
        
    end
    
    if max(t)<instant_end_rest+duration_pulse
        err=-2;
        Rp = nan;
        R_I = nan;
        Rt = nan;
        RDoD = nan;
        Rdt = nan;
        return;
    end
    

        Rp = [];
        R_I = [];
        Rt = [];
        RDoD = [];
        Rdt = [];  
        U_sim = [];
        err_U = [];
        
    for ind = 1:length(delta_time)
        if max(tpulse)-min(tpulse)<delta_time(ind)
            %DEBUG
            %fprintf('Pulse is not long enough, DoD: %.1f Ah, pulse length: %.1f s, R delta time: %.1f s.\n',DoDAh(1),max(tpulse)-min(tpulse), t_calcul_R(ind));
            continue
        else
%             w = abs(tpulse-tpulse(end));                               %poids d'interpolation polynominal pour le pulse, les points loin de l'impulse de courant ont un poids plus eleve
            w = 1./(abs(instant_end_rest-tpulse)+1);
            Ural_pul = fitting_pol2(tpulse,Upulse,instant_end_rest+delta_time(ind),w);%U ralonge pour le pulse, ont extrapole le point a l'instant de l'impulse
%             w = abs(trest-trest(1));
            w = 1./(abs(instant_end_rest-trest)+1);
            Ural_rep = fitting_pol2(trest,Urest,instant_end_rest+delta_time(ind),w);%U ralonge pour le rest,ont extrapole le point a l'instant de l'impulse
            
            R_I(end+1) = mean(Ipulse);                                 %le courant d'estimation de la resistance est la moyenne du courant (filtrer le bruit)
            Rp(end+1) = (Ural_pul-Ural_rep)/R_I(end);                       %la resistance est la difference de potentiel entre le rest et le pulse divise par le courant
%             Rt(end+1) = t(1) + duration_rest;%intant of measurement
            Rt(end+1) = instant_end_rest;%intant of measurement
            RDoD(end+1) = DoDAh(1);
            Rdt(end+1) = delta_time(ind);%delta t
            U_sim(end+1) = Ural_rep+R_I(end)*Rp(end);
            err_U(end+1) = U_sim(end)-U(find(t>=Rt(end) & t<=Rt(end)+1,1));
        end
    end
    
    
       

    if (any(Rp<0) || any(isnan(Rp)))
        fprintf('calcul_r : Error R negative or NAN\n');

    end
    if exist('graph','var')
        if graph
            show_result(t,U,I,instant_end_rest,Ural_pul,Ural_rep,R_I,tpulse,Upulse,trest,Urest,delta_time)
        end
    end

    %DEBUG
    % show_result(t,U,I,instant_end_rest,Ural_pul,Ural_rep,R_I,tpulse,Upulse,trest,Urest,t_calcul_R)

end


function show_result(t,U,I,instant_end_rest,Ural_pul,Ural_rep,R_I,tpulse,Upulse,trest,Urest,t_calcul_R)
figure,
w = abs(tpulse-tpulse(end));  
Ural_pul_syn = fitting_pol2(tpulse,Upulse,tpulse+t_calcul_R,w);%U ralonge pour le pulse
w = abs(trest-trest(1));
Ural_rep_syn = fitting_pol2(trest,Urest,trest+t_calcul_R,w);%U ralonge pour le rest

subplot(211),plot(t-instant_end_rest,U,'.-',0,Ural_pul,'r^',0,Ural_rep,'rs'),hold on
subplot(211),plot(tpulse-instant_end_rest,Ural_pul_syn,'m.-',trest-instant_end_rest+t_calcul_R,Ural_rep_syn,'c.-'),hold on
subplot(212),plot(t-instant_end_rest,I,'.-',0,R_I,'r^'),hold on

subplot(211),xlim([min(trest-instant_end_rest) max(tpulse-instant_end_rest)])
xlabel('Time[s]'), ylabel('Voltage U[V]')
legend('Experimental points U','U extrapolated pulse','U extrapolated rest','projection U pulse','projection U rest');
subplot(212),xlim([min(trest-instant_end_rest) max(tpulse-instant_end_rest)])
xlabel('Time[s]'), ylabel('Current I[A]')
legend(' Measures points I','R_I');
end
