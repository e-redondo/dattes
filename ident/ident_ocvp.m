function [OCVp, DoDp, tOCVp, Ipsign] = ident_ocvp(t,U,DoDAh,m,config,phases,options)
%ident_ocvp OCV by points identification (rests after partial
%charges/discharges)
%
% [OCVp, DoDp] = ident_ocvp(t,U,DoDAh,m,config,phases,options)
% - t,U,DoDAh,m [(nx1) double]: vecteurs temps,tension DoD(Ah) et mode
% - config: [struct] issue de configurator2
% - phases: [struct] issue de decoupeBanc
% - options: [string] options d'execution ('v' = verbose, 'g' = graphique)
%
% See also modeBanc, decoupeBanc, configurator2

if ~exist('options','var')
    options = '';
end
if ismember('v',options)
    fprintf('ident_ocvp:...');
end

tOCVp =[];%instants pour la prise de la mesure
OCVp =[];
DoDp =[];
%gestion d'erreurs:
if nargin<6 || nargin>7
    fprintf('ident_ocvp:nombre incorrect de parametres, trouves %d\n',nargin);
    return;
end
if ~isstruct(phases) || ~isstruct(config) || ~ischar(options)...
        || ~isnumeric(t) || ~isnumeric(U)|| ~isnumeric(DoDAh) || ~isnumeric(m)
    fprintf('ident_ocvp:type de parametres, incorrect\n');
    return;
end
if ~isfield(config,'pOCVr')
    fprintf('ident_ocvp:structure config incomplete\n');
    return;
end


phasesOCV = phases(config.pOCVr);
Ipavant = [config.pOCVr(2:end) false];
Ipavav = [config.pOCVr(3:end) false false];
phasesAvant = phases(Ipavant);
phasesAvav = phases(Ipavav);
if length(phasesAvant)<length(phasesOCV)
    fprintf('ident_ocvp:error\n');
end
for ind = 1:length(phasesOCV)
    [tp,Up,DoDAhp] = extract_phase(phasesOCV(ind),t,U,DoDAh);
    
    tOCVp(ind) = tp(end);
    OCVp(ind) = Up(end);%TODO: extrapolation, calcul de la relaxation, etc.
    DoDp(ind) = DoDAhp(end);
    Ipsign(ind) = sign(phasesAvant(ind).Iavg);
end
%filter points with delta DOD > delta dod max:
%TODO: Either do it in configurator2, either let it possible as option here
%TODO: (bug) not working if phase(2) in phasesOCV, try filtering by DoDp? 
% ddod = ([phasesAvant.capacity] + [phasesAvav.capacity])/config.Capa;
% If = abs(ddod)<config.dodmaxOCVr & abs(ddod)>config.dodminOCVr;
If = true(size(tOCVp));

tOCVp = tOCVp(If);
OCVp = OCVp(If);
DoDp = DoDp(If);
Ipsign = Ipsign(If);

if ismember('v',options)
    fprintf('OK\n');
end
if ismember('g',options)
%     showResult(t,U,DoDAh, tOCVp, OCVp, DoDp);
    plotOCVp(t,U,DoDAh, tOCVp, OCVp, DoDp, Ipsign);
end

end

% function showResult(t,U,DoDAh, tOCVp, OCVp, DoDp)
% 
% hf = figure('name','ident_ocvp');
% 
% subplot(211),plot(t,U),hold on,ylabel('voltage [V]'),xlabel('temps [s]')
% subplot(212),plot(DoDAh,U),hold on,ylabel('voltage [V]'),xlabel('DoDAh [Ah]')
% 
% subplot(211),plot(tOCVp,OCVp,'rx')
% subplot(212),plot(DoDp,OCVp,'r-x')
% 
% %cherche tout les handles du type axe et ignore les legendes
% ha = findobj(hf,'type','axes','tag','');
% prettyAxes(ha);
% changeLine(ha,2,15);
% end