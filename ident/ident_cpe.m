function [impedance] = ident_cpe(t,U,I,DoDAh,config,phases,options)
%ident_cpe CPE (Constant phase element) impedance identification from a
% temporal profile (t,U,I,m).
%
% Usage:
% [CPEQ, CPEalpha, CPER, CPEDoD, CPERegime] = ident_cpe(t,U,I,DoDAh,config,options)
% - t,U,I,DoDAh (nx1 double) from extract_bench
% - DoDAh (nx1 double) from calcul_soc
% - config (1x1 struct) from configurator
% - options (string)
%   - 'v': verbose, tell what you do
%
% See also calcul_cpe_pulse, dattes
if ~exist('options','var')
    options = '';
end
if ismember('v',options)
    fprintf('ident_cpe:...');
end

%% 0- Inputs management

if nargin<6 || nargin>8
    fprintf('ident_cpe: wrong number of parameters, found %d\n',nargin);
    return;
end
if ~isstruct(config) || ~ischar(options) || ~isnumeric(t) || ~isstruct(phases)   || ~isnumeric(U) || ~isnumeric(I) || ~isnumeric(DoDAh)
    fprintf('ident_cpe: wrong type of parametres\n');
    return;
end
if ~isfield(config,'tW') || ~isfield(config,'tminWr') || ~isfield(config,'tminW')
    fprintf('ident_cpe: config struct incomplete\n');
    return;
end
%% 1- Initialization
impedance=struct;
CPEQ = [];
CPEalpha = [];
CPER = [];
CPEDoD = [];
CPERegime = [];

%% 2- Determine the phases for which a CPE identification is relevant
ind_CPE = find(config.pCPE);
time_before_after_phase = [config.rest_duration_before_pulse 0];
% phases_identify_CPE=phases(config.pCPE);


%% 3-CPEQ and CPEalpha are identified for each of these phases
for phase_k = 1:length(ind_CPE)
    [tp,Up,Ip,DoDp] = get_phase2(phases(ind_CPE(phase_k)),time_before_after_phase,t,U,I,DoDAh);
%     for i=1:length(DoDp)
%         if DoDp(i)<0
%             DoDp(i)=abs(DoDp(i));
%         end
%     end

        
    
    %Ohmic polarization is extracted
    [R, RRegime] = calcul_r(tp,Up,Ip,DoDp,config.instant_end_rest(phase_k),config.minimal_duration_pulse,config.minimal_duration_rest_before_pulse ,config.instant_calcul_R);
    Ur = zeros(size(Up));
    Ur = Ip*R(1);
    Up = Up-Ur;
    
       %Relaxation voltage is extracted
    OCV = Up(1);
    Up  = Up-OCV; 
    %TODO: comment transmettre 'g' a calculCPE? il genere beaucoup de
    %figures!!
    if ~config.CPEafixe
        [CPEQ(phase_k), CPEalpha(phase_k), ~, CPERegime(phase_k)] = calcul_cpe_pulse(tp,Up,Ip);
    else
        [CPEQ(phase_k), CPEalpha(phase_k), ~, CPERegime(phase_k)] = calcul_cpe_pulse(tp,Up,Ip,'a',config.CPEafixe);
    end
    CPEt(phase_k) = t(t==config.tW(phase_k));
    CPEDoD(phase_k) = DoDAh(t==config.tW(phase_k));%TODO: DoD ini ou moyen?
    CPER(phase_k) = R(1);
end
CPERegime = CPERegime/config.Capa;

if ismember('v',options)
    fprintf('OK\n');
end


if ismember('g',options)
    show_result(t,U,I,DoDAh,CPEQ, CPEalpha, CPEDoD, CPERegime,CPEt);
end

    
impedance.CPEQ = CPEQ;
impedance.CPEalpha = CPEalpha;
impedance.CPER = CPER;
impedance.CPEDoD = CPEDoD;
impedance.CPERegime = CPERegime;

end

function show_result(t,U,I,DoDAh,CPEQ, CPEalpha, CPEDoD, CPERegime,CPEt)

hf = figure('name','ident_cpe');
subplot(3,2, [1 2]),plot(t,U,'b'),hold on,xlabel('time (s)'),ylabel('voltage (V)')

Ip = ismember(t,CPEt);
subplot(3,2, [1 2]),plot(t(Ip),U(Ip),'ro')
Ip = ismember(t,CPEt(isnan(CPEQ)));
subplot(3,2, [1 2]),plot(t(Ip),U(Ip),'rx')

% subplot(222),plot(t(Ip),I(Ip),'ro')
% subplot(223),plot(t(Ip),DoDAh(Ip),'ro')
% subplot(223),plot(CPEt,CPEQ,'ro'),xlabel('time (s)')

subplot(323),plot(CPEDoD,CPEQ,'ro'),xlabel('DoD(Ah)')
subplot(324),plot(CPERegime,CPEQ,'ro'),xlabel('Current(C)')
subplot(325),plot(CPEDoD,CPEalpha,'ro'),xlabel('DoD(Ah)')
subplot(326),plot(CPERegime,CPEalpha,'ro'),xlabel('Current(C)')

%cherche tout les handles du type axe et ignore les legendes
ha = findobj(hf,'type','axes','tag','');
% printLegTag(ha,'eastoutside');
prettyAxes(ha);
% linkaxes(ha, 'x' );
changeLine(ha,2,15);
end