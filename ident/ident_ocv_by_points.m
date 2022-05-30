function [OCVp, DoDp, tOCVp, Ipsign] = ident_ocv_by_points(t,U,DoDAh,m,config,phases,options)
%ident_ocv_by_points OCV by points identification (rests after partial
%charges/discharges)
%
% Usage:
% [OCVp, DoDp] = ident_ocv_by_points(t,U,DoDAh,m,config,phases,options)
%
% Inputs:
% - t,U,DoDAh,m [(nx1) double]: vectors from extract_profiles
% - config [(1x1) struct]: config struct from configurator
% - phases [(mx1) struct] phases from split_phases
% - options: [string] execution options
%    - 'v' = verbose
%    - 'g' = graphics
%
% See also which_mode, split_phases, configurator

if ~exist('options','var')
    options = '';
end
if ismember('v',options)
    fprintf('ident_ocv_by_points:...');
end

tOCVp =[];%instants pour la prise de la mesure
OCVp =[];
DoDp =[];
%gestion d'erreurs:
if nargin<6 || nargin>7
    fprintf('ident_ocv_by_points:nombre incorrect de parametres, trouves %d\n',nargin);
    return;
end
if ~isstruct(phases) || ~isstruct(config) || ~ischar(options)...
        || ~isnumeric(t) || ~isnumeric(U)|| ~isnumeric(DoDAh) || ~isnumeric(m)
    fprintf('ident_ocv_by_points:type de parametres, incorrect\n');
    return;
end
if ~isfield(config,'pOCVr')
    fprintf('ident_ocv_by_points:structure config incomplete\n');
    return;
end


phasesOCV = phases(config.pOCVr);
Ipavant = [config.pOCVr(2:end) false];
Ipavav = [config.pOCVr(3:end) false false];
phasesAvant = phases(Ipavant);
phasesAvav = phases(Ipavav);
if length(phasesAvant)<length(phasesOCV)
    fprintf('ident_ocv_by_points:error\n');
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
% ddod = ([phasesAvant.capacity] + [phasesAvav.capacity])/config.test.capacity;
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
% hf = figure('name','ident_ocv_by_points');
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