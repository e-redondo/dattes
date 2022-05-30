function [R, RDoD, RRegime, Rt, Rdt] = ident_r(t,U,I,DoDAh,config,phases,options)
%ident_r resistance identification from a profile t,U,I,m
%t,U,I from extract_profiles
%DoDAh from calcul_soc, depth of discharge in Amphours
%config from configurator
%
%See also dattes, calcul_soc, configurator, extract_profiles
if ~exist('options','var')
    options = '';
end
if ismember('v',options)
    fprintf('ident_r:...');
end
R = [];
RDoD = [];
RRegime = [];
Rt = [];
Rdt = [];
%%
%gestion d'erreurs:
if nargin<6 || nargin>7
    fprintf('ident_r:nombre incorrect de parametres, trouves %d\n',nargin);
    return;
end
if ~isstruct(config) || ~ischar(options) || ~isnumeric(t) ...
        || ~isnumeric(U) || ~isnumeric(I) || ~isnumeric(DoDAh)
    fprintf('ident_r:type de parametres, incorrect\n');
    return;
end
if ~isfield(config,'pR') || ~isfield(config,'minimal_duration_rest_before_pulse') || ~isfield(config,'minimal_duration_pulse') || ~isfield(config,'instant_end_rest')
    fprintf('ident_r:structure config incomplete\n');
    return;
end
%%
% tIniPulses = config.tR-config.tminRr-1;%FIX (BRICOLE) je met une seconde de plus (sinon warning dans calculR ligne69)
% tFinPulses = config.tR+config.tminR+1;%FIX (BRICOLE) je met une seconde de plus (sinon warning dans calculR ligne72)
indP = find(config.pR);
time_before_after_phase = [config.minimal_duration_rest_before_pulse 0];
R = [];
RRegime = [];
Rt = [];
RDoD = [];
Rdt = [];



for ind = 1:length(indP)
%     Ipulse = t>=tIniPulses(ind) & t<=tFinPulses(ind);
%     tp = t(Ipulse);
%     Up = U(Ipulse);
%     Ip = I(Ipulse);


    [tp,Up,Ip,DoDp] = extract_phase2(phases(indP(ind)),time_before_after_phase,t,U,I,DoDAh);%FIX (BRICOLE) la même mais avec getPhases 2
    Is = tp-tp(1)<config.minimal_duration_rest_before_pulse+config.minimal_duration_pulse+3;%FIX (BRICOLE) la même mais avec getPhases 2
    tp = tp(Is);
    Up = Up(Is);
    Ip = Ip(Is);

    [thisR, thisRRegime, thisRt, thisRDoD,thisRdt, err] = calcul_r(tp,Up,Ip,DoDp,config.instant_end_rest(ind),config.minimal_duration_pulse,config.minimal_duration_rest_before_pulse ,config.instant_calcul_R);
   
    R = [R thisR];
    RRegime = [RRegime thisRRegime];
    Rt = [Rt thisRt];
    RDoD = [RDoD thisRDoD];
    Rdt = [Rdt thisRdt];
    

    
end
RRegime = RRegime/config.Capa;

if ismember('v',options)
    fprintf('OK\n');
end
if ismember('g',options)
    showResult(t,U,I,DoDAh,R,RDoD,RRegime,Rt);
end
end

function showResult(t,U,I,DoDAh,R,RDoD,RRegime,Rt)

hf = figure('name','ident_r');
subplot(221),plot(t,U,'b'),hold on,xlabel('time (s)'),ylabel('voltage (V)')
% subplot(222),plot(t,I,'b'),hold on,xlabel('time (s)'),ylabel('current (A)')
% subplot(223),plot(t,DoDAh,'b'),hold on,xlabel('time (s)'),ylabel('DoD (Ah)')

Ip = ismember(t,Rt);
subplot(221),plot(t(Ip),U(Ip),'ro')
Ip = ismember(t,Rt(isnan(R)));
subplot(221),plot(t(Ip),U(Ip),'rx')

% subplot(222),plot(t(Ip),I(Ip),'ro')
% subplot(223),plot(t(Ip),DoDAh(Ip),'ro')
subplot(223),plot(Rt,R,'ro'),xlabel('time (s)'),ylabel('resistance (Ohm)')
subplot(222),plot(RDoD,R,'ro'),xlabel('DoD(Ah)'),ylabel('resistance (Ohm)')
subplot(224),plot(RRegime,R,'ro'),xlabel('Current(C)'),ylabel('resistance (Ohm)')

%cherche tout les handles du type axe et ignore les legendes
ha = findobj(hf,'type','axes','tag','');
% printLegTag(ha,'eastoutside');
prettyAxes(ha);
% linkaxes(ha, 'x' );
changeLine(ha,2,15);
end
