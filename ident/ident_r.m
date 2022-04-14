function [R, RDoD, RRegime, Rt] = ident_r(t,U,I,DoDAh,config,phases,options)
%ident_r resistance identification from a profile t,U,I,m
%t,U,I from extract_bench
%DoDAh from calcul_soc, depth of discharge in Amphours
%config from configurator
%
%See also dattes, calcul_soc, configurator, extract_bench
if ~exist('options','var')
    options = '';
end
if ismember('v',options)
    fprintf('ident_r:...');
end
R = [];
RDoD = [];
RRegime = [];

%%
%gestion d'erreurs:
if nargin<6 || nargin>7
    fprintf('ident_r:nombre incorrect de parametres, trouves %d\n',nargin);
    return;
end
if ~isstruct(config) || ~isstruct(phases) || ~ischar(options) || ~isnumeric(t) ...
        || ~isnumeric(U) || ~isnumeric(I) || ~isnumeric(DoDAh)
    fprintf('ident_r:type de parametres, incorrect\n');
    return;
end
if ~isfield(config,'pR') || ~isfield(config,'tminRr') || ~isfield(config,'tminR')
    fprintf('ident_r:structure config incomplete\n');
    return;
end
%%
% tIniPulses = config.tR-config.tminRr-1;%FIX (BRICOLE) je met une seconde de plus (sinon warning dans calculR ligne69)
% tFinPulses = config.tR+config.tminR+1;%FIX (BRICOLE) je met une seconde de plus (sinon warning dans calculR ligne72)
indP = find(config.pR);
for ind = 1:length(indP)
%     Ipulse = t>=tIniPulses(ind) & t<=tFinPulses(ind);
%     tp = t(Ipulse);
%     Up = U(Ipulse);
%     Ip = I(Ipulse);

    [tp,Up,Ip,DoDp] = get_phase2(phases(indP(ind)),[config.tminRr+3 0],t,U,I,DoDAh);%FIX (BRICOLE) la même mais avec getPhases 2
    Is = tp-tp(1)<config.tminRr+config.tminR+3;%FIX (BRICOLE) la même mais avec getPhases 2
    tp = tp(Is);
    Up = Up(Is);
    Ip = Ip(Is);
    
    %TODO: comment transmettre 'g' a calculR? il genere beaucoup de figures!!
    [R(ind), RRegime(ind)] = calcul_r(tp,Up,Ip,phases(indP(ind)-1).t_fin,config.tminR,config.tminRr);
    Rt(ind) = t(t==phases(indP(ind)-1).t_fin);
    %RDoD(ind) = DoDAh(t==config.tR(ind));
    RDoD(ind) = DoDp(1);
    
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