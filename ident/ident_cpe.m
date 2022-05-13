function [CPEQ, CPEalpha, CPER, CPEDoD, CPERegime] = ident_cpe(t,U,I,DoDAh,config,options)
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
CPEQ = [];
CPEalpha = [];
CPEDoD = [];
CPERegime = [];

%%
%gestion d'erreurs:
if nargin<5 || nargin>6
    fprintf('ident_cpe: wrong number of parameters, found %d\n',nargin);
    return;
end
if ~isstruct(config) || ~ischar(options) || ~isnumeric(t) ...
        || ~isnumeric(U) || ~isnumeric(I) || ~isnumeric(DoDAh)
    fprintf('ident_cpe: wrong type of parametres\n');
    return;
end
if ~isfield(config,'tW') || ~isfield(config,'tminWr') || ~isfield(config,'tminW')
    fprintf('ident_cpe: config struct incomplete\n');
    return;
end
%%
% TODO: stop using tW in config, use pW and get_phase
%%

tIniPulses = config.tW-config.tminWr;
tFinPulses = config.tW+config.tminW;

for ind = 1:length(config.tW)
    Ipulse = t>=tIniPulses(ind) & t<=tFinPulses(ind);
    tp = t(Ipulse);
    Up = U(Ipulse);%TODO: U - Ur - Uocv?
    Ip = I(Ipulse);
    DoDAhp = DoDAh(Ipulse);
    
    %correction relaxation
    Irepos = t>=tIniPulses(ind) & t<=config.tW(ind);
    trepos = t(Irepos);
    Urepos = U(Irepos);
    ws = warning('off','all');%TODO gerer ca un peu mieux...
    Urelax = polyval(polyfit(trepos,Urepos,2),tp);%BRICOLE
    warning(ws);%TODO gerer ca un peu mieux...
    %TODO: correction derive SoC > derive OCV
    if isfield(config,'ocv')
        Uocv = interp1(config.dod_ocv,config.ocv,DoDAhp);
        Urelax = mean(Urepos)-Uocv(1);%phenomène d'hysteresis
%          Uocv = zeros(size(Up));
    else
        Uocv = zeros(size(Up));
    end
    %TODO: correction chute ohmique
    [R, RRegime] = calcul_r(tp,Up,Ip,config.tW(ind),config.tminR,config.tminWr);
    Ur = zeros(size(Up));
    Ur = Ip*R;
    %applique les corrections:
    Up = Up-Urelax-Uocv-Ur;
    %TODO: comment transmettre 'g' a calculCPE? il genere beaucoup de
    %figures!!
    if ~config.CPEafixe
        [CPEQ(ind), CPEalpha(ind), ~, CPERegime(ind)] = calcul_cpe_pulse(tp,Up,Ip);
    else
        [CPEQ(ind), CPEalpha(ind), ~, CPERegime(ind)] = calcul_cpe_pulse(tp,Up,Ip,'a',config.CPEafixe);
    end
    CPEt(ind) = t(t==config.tW(ind));
    CPEDoD(ind) = DoDAh(t==config.tW(ind));%TODO: DoD ini ou moyen?
    CPER(ind) = R;
end
CPERegime = CPERegime/config.Capa;

if ismember('v',options)
    fprintf('OK\n');
end
if ismember('g',options)
    show_result(t,U,I,DoDAh,CPEQ, CPEalpha, CPEDoD, CPERegime,CPEt);
end
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