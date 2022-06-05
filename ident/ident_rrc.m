 function [impedance]=ident_rrc(t,U,I,dod_ah,config,phases,options)
% ident_rrc impedance analysis of a R+two RC topology
%
% [impedance]=ident_rrc(t,U,I,dod_ah,config,phases,options)
% Read the config and phases structure and performe several calculations
% regarding impedance analysis.  Results are returned in the structure impedance analysis 
%
% Usage:
% [impedance]=ident_rrc(t,U,I,dod_ah,config,phases,options)
% Inputs:
% - t [nx1 double]: time in seconds
% - U [nx1 double]: cell voltage
% - dod_ah [nx1 double]: depth of discharge in AmpHours
% - config [1x1 struct]: config struct from configurator
% - phases [1x1 struct]: phases struct from decompose_phases
% - options [string] containing:
%   - 'v': verbose, tell what you do
%   - 'g' : show figures
%
% Output:
% - impedance [(1x1) struct] with fields:
%     - topology [string]: Impedance model topology
%     - r0 [kx1 double]: Ohmic resistance
%     - r1 [kx1 double]: R1 resistance
%     - C1 [kx1 double]: C1 capacity
%     - r2 [kx1 double]: R2 resistance
%     - C2 [kx1 double]: C2 capacity
%     - crate [kx1 double]: C-Rate of each impedance measurement
%     - dod [kx1 double]: Depth of discharge of each impedance measurement
%     - time [kx1 double]: time of each impedance measurement
%
%See also dattes, calcul_soc, configurator, extract_profiles
%
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

%% check inputs:

if ~exist('options','var')
    options = '';
end
if ismember('v',options)
    fprintf('ident_rrc:...');
end

if nargin<6 || nargin>8
    fprintf('ident_rrc : wrong number of parameters, found %d\n',nargin);
    return;
end
if ~isstruct(config) || ~ischar(options) || ~isnumeric(t) || ~isstruct(phases)   || ~isnumeric(U) || ~isnumeric(I) || ~isnumeric(dod_ah)
    fprintf('ident_rrc: wrong type of parameters\n');
    return;
end
if ~isfield(config,'impedance')
    fprintf('ident_rrc: incomplete structure config, redo configurator: dattes(''cs'')\n');
    return;
end    
if ~isfield(config.impedance,'initial_params') || ~isfield(config.impedance,'pulse_max_duration')
    fprintf('ident_rrc: incomplete structure config, redo configurator: dattes(''cs'')\n');
    return;
end

%% 1- Initialization
impedance=struct([]);

r0=[];
r1=[];
c1=[];
r2=[];
c2=[];
rrc_time = [];
rrc_dod = [];
rrc_crate = [];


%% 2- Determine the phases for which a RC identification is relevant

indice_r = find(config.impedance.pZ);
rest_duration_before_pulse=config.impedance.rest_min_duration;
rest_before_after_phase = [rest_duration_before_pulse 0];
phases_identify_rc=phases(config.impedance.pZ);

%% 3 - r0,C0,r1,c1 and r2,c2 are computed for each of these phases
for phase_k = 1:length(indice_r)
        %Time, voltage,current and DoD are extracted for the phase_k
    [time_phase,voltage_phase,current_phase,dod_phase] = extract_phase2(phases_identify_rc(phase_k),rest_before_after_phase,t,U,I,dod_ah);
    for i=1:length(dod_phase)
        if dod_phase(i)<0
            dod_phase(i)=abs(dod_phase(i));
        end
    end
 
    rrc_time(phase_k) = time_phase(1);
    rrc_dod(phase_k) = dod_phase(1);
    rrc_crate(phase_k) = phases_identify_rc(phase_k).Iavg/config.test.capacity;   
    [R10,C10,R20,C20,tau2]=define_RCini(time_phase,config);

    % Step time is reduced to maximize the identification accuracy
    time_step = 0.1;
    tmi = (time_phase(1):time_step:time_phase(end))';
    voltage_phase = interp1(time_phase,voltage_phase,tmi);
    current_phase = interp1(time_phase,current_phase,tmi);
    time_phase = tmi;

%Relaxation voltage is extracted
ocv = voltage_phase(1);
voltage_phase  = voltage_phase-ocv;

%% Rs and first RC are identified as a whole
time_phase = time_phase-time_phase(1);

tm1 = time_phase(time_phase<rest_duration_before_pulse+tau2);
Im1 = current_phase(time_phase<rest_duration_before_pulse+tau2);
Umrc1 = voltage_phase(time_phase<rest_duration_before_pulse+tau2);

[Rsid,R1id, C1id] = calcul_rrc(tm1,Umrc1,Im1,'c',R10,R10,C10);

r0=[r0 Rsid];
r1=[r1 R1id];
c1=[c1 C1id];



Us_rsr1c1 = reponseRRC(time_phase,current_phase,Rsid,R1id,C1id);

%residual voltage used for R2C2 identification
Umrc2 = voltage_phase-Us_rsr1c1;



%% R2C2 is identified thanks to the residual voltage
  [R2id, C2id] = calcul_rc(time_phase,Umrc2,current_phase,'c',R20,C20);
r2=[r2 R2id];
c2=[c2 C2id];



Usr2c2 = rc_output(time_phase,current_phase,R2id,C2id);
 
 Usimu = Us_rsr1c1+Usr2c2;

     
    err_qua=1000*abs(Usimu-voltage_phase).^2;
    err_abs=1000*abs(Usimu-voltage_phase);
    
    if ismember('g',options) 
        x=rand;
        if x<0.1
          phase_number=indice_r(phase_k);

            figure
            subplot(311),          
            plot(time_phase,voltage_phase,'.-',time_phase,Usimu,'r.-'),ylabel('Voltage (V)')
            legend('measure','simulation')
              title(['Simulation versus measurement for phase ',num2str(phase_number)])

            subplot(312),plot(time_phase,err_qua,'g.'),ylabel('Quadratic error (mV²)')
            legend(sprintf('Mean value quadratic error: %e',mean(err_qua)),'location','best')
        title(['Quadratic error evolution for phase ',num2str(phase_number)])

            subplot(313),plot(time_phase,err_abs,'g.'),ylabel('Absolute error (mV)')
            legend(sprintf('Mean value absolute error: %e',mean(err_abs)),'location','best')
              title(['Absolute error evolution for phase ',num2str(phase_number)])

         end
    end
    

end
   if ismember('v',options)
        fprintf('OK\n');
   end
   
  impedance(1).topology = 'R0 + R1C1 + R2C2';
  impedance.r0=r0;
  impedance.r1=r1;
  impedance.c1=c1;
  impedance.r2=r2;
  impedance.c2=c2;
  impedance.time = rrc_time;
  impedance.dod = rrc_dod;
  impedance.crate = rrc_crate;

end


function [R, C, err] = identificationRC(time_phase,voltage_phase,current_phase,options,r0,C0,Rmin,Rmax,Cmin,Cmax)
% function [R, C, err] = identificationRC(time_phase,voltage_phase,current_phase,options,r0,C0)
%
%identificationRC determine the R and C parameters thanks to t,U and I
%arrays
% time_phase [nx1 double]: time measurement array
% voltage_phase [nx1 double]: voltage measurement array
% current_phase [nx1 double]: current measurement array
% options [string]: options d'execution:
%       if options contains 'g': grafic mode, show results
%       if options contains 'c': 'C fixed', C is fixed as C=C0
% r0 [1x1 double]: R initial value
% C0 [1x1 double]: C initial value
%
% See also  reponseRC

if ~exist('options','var')
    options='';
end
if ~exist('r0','var')
    r0=1e-3;
end
if ~exist('C0','var')
    C0=100;
end

if ~contains(strfind(options, 'c'))
    %identification des deux parametres (R et C)
    monCaller = @(x) errorRC(x(1),x(2),time_phase,voltage_phase,current_phase);
    x0 = [r0; C0];
else
    %identification d'un parametre (C fixe)
    C = C0;%C fixe
    monCaller = @(x) errorRC(x,C,time_phase,voltage_phase,current_phase);
    x0 = [r0];
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

Us = reponseRC(time_phase,current_phase,R,C);
Is = current_phase;
ts = time_phase;
err = mean(Quadraticerror(voltage_phase,Us));

if ~isempty(strfind(options, 'g'))
    showResult(time_phase,current_phase,voltage_phase,ts,Is,Us,err);
end

end


function erreur = errorRC(R,C,time_phase,voltage_phase,current_phase)
%erreur = errorRC(Q,alpha,time_phase,voltage_phase,current_phase)
%erreurCPE simulate a RC circuit and compare the result to measurement  
% -R,C [1x1 double]: RC circuit parameters 
% -time_phase,voltage_phase,current_phase [nx1 double]:  time, voltages, current (measured) arrays
%

if ~isnumeric(R) ||  ~isnumeric(C) ||  ~isnumeric(time_phase) ||  ~isnumeric(voltage_phase) ||  ~isnumeric(current_phase)
    erreur = [];
    fprintf('errorRC:ERROR, inputs must be numerical\n');
    return
end
if numel(R) ~= 1 || numel(C) ~= 1
    erreur = [];
    fprintf('errorRC:ERROR, R et C must be scalars (1x1)\n');
    return
end
if ~isequal(size(time_phase),size(voltage_phase)) || ~isequal(size(time_phase),size(current_phase)) || size(time_phase,1)~=length(time_phase)
    erreur = [];
    fprintf('errorRC:ERROR, time_phase,voltage_phase and current_phase must have same sizes (nx1)\n');
    return
end


U = reponseRC(time_phase,current_phase,R,C);
U = U(:);
voltage_phase = voltage_phase(:);

erreur = mean(Quadraticerror(voltage_phase,U));


end

function err_qua = Quadraticerror(voltage_phase,Us)
err_qua = abs(Us-voltage_phase).^2;
end

function showResult(time_phase,current_phase,voltage_phase,ts,Is,Us,err)
figure,
subplot(211),plot(time_phase,current_phase,'.-',ts,Is,'r.-'),ylabel('courant (A)')
subplot(212),plot(time_phase,voltage_phase,'.-',ts,Us,'r.-',time_phase,Us-voltage_phase,'g.'),ylabel('tension (V)')
legend('mesure','simu',sprintf('erreur quadratique: %f',err),'location','best')
end

function [R1ini,C1ini,R2ini,C2ini,tau2ini]=define_RCini(time_phase,config)
%[R1ini,C1ini,R2ini,C2ini]=define_RCini(time_phase)
% define_RCini defines the Ri and Ci initial values to maximize the
% identification accuracy made by ident_RC
% input :
% - time_phase :double, time array contains the instants of the pulse
% output :
% -R1ini,C1ini,R2ini,C2ini : double, are the optimal Ri and Ci values
% see also : ident_RC, calculRC,calculRRC

%% 0- Input check

if  ~isnumeric(time_phase) 
    fprintf('define_RCini: time_phase is not a numeric array\n');
    return;
end
duration_pulse=time_phase(end)-time_phase(1);

tau1ini=duration_pulse/2;
tau2ini=duration_pulse;

R1ini=config.impedance.initial_params(1);
R2ini=config.impedance.initial_params(3);

C1ini=tau1ini/R1ini;
C2ini=tau2ini/R2ini;

end



