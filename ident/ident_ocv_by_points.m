function [ocv, dod, time, signe] = ident_ocv_by_points(t,U,DoDAh,m,config,phases,options)
%ident_ocv_by_points OCV by points identification (rests after partial
%charges/discharges)
%
% Usage:
% [ocv, dod] = ident_ocv_by_points(t,U,DoDAh,m,config,phases,options)
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

time =[];%instants pour la prise de la mesure
ocv =[];
dod =[];
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


phases_ocv = phases(config.pOCVr);
ip_avant = [config.pOCVr(2:end) false];
ip_avav = [config.pOCVr(3:end) false false];
phases_avant = phases(ip_avant);
phases_avav = phases(ip_avav);
if length(phases_avant)<length(phases_ocv)
    fprintf('ident_ocv_by_points:error\n');
end
for ind = 1:length(phases_ocv)
    [tp,Up,DoDAhp] = extract_phase(phases_ocv(ind),t,U,DoDAh);
    
    time(ind) = tp(end);
    ocv(ind) = Up(end);%TODO: extrapolation, calcul de la relaxation, etc.
    dod(ind) = DoDAhp(end);
    signe(ind) = sign(phases_avant(ind).Iavg);
end
%filter points with delta DOD > delta dod max:
%TODO: Either do it in configurator2, either let it possible as option here
%TODO: (bug) not working if phase(2) in phases_ocv, try filtering by DoDp? 
% ddod = ([phases_avant.capacity] + [phases_avav.capacity])/config.Capa;
% If = abs(ddod)<config.dodmaxOCVr & abs(ddod)>config.dodminOCVr;
If = true(size(time));

time = time(If);
ocv = ocv(If);
dod = dod(If);
signe = signe(If);

if ismember('v',options)
    fprintf('OK\n');
end
if ismember('g',options)
%     showResult(t,U,DoDAh, time, ocv, dod);
    plotOCVp(t,U,DoDAh, time, ocv, dod, signe);
end

end

% function showResult(t,U,DoDAh, time, ocv, dod)
% 
% hf = figure('name','ident_ocv_by_points');
% 
% subplot(211),plot(t,U),hold on,ylabel('voltage [V]'),xlabel('temps [s]')
% subplot(212),plot(DoDAh,U),hold on,ylabel('voltage [V]'),xlabel('DoDAh [Ah]')
% 
% subplot(211),plot(time,ocv,'rx')
% subplot(212),plot(dod,ocv,'r-x')
% 
% %cherche tout les handles du type axe et ignore les legendes
% ha = findobj(hf,'type','axes','tag','');
% prettyAxes(ha);
% changeLine(ha,2,15);
% end