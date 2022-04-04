function m = mode_bench2(t,I,U,Step,seuilI,seuilU,options)
% mode_bench2 mode de fonctionnement du banc (repos, CC, CV, EIS, profil)
%     mode_bench2(t,I,U,seuilI,seuilU) Calcule le vecteur mode ("m") apartir des
%     informations suivantes:
%     1.- U: si constant (i.e. deltaU < seuilU), phase CV
%     2.- I: si constant (i.e. deltaI < seuilI), phase CC ou repos (si 0)
%     Valeur de retour:
%     m [nx1 (double)]:'mode (1=CC, 2=CV, 3=repos, 4=EIS, 5 = profil de courant)'
%   See also importArbinRes, importBiologic,decompose_bench

if ~exist('options','var')
    options = '';
end
%options d'execution
verbose = ismember('v',options);


m = zeros(size(t));

seuilI2 = 2*seuilI;
seuilU2 = 2*seuilU;

%decouper en fonction de la valeur de Step
[phases, tcell, Icell, Ucell, Steps] = decompose_bench(t,I,U,Step);

%FUSION DE STEPS COURTS (profil)
%trouver des Steps courts et les fusionner
Is = [phases.duration]<=1;
Idebut = Is & ~[0 Is(1:end-1)];%step actuel est court et celui d'avant non
Ifin = Is & ~[Is(2:end) 0];%step actuel est court et celui d'apres non
Debuts = find(Idebut);
Fins = find(Ifin);
nbSteps = Fins-Debuts;%nb de steps entre un 'debut' et une 'fin'
%on ne retient que les series d'au moins 10 steps courts consecutifs:
Debuts = Debuts(nbSteps>10);
Fins = Fins(nbSteps>10);


newStep = Step;
for ind = 1:length(Debuts)
    tDebut = phases(Debuts(ind)).t_ini;%debut de la premiere phase courte
    t_fin = phases(Fins(ind)).t_fin;%fin de la derniere phase courte
    indices = t>=tDebut & t<=t_fin;%FIX: effet de bord?
%     newValue = phases(Debuts(ind)).modes;
    newStep(indices) = -1;%marquage profil
end

%redecoupe, cette fois avec newStep (Steps courts fusionnes)
[phases, tcell, Icell, Ucell, Steps] = decompose_bench(t,I,U,newStep);
for ind = 1:length(phases)
   indices = t>=tcell{ind}(1) & t<=tcell{ind}(end);
   if Steps(ind)==-1%marquage profil
       m(indices) = 5;
   else
       m(indices)  = quelMode(tcell{ind},Ucell{ind},Icell{ind},seuilU2,seuilI2);
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
    %     m = modeBanc(1:length(I),I,U,sI,sU);
    %     return;
    indCCCV = findCCCV(t,I);
    m = ones(size(I));%CC = 1
    m(indCCCV:end) = 2;%CV = 2
    return;
end
m=find(modes);
end


function showResult(t,U,I,m)

h = figure('name','mode_bench2');
subplot(211),plot(t,U,'b','tag','essai'),hold on,xlabel('time'),ylabel('voltage')
subplot(212),plot(t,I,'b','tag','essai'),hold on,xlabel('time'),ylabel('current')

c = 'rmgck';
tags = {'CC','CV','repos','EIS','profil'};
for ind = 1:5
    indices = m==ind;
    
    subplot(211),plot(t(indices),U(indices),[c(ind) 'o'],'tag',tags{ind})
    subplot(212),plot(t(indices),I(indices),[c(ind) 'o'],'tag',tags{ind})
end


%cherche tout les handles du type axe et ignore les legendes
ha = findobj(h, 'type', 'axes', 'tag', '' );   
printLegTag(ha,'eastoutside');
linkaxes(ha, 'x' );
prettyAxes(ha);
end

function indCCCV = findCCCV(t,I)
%experimentalement  j'ai trouve que la transition CCCV se produit avant le
%pic de dIdt, il faut trouver le premier 'zero' de dIdt avant le pic:
if length(unique(diff(t)))~=1
    warning('vector sampled with variable frequency')
end
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