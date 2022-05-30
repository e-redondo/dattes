function [phases, tcell, Icell, Ucell, modes] = split_phases(t,I,U,m,options)
%split_phases split profiles (t,U,I,m) into phases by m value.
%
% Usage:
% [phases, tcell, Icell, Ucell, modes] = split_phases(t,I,U,m)
% Search for changes in 'm' vector and cut the four vectors (t,U,I,m)
%
% Inputs:
% - t,I,U,m [(nx1) double]: vectors from extract_profiles
% - options [(1xp) string]: execution options:
%    - 'u': unsigned ignore changes in polarity of current
%    - 'v': verbose
%    - 'g': graphics
%
% Outputs:
% - phases [(mx1) struct]: structure array with fields:
%    - t_ini [(1x1) double]: phase start time (seconds)
%    - t_fin [(1x1) double]: phase end time (seconds)
%    - duration [(1x1) double]: phase duration (seconds)
%    - Uini [(1x1) double]: phase initial voltage
%    - Ufin [(1x1) double]: phase final voltage
%    - Iavg [(1x1) double]: phase average current
%    - Uavg [(1x1) double]:  phase average voltage
%    - capacity [(1x1) double]: phase capacity (Ah)
%    - mode [(1x1) double]: phase mode (rest, CC, CV, EIS, profile)
% - tcell Icell, Ucell [(mx1) cell]: cell arrays, each 'k' element
% correspond to the 'cut' of t,U,I or m for 'k' phase
% - modes [(mx1) double]: mode of each phase
%
% Examples:
% split_phases(t,I,U,m,'g') % 'graphics', show results in a figure.
% split_phases(t,I,U,m,'v') % 'verbose', tell what it does.
%
% See also which_mode, extract_profiles, plot_phases

if ~exist('options','var')
    options = '';
end

% TENTATIVE: différencier des phases avec le même mode et changment de
if ismember('u',options)%unsigned
  ms = m;  
else
% polarité
ms = m.*sign(I);
ms(sign(I)==0 | ms==-3) = 3;
end


Icut = find(diff(ms));

iniPhase = [1;Icut+1];
finPhase = [Icut;length(t)];

tcell = cell(size(iniPhase));
Icell = cell(size(iniPhase));
Ucell = cell(size(iniPhase));
modes = zeros(size(iniPhase));
if ismember('v',options)
    fprintf('split_phases: t,U,I,m >>>');
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
    fprintf('split_phases: phases...');
end

for ind = 1:length(tcell)
    thist = tcell{ind};
    thisI = Icell{ind};
    thisU = Ucell{ind};
%     if ind==22 %DEBUG (put ind value of concerning phase)
%         fprintf('here\n');
%     end
    phases(ind).t_ini = thist(1);
    phases(ind).t_fin = thist(end);
    phases(ind).duration = phases(ind).t_fin - phases(ind).t_ini;
    phases(ind).Uini = thisU(1);
    phases(ind).Ufin = thisU(end);
    if phases(ind).duration==0
        %TODO better error detectio, if length thist==1, try to merge into
        %preceding or posponing phase
        phases(ind).Iavg = thisI(1);
        phases(ind).Uavg = thisU(1);
        phases(ind).capacity = 0;
    else
        phases(ind).Iavg = trapz(thist,thisI)/phases(ind).duration;
        phases(ind).Uavg = trapz(thist,thisU)/phases(ind).duration;
        phases(ind).capacity = phases(ind).Iavg*phases(ind).duration/3600;
    end

    phases(ind).mode = modes(ind);
end
if ismember('v',options)
    fprintf('OK\n');
end

if ismember('g',options)
    hf = plot_phases(t,U,I,phases,'','h');
    set(hf,'name','split_phases');
end
end

% function Capa = calculCapa(t,I)
% %calculCapa calcul des amperes heure en integrant le courant versus le temps
% % Capa = calculCapa(t,I)
% % parameters d'entree: 
% % t ([nx1] double): temps en secondes
% % I ([nx1] double): courant en amperes
% % sortie:
% % Capa ([1x1] double): valeur de l'integration Ah
% if iscell(t)
%     fprintf('essaye: Q = cellfun(@calculCapa,t,I,''UniformOutput'' , false\n');
%     error('il faut mettre a jour le typage, vecteurs au lieu de cellules');
% end
% if ~isequal(size(t),size(I))
%     error('taille de vecteurs incompatible')
% end
% if isempty(t)
%     Capa = [];return;
% end
% if length(t)==1
%     Capa = 0;return;
% end
%     Capa = trapz(t,I)/3600;     %integration numerique du type trapeizoidal du courant par rapport au temps
% end
