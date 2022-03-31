function [phases, tcell, Icell, Ucell, modes] = decompose_bench(t,I,U,m,options)
%decompose_bench decoupe des profils (t,U,I,m) en phases par la valeur de m.
%
%[phases, tcell, Icell, Ucell, modes] = decompose_bench(t,I,U,m) cherche les
%changements du vecteur m et decoupe les quatre vecteurs (t,U,I,m). la
%fonction retourne:
% - phases: [(nx1) struct] avec quelques informations concernant chaque
% phase (tIni,tFin,Imoy,capa,Umax,Umin)
% - quatre cellules [tcell, Icell, Ucell] qui contiennent les portions des
% vecteurs.
% - modes: [(nx1) double] avec le mode (modeBanc) de chaque phase
%
%
%decompose_bench(t,I,U,m,'g') 'graphic', montre les resultats dans une figure.
%decompose_bench(t,I,U,m,'v') 'verbose', raconte ce qu'il fait.
%
% See also modeBanc, extractBanc, plot_phases

if ~exist('options','var')
    options = '';
end

% TENTATIVE: différencier des phases avec le même mode et changment de
% polarité
ms = m.*sign(I);
% ms = m;

Idecoupe = find(diff(ms));

iniPhase = [1;Idecoupe+1];
finPhase = [Idecoupe;length(t)];

tcell = cell(size(iniPhase));
Icell = cell(size(iniPhase));
Ucell = cell(size(iniPhase));
modes = zeros(size(iniPhase));
if ismember('v',options)
    fprintf('decompose_bench: t,U,I,m >>>');
end
for ind = 1:length(iniPhase)
    indices = iniPhase(ind):finPhase(ind);
    tcell{ind} = t(indices);
    Ucell{ind} = U(indices);
    Icell{ind} = I(indices);
%     modes(ind) = unique(m(indices));
     modes(ind) = mode(m(indices));%FIX: mode function returns always one unique value
end
if ismember('v',options)
    fprintf('tcell,Ucell,Icell,modes OK\n');
end
if ismember('v',options)
    fprintf('decompose_bench: phases...');
end

for ind = 1:length(tcell)
    thist = tcell{ind};
    thisI = Icell{ind};
    thisU = Ucell{ind};
    
    phases(ind).capa = calculCapa(thist,thisI);
    phases(ind).tIni = thist(1);
    phases(ind).tFin = thist(end);
    phases(ind).duree = phases(ind).tFin - phases(ind).tIni;
    phases(ind).Uini = thisU(1);
    phases(ind).Ufin = thisU(end);
    phases(ind).Imoy = phases(ind).capa*3600/phases(ind).duree;
    phases(ind).modes = modes(ind);
end
if ismember('v',options)
    fprintf('OK\n');
end

if ismember('g',options)
    hf = plot_phases(t,U,I,phases,'','h');
    set(hf,'name','decompose_bench');
end
end

function Capa = calculCapa(t,I)
%calculCapa calcul des amperes heure en integrant le courant versus le temps
% Capa = calculCapa(t,I)
% parameters d'entree: 
% t ([nx1] double): temps en secondes
% I ([nx1] double): courant en amperes
% sortie:
% Capa ([1x1] double): valeur de l'integration Ah
if iscell(t)
    fprintf('essaye: Q = cellfun(@calculCapa,t,I,''UniformOutput'' , false\n');
    error('il faut mettre a jour le typage, vecteurs au lieu de cellules');
end
if ~isequal(size(t),size(I))
    error('taille de vecteurs incompatible')
end
if isempty(t)
    Capa = [];return;
end
if length(t)==1
    Capa = 0;return;
end
    Capa = trapz(t,I)/3600;     %integration numerique du type trapeizoidal du courant par rapport au temps
end
