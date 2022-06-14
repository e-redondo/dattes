function [Rp, R_I,Rt,RDoD,Rdt,err] = calcul_r(t,U,I,DoDAh,instant_end_rest,duration_pulse,duration_rest,t_calcul_R,graph)
%calcul_r Calculate resistance thanks to profiles t,U and I
%
% Usage
%[Rp, R_I,Rt,RDoD,Rdt,err] = calcul_r(t,U,I,DoDAh,instant_end_rest,duration_pulse,duration_rest,t_calcul_R,graph)
%
% Inputs :
% - t [nx1 double]: time in s
% - U [nx1 double]: cell voltage in V
% - I [nx1 double]: cell current in A
% - instant_end_rest [double]: Last rest instant before a pulse in s
% - duration_pulse [double]: Pulse duration to be considered for
% interpolation in s
% - duration_rest [double]: Rest duration to be considered for
% interpolation  in s
% - graph:[char] 'g' to show result
%
%  Outputs
% - Rp: Estimated resistance at the pulse in ohms
% - R_I: Current at which resistance has been calculated in A
% - Rt:  Time at which resistance has been calculated in s
% - RDoD :Depth of discharge at which resistance has been calculated in Ah
% - Rdt :  Instant at which resistance is calculated since the beginning of the pulse in s
%
% See also ident_r
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

Rp = 0;
R_I = 0;
Rt = 0;
RDoD = 0;
Rdt = 0;
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

 rest = (t<instant_end_rest & t>=(instant_end_rest - duration_rest)); 
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
        
        
    for ind = 1:length(t_calcul_R)
        if max(tpulse)-min(tpulse)<t_calcul_R(ind)
            continue
        else
            w = abs(tpulse-tpulse(end));                               %poids d'interpolation polynominal pour le pulse, les points loin de l'impulse de courant ont un poids plus eleve
            Ural_pul = fitting_pol2(tpulse,Upulse,instant_end_rest+t_calcul_R(ind),w);%U ralonge pour le pulse, ont extrapole le point a l'instant de l'impulse
            w = abs(trest-trest(1));
            Ural_rep = fitting_pol2(trest,Urest,instant_end_rest+t_calcul_R(ind),w);%U ralonge pour le rest,ont extrapole le point a l'instant de l'impulse
            
            R_I(end+1) = mean(Ipulse);                                 %le courant d'estimation de la resistance est la moyenne du courant (filtrer le bruit)
            Rp(end+1) = (Ural_pul-Ural_rep)/R_I(end);                       %la resistance est la difference de potentiel entre le rest et le pulse divise par le courant
            Rt(end+1) = t(1) + duration_rest;
            RDoD(end+1) = DoDAh(1);
            Rdt(end+1) = t_calcul_R(ind);
        end
    end
    
    
       

    if (any(Rp<0) || any(isnan(Rp)))                              
        fprintf('calcul_r : Error R negative or NAN\n');                

    
    if exist('graph','var')
        if graph
            show_result(t,U,I,instant_end_rest,Ural_pul,Ural_rep,R_I,tpulse,Upulse,trest,Urest,t_calcul_R)
        end
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
