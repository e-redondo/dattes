 function [impedance]=ident_rrc(t,U,I,DoDAh,config,phases,options)
%ident_rrc R+RC identification from a profile t,U,I,m
%t,U,I from extract_bench
%DoDAh from calcul_soc, depth of discharge in Amphours
%config from configurator
%
%See also dattes, calcul_soc, configurator, extract_bench
%%%
%% 0- Inputs management

if ~exist('options','var')
    options = '';
end
if ismember('v',options)
    fprintf('ident_rrc:...');
end

if nargin<6 || nargin>8
    fprintf('ident_rrc: 7 inputs arguments are expected, found : %d\n',nargin);
    return;
end
if ~isstruct(config) || ~ischar(options) || ~isnumeric(t) || ~isstruct(phases)   || ~isnumeric(U) || ~isnumeric(I) || ~isnumeric(DoDAh)
    fprintf('ident_rrc:input class is not correct\n');
    return;
end
if ~isfield(config,'R1ini') || ~isfield(config,'R2ini') || ~isfield(config,'maximal_duration_pulse_measurement_R')
    fprintf('ident_rrc: configuration structure is not complete\n R1ini, R2ini and maximal_duration_pulse_measurement_R are expected ');
    return;
end

%% 1- Initialization

R0=[];
R1=[];
C1=[];
R1C1t=[];
R1C1DoD=[];
R1C1Regime=[];

R2=[];
C2=[];
R2C2t=[];
R2C2DoD=[];
R2C2Regime=[];


%% 2- Determine the phases for which a RC identification is relevant

ind_R = find(config.pRC);
rest_duration_before_pulse=config.rest_duration_before_pulse;
rest_before_after_phase = [rest_duration_before_pulse 0];
phases_identify_RC=phases(config.pRC);

%% 3 - R0,C0,R1,C1 and R2,C2 are computed for each of these phases
for phase_k = 1:length(ind_R)
        %Time, voltage,current and DoD are extracted for the phase_k
    [tm,Um,Im,DoDm] = get_phase2(phases_identify_RC(phase_k),rest_before_after_phase,t,U,I,DoDAh);
    for i=1:length(DoDm)
        if DoDm(i)<0
            DoDm(i)=abs(DoDm(i));
        end
    end
    
[R10,C10,R20,C20,tau2]=define_RCini(tm,config);

% Step time is reduced to maximize the identification accuracy
Ts = 0.1;
tmi = (tm(1):Ts:tm(end))';
Um = interp1(tm,Um,tmi);
Im = interp1(tm,Im,tmi);
tm = tmi;

%Relaxation voltage is extracted
OCV = Um(1);
Um  = Um-OCV;

%% Rs and first RC are identified as a whole
tm = tm-tm(1);

tm1 = tm(tm<rest_duration_before_pulse+tau2);
Im1 = Im(tm<rest_duration_before_pulse+tau2);
Umrc1 = Um(tm<rest_duration_before_pulse+tau2);

[Rsid,R1id, C1id] = calcul_rrc(tm1,Umrc1,Im1,'c',R10,R10,C10);

R0=[R0 Rsid];
R1=[R1 R1id];
C1=[C1 C1id];

R1C1t=[R1C1t tm1(1)];
R1C1DoD=[R1C1DoD DoDm(1)];
R1C1Regime=[R1C1Regime max(abs(Im1))];

Us_rsr1c1 = reponseRRC(tm,Im,Rsid,R1id,C1id);

%residual voltage used for R2C2 identification
Umrc2 = Um-Us_rsr1c1;



%% R2C2 is identified thanks to the residual voltage
  [R2id, C2id] = calcul_rc(tm,Umrc2,Im,'c',R20,C20);
R2=[R2 R2id];
C2=[C2 C2id];

R2C2t=[R2C2t tm(1)];
R2C2DoD=[R2C2DoD DoDm(1)];
R2C2Regime=[R2C2Regime max(abs(Im))];

Usr2c2 = rc_output(tm,Im,R2id,C2id);
 
 Usimu = Us_rsr1c1+Usr2c2;

     
    err_qua=1000*abs(Usimu-Um).^2;
    err_abs=1000*abs(Usimu-Um);
    
    if ismember('g',options) 
        x=rand;
        if x<0.1
          phase_number=ind_R(phase_k);

            figure
            subplot(311),          
            plot(tm,Um,'.-',tm,Usimu,'r.-'),ylabel('Voltage (V)')
            legend('measure','simulation')
              title(['Simulation versus measurement for phase ',num2str(phase_number)])

            subplot(312),plot(tm,err_qua,'g.'),ylabel('Quadratic error (mV²)')
            legend(sprintf('Mean value quadratic error: %e',mean(err_qua)),'location','best')
        title(['Quadratic error evolution for phase ',num2str(phase_number)])

            subplot(313),plot(tm,err_abs,'g.'),ylabel('Absolute error (mV)')
            legend(sprintf('Mean value absolute error: %e',mean(err_abs)),'location','best')
              title(['Absolute error evolution for phase ',num2str(phase_number)])

         end
    end
    

end
   if ismember('v',options)
        fprintf('OK\n');
   end
   
  impedance.R0=R0;
  impedance.R1=R1;
  impedance.C1=C1;
  impedance.R1C1t=R1C1t;
  impedance.R1C1DoD=R1C1DoD;
  impedance.R1C1Regime=R1C1Regime;
  impedance.R2=R2;
  impedance.C2=C2;
  impedance.R2C2t=R2C2t;
  impedance.R2C2DoD=R2C2DoD;
  impedance.R2C2Regime=R2C2Regime;
   
end


function [R, C, err] = identificationRC(tm,Um,Im,options,R0,C0,Rmin,Rmax,Cmin,Cmax)
% function [R, C, err] = identificationRC(tm,Um,Im,options,R0,C0)
%
%identificationRC determine the R and C parameters thanks to t,U and I
%arrays
% tm [nx1 double]: time measurement array
% Um [nx1 double]: voltage measurement array
% Im [nx1 double]: current measurement array
% options [string]: options d'execution:
%       if options contains 'g': grafic mode, show results
%       if options contains 'c': 'C fixed', C is fixed as C=C0
% R0 [1x1 double]: R initial value
% C0 [1x1 double]: C initial value
%
% See also  reponseRC

if ~exist('options','var')
    options='';
end
if ~exist('R0','var')
    R0=1e-3;
end
if ~exist('C0','var')
    C0=100;
end

if ~contains(strfind(options, 'c'))
    %identification des deux parametres (R et C)
    monCaller = @(x) errorRC(x(1),x(2),tm,Um,Im);
    x0 = [R0; C0];
else
    %identification d'un parametre (C fixe)
    C = C0;%C fixe
    monCaller = @(x) errorRC(x,C,tm,Um,Im);
    x0 = [R0];
end
%recherche du minimum
% [x,fval,exitflag,output] = fminsearch(monCaller,x0);

if ~isnan(monCaller(x0))
    
    A = [];
    b = [];
    Aeq = [];
    beq = [];
    
    
    lb=[Rmin Cmin];
    ub=[Rmax Cmax];
    optim_options = optimoptions('fmincon','Algorithm','interior-point','Display','off');
    
    [x,fval,exitflag,output] = fmincon(monCaller,x0,A,b,Aeq,beq,lb,ub,[],optim_options);
    
else
    
    R = nan;
    C = nan;
    err = nan;
    return
end



if exitflag<1
    R = nan;
    C = nan;
    err = nan;
    return
end

R = x(1);

if isempty(strfind(options, 'a'))%si deux parametres
    C = x(2);
end

Us = reponseRC(tm,Im,R,C);
Is = Im;
ts = tm;
err = mean(Quadraticerror(Um,Us));

if ~isempty(strfind(options, 'g'))
    showResult(tm,Im,Um,ts,Is,Us,err);
end

end


function erreur = errorRC(R,C,tm,Um,Im)
%erreur = errorRC(Q,alpha,tm,Um,Im)
%erreurCPE simulate a RC circuit and compare the result to measurement  
% -R,C [1x1 double]: RC circuit parameters 
% -tm,Um,Im [nx1 double]:  time, voltages, current (measured) arrays
%

if ~isnumeric(R) ||  ~isnumeric(C) ||  ~isnumeric(tm) ||  ~isnumeric(Um) ||  ~isnumeric(Im)
    erreur = [];
    fprintf('errorRC:ERROR, inputs must be numerical\n');
    return
end
if numel(R) ~= 1 || numel(C) ~= 1
    erreur = [];
    fprintf('errorRC:ERROR, R et C must be scalars (1x1)\n');
    return
end
if ~isequal(size(tm),size(Um)) || ~isequal(size(tm),size(Im)) || size(tm,1)~=length(tm)
    erreur = [];
    fprintf('errorRC:ERROR, tm,Um and Im must have same sizes (nx1)\n');
    return
end


U = reponseRC(tm,Im,R,C);
U = U(:);
Um = Um(:);

erreur = mean(Quadraticerror(Um,U));


end

function err_qua = Quadraticerror(Um,Us)
err_qua = abs(Us-Um).^2;
end

function showResult(tm,Im,Um,ts,Is,Us,err)
figure,
subplot(211),plot(tm,Im,'.-',ts,Is,'r.-'),ylabel('courant (A)')
subplot(212),plot(tm,Um,'.-',ts,Us,'r.-',tm,Us-Um,'g.'),ylabel('tension (V)')
legend('mesure','simu',sprintf('erreur quadratique: %f',err),'location','best')
end

function [R1ini,C1ini,R2ini,C2ini,tau2ini]=define_RCini(tm,config)
%[R1ini,C1ini,R2ini,C2ini]=define_RCini(tm)
% define_RCini defines the Ri and Ci initial values to maximize the
% identification accuracy made by ident_RC
% input :
% - tm :double, time array contains the instants of the pulse
% output :
% -R1ini,C1ini,R2ini,C2ini : double, are the optimal Ri and Ci values
% see also : ident_RC, calculRC,calculRRC

%% 0- Input check

if  ~isnumeric(tm) 
    fprintf('define_RCini: tm is not a numeric array\n');
    return;
end
duration_pulse=tm(end)-tm(1);

tau1ini=duration_pulse/2;
tau2ini=duration_pulse;

R1ini=config.R1ini;
R2ini=config.R2ini;

C1ini=tau1ini/R1ini;
C2ini=tau2ini/R2ini;

end



