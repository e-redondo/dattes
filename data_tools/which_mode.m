function m = which_mode(t,I,U,Step,I_threshold,U_threshold,options)
% which_mode calculate the working mode of the cycler (rest, CC, CV, EIS, profile)
%
% Usage:
% m = which_mode(t,I,U,Step,I_threshold,U_threshold,options)
%
% Inputs:
% - t,I,U,Step (nx1 double): from test data
% - I_threshold (1x1 double): current threshold to consider change
% - U_threshold (1x1 double): voltage threshold to consider change
% - options (1xp string): execution options
%    - 'v': verbose
%    - 'g': graphics
%
% Output:
% - m (nx1 double): cycler working mode
%    - 1 = CC (constant current)
%    - 2 = CV (constant voltage)
%    - 3 = rest 
%    - 4 = EIS (impedance spectroscopy)
%    - 5 = profile (random profile)
%
%   See also import_arbin_res, import_arbin_xls, import_bitrode, split_phases
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

if nargin < 6
    error('which_mode: minimum inputs = 6')
end

if ~isnumeric(U_threshold) || ~isnumeric(I_threshold)
    error('which_mode: I_threshold and U_threshold must be numeric')
end

if ~isscalar(U_threshold) || ~isscalar(I_threshold)
    error('which_mode: I_threshold and U_threshold must be scalars')
end
   
if ~isvector(t) || ~isvector(I) || ~isvector(U) || ~isvector(Step)
    error('which_mode: t,U,I,Step must be vectors')
end

if length(t)<2  || length(t)~=length(I)|| length(t)~=length(U)|| length(t)~=length(Step)
   error('which_mode: t,U,I,Step must have same size and length>2')
end
if ~exist('options','var')
    options = '';
end
%Running options
verbose = ismember('v',options);


m = zeros(size(t));

I_threshold2 = 2*I_threshold;
U_threshold2 = 2*U_threshold;

%decompose vectors depending of Step value
[phases, tcell, Icell, Ucell, Steps] = split_phases(t,I,U,Step,'u');

%Merge short steps (profil)
%Find and merge short steps
Is = [phases.duration]<=1;
Idebut = Is & ~[0 Is(1:end-1)];%current step is short and previous not
Ifin = Is & ~[Is(2:end) 0];%current step is short and following not
Starts = find(Idebut);
Ends = find(Ifin);
nbSteps = Ends-Starts;%steps number between 'start' and 'end'
%Only the series with at least 10 consecutives shorts steps are kept 
Starts = Starts(nbSteps>10);
Ends = Ends(nbSteps>10);


newStep = Step;
for ind = 1:length(Starts)
    datetime_ini = phases(Starts(ind)).datetime_ini;%start of the first short phase 
    datetime_fin = phases(Ends(ind)).datetime_fin;%end of the last short phase 
    indices = t>=datetime_ini & t<=datetime_fin;%FIX: effet de bord?
    newStep(indices) = -1;%marquage profil
end

%decompose again, this time with newStep (short merged Steps)
[phases, tcell, Icell, Ucell, Steps] = split_phases(t,I,U,newStep,'u');
for ind = 1:length(phases)
   indices = t>=tcell{ind}(1) & t<=tcell{ind}(end);
   if Steps(ind)==-1%marquage profil
       m(indices) = 5;
   else
       m(indices)  = quelMode(tcell{ind},Ucell{ind},Icell{ind},U_threshold2,I_threshold2);
   end
end

if ismember('g',options)
    showResult(t,U,I,m);
end
end


function  m  = quelMode(t,U,I,sU,sI)
%fonction pour les cas des points non isoles length(t)>1
%si max(abs(I))<sI/2 >>> m=3
%si abs(U(2)-U(1)) || abs(U(3)-U(2)) < sU >>> m=2
%si abs(I(2)-I(1)) || abs(I(3)-I(2)) < sI >>> m=3
modes  = false(1,5);

% modes(3) = max(abs(I))<=sI/2;%repos
modes(3) = mean(abs(I))<=sI/2;%repos %FIX, BRICOLE, points a 0.2A pdt des repos
if modes(3)
    m = 3;
    return;
end
dU = max(U)-min(U);
dI =  max(I)-min(I);
modes(2) = dU<=sU;%CV
modes(1) = dI<=sI;%CC

if sum(modes)>1
    %si m2 et m3 au meme temps, arbitrer:
    if dU/sU < dI/sI
        modes(1)=false;
    else
        modes(2)=false;
    end
    if sum(modes)>1
        error('arbitrage necessaire')
    end
end
if sum(modes)==0
    %     error('mode non trouve')
    %je ne sais pas ce que c'est, ca doit etre un profil
    %     return;
%     indCCCV = findCCCV(t,I);
    indCCCV = split_cccv(t,I);
    m = ones(size(I));%CC = 1
    m(indCCCV:end) = 2;%CV = 2
    return;
end
m=find(modes);
end


function showResult(t,U,I,m)

h = figure('name','which_mode');
subplot(211),plot(t,U,'b','displayname','test'),hold on,xlabel('time'),ylabel('voltage')
subplot(212),plot(t,I,'b','displayname','test'),hold on,xlabel('time'),ylabel('current')

c = 'rmgck';
tags = {'CC','CV','rest','EIS','profile'};
for ind = 1:5
    indices = m==ind;
    
    subplot(211),plot(t(indices),U(indices),[c(ind) 'o'],'displayname',tags{ind})
    subplot(212),plot(t(indices),I(indices),[c(ind) 'o'],'displayname',tags{ind})
end


%cherche tout les handles du type axe et ignore les legendes
ha = findobj(h, 'type', 'axes', 'tag', '' );   
% printLegTag(ha,'eastoutside');
legend(subplot(211),'show','location','eastoutside')
legend(subplot(212),'show','location','eastoutside')

linkaxes(ha, 'x' );
prettyAxes(ha);
end

function indCCCV = findCCCV(t,I)
%experimentalement  j'ai trouve que la transition CCCV se produit avant le
%pic de dIdt, il faut trouver le premier 'zero' de dIdt avant le pic:

%DEBUG
% if length(unique(diff(t)))~=1
%     warning('vector sampled with variable frequency')
% end
%1.-calcul de dIdt:
dIdt = moving_derivative(t,I,5*(t(2)-t(1)));%ordre 5, TODO: fixer, configurer?
%2 Filtrer:
%2.1.-premier filtre
if mean(I)>0%si charge on cherche une forte diminution
dIdt(dIdt>0)=0;
else%si decharge on cherche une forte augmentation (diminution de la valeur abs)
dIdt(dIdt<0)=0;
end
%2.2.-deuxieme filtre (temps de montee, 80%)
indDebut = find(abs(I)>0.8*max(abs(I)),1);
dIdt(1:indDebut)=0;
%2.3.-troisieme filtre (bruit de courant pendant le floating)
indFin = find(abs(I(indDebut:end))<0.8*max(abs(I)),1);
dIdt(indFin:end)=0;
%3.-recherche du pic
indPic = find(abs(dIdt)==max(abs(dIdt)),1,'last');
%3.1-recherche de l'instant justa avant ou dIdt valait '0'
indCCCV = find(dIdt(1:indPic)==0,1,'last');
end
