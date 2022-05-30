function [pOCV, pDoD, pPol, pEff,UCi,UDi,Regime] = ident_pseudo_ocv(t,U,DoDAh,config,phases,options)
%ident_pseudo_ocv pseudoOCV identification
%
% See also dattes, configurator

%si plus d'une phase en charge ou plus d'une phase en decharge > ERREUR

phasesOCVC = phases(config.pOCVpC);
phasesOCVD = phases(config.pOCVpD);

%default values: empty arrays
    pOCV = [];
    pDoD = [];
    pPol = [];
    pEff = [];
    UCi = [];
    UDi = [];
    Regime = [];
    
%error management, if no pseudoOCV phases, return empty arrays
if isempty(phasesOCVC) || isempty(phasesOCVD)
    fprintf('ident_pseudo_ocv: ERREUR nombre de phases incorrect\n');
    return
end

regimeC = [phasesOCVC.Iavg]/config.test.capacity;
[regimeC Is] = sort(regimeC);%on met dans l'ordre
phasesOCVC = phasesOCVC(Is);
rapports = regimeC(1:end-1)./regimeC(2:end);%on calcule les rapports
If = [true rapports<.99];% on filtre les doublons (99%)
regimeC = regimeC(If);
phasesOCVC = phasesOCVC(If);

regimeD = -[phasesOCVD.Iavg]/config.test.capacity;
[regimeD Is] = sort(regimeD);%on met dans l'ordre
phasesOCVD = phasesOCVD(Is);
rapports = regimeD(1:end-1)./regimeD(2:end);%on calcule les rapports
If = [true rapports<.99];% on filtre les doublons (99%)
regimeD = regimeD(If);
phasesOCVD = phasesOCVD(If);

for ind = 1:length(regimeD)
    ceRegD = regimeD(ind);
    Delta = abs(1-regimeC/ceRegD);
   %trouver le regime en charge le plus proche pour chaque decharge
   [~,indC(ind)] = min(Delta);
end
%rearrange charges according to the discharges
phasesOCVC = phasesOCVC(indC);
Regime = regimeD;
if length(unique(indC))<indC
    fprintf('ident_pseudo_ocv: ERREUR à gerer\n');
    return
end

%BRICOLE pour SIMCAL KOKAM 12Ah
% if length(phasesOCVC)>3
%     phasesOCVC = phasesOCVC(1:3);
% end
% if length(phasesOCVD)>2
%     phasesOCVD = phasesOCVD(1:2);
% end
% if length(phasesOCVC)~=1 || length(phasesOCVD)~=1
%     pOCV = [];
%     pDoD = [];
%     pPol = [];
%     fprintf('ident_pseudo_ocv: ERREUR nombre de phases incorrect\n');
%     return
% end
UC = cell(size(phasesOCVC));
DoDAhC = cell(size(phasesOCVC));
UD = cell(size(phasesOCVD));
DoDAhD = cell(size(phasesOCVD));

for ind =1:length(phasesOCVC)
    %extraire les phases
    [~,UC{ind},DoDAhC{ind}] = extract_phase(phasesOCVC(ind),t,U,DoDAh);
end

for ind =1:length(phasesOCVD)
%extraire les phases
[~,UD{ind},DoDAhD{ind}] = extract_phase(phasesOCVD(ind),t,U,DoDAh);
end

%mettre dans l'ordre (et enleve doublons) TODO: ameliorer
[DoDAhCs, Is] = cellfun(@unique,DoDAhC,'uniformoutput',false);
UCs = cellfun(@(x,y) x(y),UC,Is,'uniformoutput',false);
%mettre dans l'ordre (et enleve doublons) TODO: ameliorer
[DoDAhDs, Is] = cellfun(@unique,DoDAhD,'uniformoutput',false);
UDs = cellfun(@(x,y) x(y),UD,Is,'uniformoutput',false);


%TODO: aller jusqu'à la fin, ne pas rester a CapaNom
pDoD = (0:config.dQOCV:config.test.capacity)';
% UCi = interp1(DoDAhCs,UCs,pDoD);
% UDi = interp1(DoDAhDs,UDs,pDoD);

UCi = cellfun(@(x,y) interp1(x,y,pDoD),DoDAhCs,UCs,'uniformoutput',false);
UDi = cellfun(@(x,y) interp1(x,y,pDoD),DoDAhDs,UDs,'uniformoutput',false);

%ancienne methode: moyenne entre plusieurs
% %TODO: traitement des NaN separement
% UCi = mean(cell2mat(UCi),2);
% UDi = mean(cell2mat(UDi),2);
% %TODO: ponderer en fonction du regime charge/decharge
% pOCV = (UCi+UDi)/2;
% pPol = UCi-UDi;
%nouvelle methode un couple de courbes par regime
pOCV = cellfun(@(x,y) (x+y)/2,UCi,UDi,'uniformoutput',false);
pPol = cellfun(@(x,y) (x-y),UCi,UDi,'uniformoutput',false);
pEff = cellfun(@(x,y) (y./x),UCi,UDi,'uniformoutput',false);

if ismember('g',options)
    showResult(UC,DoDAhC,UD,DoDAhD,pDoD,UCi,UDi,pOCV);
end
end

function showResult(UC,DoDAhC,UD,DoDAhD,pDoD,UCi,UDi,pOCV)

hf = figure('name','ident_pseudo_ocv');hold on
cellfun(@(x,y) plot(x,y,'b.-','tag','charge (mesure)'),DoDAhC,UC)
cellfun(@(x,y) plot(x,y,'r.-','tag','decharge (mesure)'),DoDAhD,UD)
% plot(pDoD,UCi,'b*','tag','charge (points)')
% plot(pDoD,UDi,'r*','tag','decharge (points)')
% plot(pDoD,pOCV,'k*-','tag','pseudoOCV')

cellfun(@(x,y) plot(pDoD,x,'b*','tag','charge (points)'),UCi)
cellfun(@(x,y) plot(pDoD,x,'r*','tag','decharge (points)'),UDi)
cellfun(@(x,y) plot(pDoD,x,'k-','tag','pseudoOCV'),pOCV)

ylabel('voltage [V]'),xlabel('DoD [Ah]')

%cherche tout les handles du type axe et ignore les legendes
ha = findobj(hf,'type','axes','tag','');
prettyAxes(ha);
changeLine(ha,2,15);
end