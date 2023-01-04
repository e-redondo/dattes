function [phases, tcell, Icell, Ucell, modes] = split_phases(datetime,I,U,m,options)
%split_phases split profiles (datetime,U,I,m) into phases by m value.
%
% Usage:
% [phases, tcell, Icell, Ucell, modes] = split_phases(datetime,I,U,m)
% Search for changes in 'm' vector and cut the four vectors (datetime,U,I,m)
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
%    - datetime_ini [(1x1) double]: phase start datetime (seconds)
%    - datetime_fin [(1x1) double]: phase end datetime (seconds)
%    - duration [(1x1) double]: phase duration (seconds)
%    - Uini [(1x1) double]: phase initial voltage
%    - Ufin [(1x1) double]: phase final voltage
%    - Iini [(1x1) double]: phase initial current
%    - Ifin [(1x1) double]: phase final current
%    - Uavg [(1x1) double]:  phase average voltage
%    - Iavg [(1x1) double]: phase average current
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
%
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

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
ms(ms==-4) = 4;
end


Icut = find(diff(ms));

iniPhase = [1;Icut+1];
finPhase = [Icut;length(datetime)];

tcell = cell(size(iniPhase));
Icell = cell(size(iniPhase));
Ucell = cell(size(iniPhase));
modes = zeros(size(iniPhase));
if ismember('v',options)
    fprintf('split_phases: t,U,I,m >>>');
end
for ind = 1:length(iniPhase)
    indices = iniPhase(ind):finPhase(ind);
    tcell{ind} = datetime(indices);
    Ucell{ind} = U(indices);
    Icell{ind} = I(indices);

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

    phases(ind).datetime_ini = thist(1);
    phases(ind).datetime_fin = thist(end);
    
    phases(ind).Uini = thisU(1);
    phases(ind).Ufin = thisU(end);
    phases(ind).Iini = thisI(1);
    phases(ind).Ifin = thisI(end);
    if phases(ind).duration==0
        %TODO better error detectio, if length thist==1, try to merge into
        %preceding or posponing phase
        phases(ind).Uavg = thisU(1);
        phases(ind).Iavg = thisI(1);
        phases(ind).capacity = 0;
    else
        phases(ind).Uavg = trapz(thist,thisU)/phases(ind).duration;
        phases(ind).Iavg = trapz(thist,thisI)/phases(ind).duration;
        phases(ind).capacity = phases(ind).Iavg*phases(ind).duration/3600;
    end

    phases(ind).mode = modes(ind);
end

for ind = 1:(length(phases)-1)
    %duration = t_ini of following phase - t_ini of current phase
    phases(ind).duration = phases(ind+1).datetime_ini - phases(ind).datetime_ini;
end
% last phase is different, no following phase
% duration = t_fin - t_ini
phases(end).duration = phases(end).datetime_fin-phases(end).datetime_ini;

if ismember('v',options)
    fprintf('OK\n');
end

if ismember('g',options)
    hf = plot_phases(datetime,U,I,phases,'','h');
    set(hf,'name','split_phases');
end
end

