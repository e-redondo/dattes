%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%function [variableNames unitNames dateEssai typeEssai sourcefile] = analyseTete(filename)
function [variableNames, unitNames, dateEssai, typeEssai, sourcefile] = analyze_head(filename)

[tete, dateEssai, typeEssai, sourcefile] = biologic_head(filename);

[variableNames, unitNames] = analyseVariables(tete{end}, typeEssai);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%function [variableNames unitNames] = analyseVariables(ligne, typeEssai)
function [variableNames, unitNames] = analyseVariables(ligne, typeEssai)
%variables
variableNames = cell(0);
unitNames = cell(0);
%variables communes:
ligne = strrep(ligne,'time/s','tc{s}');
ligne = strrep(ligne,'Ewe/V','U{V}');%OVC SCGPL
ligne = strrep(ligne,'I/mA','I{mA}');%MB et autres?
ligne = strrep(ligne,'Energy/W.h','Energy{Wh}');%MB et autres?
ligne = strrep(ligne,'|Energy|/W.h','Energy{Wh}');%MB et autres?
ligne = strrep(ligne,'<Ewe>/V','U{V}');%GEIS
ligne = regexprep(ligne,'Ewe-Ece/V','EweEceDiff{V}');%IFPen dans SIMCAL
ligne = regexprep(ligne,'Ece/V','Ece{V}');%IFPen dans SIMCAL
ligne = regexprep(ligne,'z cycle','z_cycle');%202101 v1.31 MB et autres?
ligne(ligne==65533)='u';%v10.40 'micro' par 'u'
%BT-Lab
ligne(ligne=='µ')='u';%EC-LAB mars 2021
ligne = strrep(ligne,'°C','degC');%BT-LAB mars 2021
ligne = strrep(ligne,'Temperature/degC','Temperature{degC}');%BT-LAB mars 2021
ligne = strrep(ligne,'Ecell/V','U{V}');%OVC SCGPL
ligne = strrep(ligne,'Temperature/uC','T{degC}');%OVC SCGPL
ligne = strrep(ligne,'I Range','I_Range');%EC-Lab mars 2021 (GCPL)
ligne = strrep(ligne,'(Q-Qo)/mA.h','Qp{mAh}');%EC-Lab mars 2021 (GEIS)
ligne = strrep(ligne,'dq/mA.h','dq{mAh}');%EC-Lab mars 2021 (GEIS)
if strcmp(typeEssai,'SGCPL') || strcmp(typeEssai,'GCPL')
    %variables du SGCPL: 'mode','ox_red','error','control_changes','Ns_changes','counter','time','control','Ewe','dq','Analog_IN_1','I','Qp','x'
    %version: 10.23
    %variables du GCPL: 'mode','ox/red','error','control changes','Ns changes','counter inc.','Ns','time/s','control/V/mA','Ewe/V','dq/mA.h','Analog IN 1/V','P/W','<I>/mA','(Q-Qo)/mA.h','x','Capacity/mA.h'
    ligne = strrep(ligne,'ox/red','ox_red');
    ligne = strrep(ligne,'control changes','control_changes');
    ligne = strrep(ligne,'Ns changes','Ns_changes');
    ligne = strrep(ligne,'counter inc.','counter');
    ligne = strrep(ligne,'control/V/mA','control{V_or_mA}');
    ligne = strrep(ligne,'control/V','control{V}');%v10.40
    ligne = strrep(ligne,'control/mA','control{mA}');%v10.40
    ligne = strrep(ligne,'dq/mA.h','dq{mAh}');
    ligne = strrep(ligne,'Analog IN ','Analog_IN_');%%%%%%%%%%%%%%%%%%%%%%%%%
    ligne = strrep(ligne,'Analog_IN_1/V','Analog_IN_1{V}');%%%%%%%%%%%%%%%%%%%%%%%%%
    ligne = strrep(ligne,'Analog_IN_1/C','Analog_IN_1{C}');%%%%%%%%%%%%%%%%%%%%%%%%%
    ligne = strrep(ligne,'Analog_IN_2/V','Analog_IN_2{V}');%%%%%%%%%%%%%%%%%%%%%%%%%
    ligne = strrep(ligne,'Analog_IN_2/C','Analog_IN_2{C}');%%%%%%%%%%%%%%%%%%%%%%%%%
    ligne = strrep(ligne,'Analog OUT','Analog_OUT');%%%%%%%%%%%%%%%%%%%%%%%%%
    ligne = strrep(ligne,'Analog_OUT/V','Analog_OUT{V}');
    ligne = strrep(ligne,'(Q-Qo)/mA.h','Qc{mAh}');
    ligne = strrep(ligne,'Q charge/discharge/mA.h','Qp{mAh}');%10.40 bis
    ligne = strrep(ligne,'Q discharge/mA.h','Qdischarge{mAh}');%10.40 bis
    ligne = strrep(ligne,'Q charge/mA.h','Qcharge{mAh}');%10.40 bis
    ligne = strrep(ligne,'Energy discharge/W.h','Edischarge{Wh}');%10.40 bis
    ligne = strrep(ligne,'Energy charge/W.h','Echarge{Wh}');%10.40 bis
    ligne = strrep(ligne,'half cycle','half_cycle');%10.40 bis
    ligne = strrep(ligne,'<I>/mA','I{mA}');
    ligne = strrep(ligne,'P/W','Pp{W}');%v10.23
    ligne = strrep(ligne,'Capacity/mA.h','Capacity{mAh}');%v10.23
    ligne = strrep(ligne,'Efficiency/%','Efficiency{pc}');%10.40 bis
    ligne = strrep(ligne,'Capacitance ','Capacitance_');%v10.40 (Capacitance_charge o Capacitance_discharge)
    ligne = strrep(ligne,'/uF','{uF}');%v10.40 (microFarads)
    ligne = regexprep(ligne,'/.F','{uF}');%v10.40bis (microFarads avec letrte grecque)
    ligne = strrep(ligne,'cycle number','cycle_number');%v10.40bis
elseif strcmp(typeEssai,'GPI')%v10.23
    %variables du GPI: 'mode','ox/red','error','control changes','Ns changes','counter inc.','Ns','time/s','control/mA','Ewe/V','<I>/mA','(Q-Qo)/mA.h','Energy/W.h','Analog IN 1/V','P/W'
    ligne = strrep(ligne,'ox/red','ox_red');
    ligne = strrep(ligne,'control changes','control_changes');
    ligne = strrep(ligne,'Ns changes','Ns_changes');
    ligne = strrep(ligne,'counter inc.','counter');
    ligne = strrep(ligne,'control/mA','control{mA}');
    ligne = strrep(ligne,'dq/mA.h','dq{mAh}');
    ligne = strrep(ligne,'Analog IN ','Analog_IN_');%%%%%%%%%%%%%%%%%%%%%%%%%
    ligne = strrep(ligne,'Analog_IN_1/V','Analog_IN_1{V}');%%%%%%%%%%%%%%%%%%%%%%%%%
    ligne = strrep(ligne,'Analog_IN_1/C','Analog_IN_1{C}');%%%%%%%%%%%%%%%%%%%%%%%%%
    ligne = strrep(ligne,'Analog_IN_2/V','Analog_IN_2{V}');%%%%%%%%%%%%%%%%%%%%%%%%%
    ligne = strrep(ligne,'Analog_IN_2/C','Analog_IN_2{C}');%%%%%%%%%%%%%%%%%%%%%%%%%
    ligne = strrep(ligne,'Analog OUT','Analog_OUT');%%%%%%%%%%%%%%%%%%%%%%%%%
    ligne = strrep(ligne,'Analog_OUT/V','Analog_OUT{V}');
    ligne = strrep(ligne,'(Q-Qo)/mA.h','Qp{mAh}');
    ligne = strrep(ligne,'Energy/W.h','Ep{Wh}');
    ligne = strrep(ligne,'P/W','Pp{W}');
    ligne = strrep(ligne,'<I>/mA','I{mA}');
elseif strcmp(typeEssai,'GEIS') || strcmp(typeEssai,'PEIS')
    %variables du GEIS: 'freq','Re_Z','Im_Z','Z_mod','Z_angle','time','Ewe','I','cycle_number','Ewe_mod','I_mod','Re_Y','Im_Y','Y_mod','Y_angle'
    %%v10.23: Cs/uF,	Cp/uF
    ligne = strrep(ligne,'freq/Hz','freq{Hz}');
    ligne = strrep(ligne,'<I>/mA','I{mA}');
    ligne = strrep(ligne,'Re(Z)/Ohm','ReZ{Ohm}');
    ligne = strrep(ligne,'-Im(Z)/Ohm','ImZ{Ohm}');
    ligne = strrep(ligne,'|Z|/Ohm','Zmod{Ohm}');
    ligne = strrep(ligne,'Phase(Z)/deg','Zangle{deg}');
    ligne = strrep(ligne,'cycle number','cycle_number');
    ligne = strrep(ligne,'I Range','I_Range{A}');
    ligne = strrep(ligne,'|Ewe|/V','Umod{V}');
    
    ligne = strrep(ligne,'|I|/A','Imod{A}');
    ligne = strrep(ligne,'Re(Y)/Ohm-1','ReY{1_Ohm}');
    ligne = strrep(ligne,'Im(Y)/Ohm-1','ImY{1_Ohm}');
    ligne = strrep(ligne,'|Y|/Ohm-1','Ymod{1_Ohm}');
    ligne = strrep(ligne,'Phase(Y)/deg','Yangle{deg}');
    ligne = regexprep(ligne,'Cs/.F','Cs{uF}');%LINUX
    ligne = regexprep(ligne,'Cp/.F','Cp{uF}');%LINUX
    ligne = strrep(ligne,'|Ece|/V','Ucemod{V}');%IFPen dans SIMCAL
    ligne = strrep(ligne,'|Zce|/Ohm','Zcemod{Ohm}');%IFPen dans SIMCAL
    ligne = strrep(ligne,'Re(Zce)/Ohm','ReZce{Ohm}');%IFPen dans SIMCAL
    ligne = strrep(ligne,'-Im(Zce)/Ohm','ImZce{Ohm}');%IFPen dans SIMCAL
    ligne = strrep(ligne,'Phase(Zce)/deg','ZangleCe{deg}');%IFPen dans SIMCAL
    ligne = strrep(ligne,'Phase(Zwe-ce)/deg','ZangleWeCe{deg}');%IFPen dans SIMCAL
    ligne = strrep(ligne,'|Zwe-ce|/Ohm','ZWeCe{Ohm}');%IFPen dans SIMCAL
    ligne = strrep(ligne,'Re(Zwe-ce)/Ohm','ReZWeCe{Ohm}');%IFPen dans SIMCAL
    ligne = strrep(ligne,'-Im(Zwe-ce)/Ohm','ImZWeCe{Ohm}');%IFPen dans SIMCAL
    
    ligne = strrep(ligne,'P/W','Pp{W}');%v11.20
    
elseif strcmp(typeEssai,'OCV')
    %variables du OCV: 'mode','error','time','Ewe','Analog_IN_1'
    ligne = strrep(ligne,'Analog IN ','Analog_IN_');
    ligne = strrep(ligne,'Analog_IN_1/V','Analog_IN_1{V}');
    ligne = strrep(ligne,'Analog_IN_1/C','Analog_IN_1{C}');
    ligne = strrep(ligne,'Analog_IN_2/V','Analog_IN_2{V}');
    ligne = strrep(ligne,'Analog_IN_2/C','Analog_IN_2{C}');
    ligne = strrep(ligne,'Analog OUT','Analog_OUT');
    ligne = strrep(ligne,'Analog_OUT/V','Analog_OUT{V}');
    ligne = strrep(ligne,'<I>/mA','I{mA}');
elseif strcmp(typeEssai,'Wait')
    %variables du Wait: 'mode','error','time/s','Ewe/V','I/mA','Analog IN 1/V','P/W','Analog OUT/V'
    ligne = strrep(ligne,'Analog IN ','Analog_IN_');
    ligne = strrep(ligne,'Analog_IN_1/V','Analog_IN_1{V}');
    ligne = strrep(ligne,'Analog_IN_1/C','Analog_IN_1{C}');
    ligne = strrep(ligne,'Analog_IN_2/V','Analog_IN_2{V}');
    ligne = strrep(ligne,'Analog_IN_2/C','Analog_IN_2{C}');
    ligne = strrep(ligne,'Analog OUT','Analog_OUT');
    ligne = strrep(ligne,'Analog_OUT/V','Analog_OUT{V}');
    ligne = strrep(ligne,'P/W','Pp{W}');
    ligne = strrep(ligne,'I/mA','I{mA}');
elseif strcmp(typeEssai,'MB') %modulo bat
    ligne = strrep(ligne,'ox/red','ox_red');
    ligne = strrep(ligne,'control changes','control_changes');
    ligne = strrep(ligne,'Ns changes','Ns_changes');
    ligne = strrep(ligne,'counter inc.','counter');
    ligne = strrep(ligne,'control/mA','control{mA}');
    ligne = strrep(ligne,'control/V/mA','control{V_or_mA}');
    ligne = strrep(ligne,'control/V','control{V}');%202101 v1.37?
    ligne = strrep(ligne,'dq/mA.h','dq{mAh}');
    ligne = strrep(ligne,'Analog IN ','Analog_IN_');%%%%%%%%%%%%%%%%%%%%%%%%%
    ligne = strrep(ligne,'Analog_IN_1/V','Analog_IN_1{V}');%%%%%%%%%%%%%%%%%%%%%%%%%
    ligne = strrep(ligne,'Analog_IN_1/C','Analog_IN_1{C}');%%%%%%%%%%%%%%%%%%%%%%%%%
    ligne = strrep(ligne,'Analog_IN_2/V','Analog_IN_2{V}');%%%%%%%%%%%%%%%%%%%%%%%%%
    ligne = strrep(ligne,'Analog_IN_2/C','Analog_IN_2{C}');%%%%%%%%%%%%%%%%%%%%%%%%%
    ligne = strrep(ligne,'Analog OUT','Analog_OUT');%%%%%%%%%%%%%%%%%%%%%%%%%
    ligne = strrep(ligne,'Analog_OUT/V','Analog_OUT{V}');
%     ligne = strrep(ligne,'(Q-Qo)/mA.h','Qp{mAh}');
    ligne = strrep(ligne,'(Q-Qo)/mA.h','Qc{mAh}');%v11.20
    ligne = strrep(ligne,'Q charge/discharge/mA.h','Qp{mAh}');%v11.20
    ligne = strrep(ligne,'Q discharge/mA.h','Qdischarge{mAh}');%v11.20
    ligne = strrep(ligne,'Q charge/mA.h','Qcharge{mAh}');%v11.20
    ligne = strrep(ligne,'Energy discharge/W.h','Edischarge{Wh}');%v11.20
    ligne = strrep(ligne,'Energy charge/W.h','Echarge{Wh}');%v11.20
    ligne = strrep(ligne,'<I>/mA','I{mA}');
    ligne = strrep(ligne,'P/W','Pp{W}');%v10.23
    ligne = strrep(ligne,'Capacity/mA.h','Capacity{mAh}');%v10.23
    ligne = strrep(ligne,'I Range','I_Range');%v11.20
    ligne = strrep(ligne,'half cycle','half_cycle');%v11.20
    ligne = strrep(ligne,'Capacitance charge/uF','Capacitance_charge{uF}');%v11.20
    ligne = strrep(ligne,'Capacitance discharge/uF','Capacitance_discharge{uF}');%v11.20
    ligne = strrep(ligne,'Capacity/mA.h','Capacity{mAh}');%v11.20
    ligne = strrep(ligne,'Efficiency/%','Efficiency{pc}');%v11.20
    ligne = strrep(ligne,'cycle number','cycle_number');%v11.20
    ligne = strrep(ligne,'R/Ohm','R{Ohm}');%v11.20
    
    %EIS in MB techniques:
    ligne = strrep(ligne,'freq/Hz','freq{Hz}');
    ligne = strrep(ligne,'<I>/mA','I{mA}');
    ligne = strrep(ligne,'Re(Z)/Ohm','ReZ{Ohm}');
    ligne = strrep(ligne,'-Im(Z)/Ohm','ImZ{Ohm}');
    ligne = strrep(ligne,'|Z|/Ohm','Zmod{Ohm}');
    ligne = strrep(ligne,'Phase(Z)/deg','Zangle{deg}');
    ligne = strrep(ligne,'cycle number','cycle_number');
    ligne = strrep(ligne,'I Range','I_Range{A}');
    ligne = strrep(ligne,'|Ewe|/V','Umod{V}');
    
    ligne = strrep(ligne,'|I|/A','Imod{A}');
    ligne = strrep(ligne,'Re(Y)/Ohm-1','ReY{1_Ohm}');
    ligne = strrep(ligne,'Im(Y)/Ohm-1','ImY{1_Ohm}');
    ligne = strrep(ligne,'|Y|/Ohm-1','Ymod{1_Ohm}');
    ligne = strrep(ligne,'Phase(Y)/deg','Yangle{deg}');
    ligne = regexprep(ligne,'Cs/.F','Cs{uF}');%LINUX
    ligne = regexprep(ligne,'Cp/.F','Cp{uF}');%LINUX
    ligne = strrep(ligne,'|Ece|/V','Ucemod{V}');%IFPen dans SIMCAL
    ligne = strrep(ligne,'|Zce|/Ohm','Zcemod{Ohm}');%IFPen dans SIMCAL
    ligne = strrep(ligne,'Re(Zce)/Ohm','ReZce{Ohm}');%IFPen dans SIMCAL
    ligne = strrep(ligne,'-Im(Zce)/Ohm','ImZce{Ohm}');%IFPen dans SIMCAL
    ligne = strrep(ligne,'Phase(Zce)/deg','ZangleCe{deg}');%IFPen dans SIMCAL
    ligne = strrep(ligne,'Phase(Zwe-ce)/deg','ZangleWeCe{deg}');%IFPen dans SIMCAL
    ligne = strrep(ligne,'|Zwe-ce|/Ohm','ZWeCe{Ohm}');%IFPen dans SIMCAL
    ligne = strrep(ligne,'Re(Zwe-ce)/Ohm','ReZWeCe{Ohm}');%IFPen dans SIMCAL
    ligne = strrep(ligne,'-Im(Zwe-ce)/Ohm','ImZWeCe{Ohm}');%IFPen dans SIMCAL
    
    ligne = strrep(ligne,'P/W','Pp{W}');%v11.20
else %essai inconnu comme MB (2021/08 v11.36)
    ligne = strrep(ligne,'ox/red','ox_red');
    ligne = strrep(ligne,'control changes','control_changes');
    ligne = strrep(ligne,'Ns changes','Ns_changes');
    ligne = strrep(ligne,'counter inc.','counter');
    ligne = strrep(ligne,'control/mA','control{mA}');
    ligne = strrep(ligne,'control/V/mA','control{V_or_mA}');
    ligne = strrep(ligne,'control/V','control{V}');%202101 v1.37?
    ligne = strrep(ligne,'dq/mA.h','dq{mAh}');
    ligne = strrep(ligne,'Analog IN ','Analog_IN_');%%%%%%%%%%%%%%%%%%%%%%%%%
    ligne = strrep(ligne,'Analog_IN_1/V','Analog_IN_1{V}');%%%%%%%%%%%%%%%%%%%%%%%%%
    ligne = strrep(ligne,'Analog_IN_1/C','Analog_IN_1{C}');%%%%%%%%%%%%%%%%%%%%%%%%%
    ligne = strrep(ligne,'Analog_IN_2/V','Analog_IN_2{V}');%%%%%%%%%%%%%%%%%%%%%%%%%
    ligne = strrep(ligne,'Analog_IN_2/C','Analog_IN_2{C}');%%%%%%%%%%%%%%%%%%%%%%%%%
    ligne = strrep(ligne,'Analog OUT','Analog_OUT');%%%%%%%%%%%%%%%%%%%%%%%%%
    ligne = strrep(ligne,'Analog_OUT/V','Analog_OUT{V}');
%     ligne = strrep(ligne,'(Q-Qo)/mA.h','Qp{mAh}');
    ligne = strrep(ligne,'(Q-Qo)/mA.h','Qc{mAh}');%v11.20
    ligne = strrep(ligne,'Q charge/discharge/mA.h','Qp{mAh}');%v11.20
    ligne = strrep(ligne,'Q discharge/mA.h','Qdischarge{mAh}');%v11.20
    ligne = strrep(ligne,'Q charge/mA.h','Qcharge{mAh}');%v11.20
    ligne = strrep(ligne,'Energy discharge/W.h','Edischarge{Wh}');%v11.20
    ligne = strrep(ligne,'Energy charge/W.h','Echarge{Wh}');%v11.20
    ligne = strrep(ligne,'<I>/mA','I{mA}');
    ligne = strrep(ligne,'P/W','Pp{W}');%v10.23
    ligne = strrep(ligne,'Capacity/mA.h','Capacity{mAh}');%v10.23
    ligne = strrep(ligne,'I Range','I_Range');%v11.20
    ligne = strrep(ligne,'half cycle','half_cycle');%v11.20
    ligne = strrep(ligne,'Capacitance charge/uF','Capacitance_charge{uF}');%v11.20
    ligne = strrep(ligne,'Capacitance discharge/uF','Capacitance_discharge{uF}');%v11.20
    ligne = strrep(ligne,'Capacity/mA.h','Capacity{mAh}');%v11.20
    ligne = strrep(ligne,'Efficiency/%','Efficiency{pc}');%v11.20
    ligne = strrep(ligne,'cycle number','cycle_number');%v11.20
    ligne = strrep(ligne,'R/Ohm','R{Ohm}');%v11.20
    
    %EIS in MB techniques:
    ligne = strrep(ligne,'freq/Hz','freq{Hz}');
    ligne = strrep(ligne,'<I>/mA','I{mA}');
    ligne = strrep(ligne,'Re(Z)/Ohm','ReZ{Ohm}');
    ligne = strrep(ligne,'-Im(Z)/Ohm','ImZ{Ohm}');
    ligne = strrep(ligne,'|Z|/Ohm','Zmod{Ohm}');
    ligne = strrep(ligne,'Phase(Z)/deg','Zangle{deg}');
    ligne = strrep(ligne,'cycle number','cycle_number');
    ligne = strrep(ligne,'I Range','I_Range{A}');
    ligne = strrep(ligne,'|Ewe|/V','Umod{V}');
    
    ligne = strrep(ligne,'|I|/A','Imod{A}');
    ligne = strrep(ligne,'Re(Y)/Ohm-1','ReY{1_Ohm}');
    ligne = strrep(ligne,'Im(Y)/Ohm-1','ImY{1_Ohm}');
    ligne = strrep(ligne,'|Y|/Ohm-1','Ymod{1_Ohm}');
    ligne = strrep(ligne,'Phase(Y)/deg','Yangle{deg}');
    ligne = regexprep(ligne,'Cs/.F','Cs{uF}');%LINUX
    ligne = regexprep(ligne,'Cp/.F','Cp{uF}');%LINUX
    ligne = strrep(ligne,'|Ece|/V','Ucemod{V}');%IFPen dans SIMCAL
    ligne = strrep(ligne,'|Zce|/Ohm','Zcemod{Ohm}');%IFPen dans SIMCAL
    ligne = strrep(ligne,'Re(Zce)/Ohm','ReZce{Ohm}');%IFPen dans SIMCAL
    ligne = strrep(ligne,'-Im(Zce)/Ohm','ImZce{Ohm}');%IFPen dans SIMCAL
    ligne = strrep(ligne,'Phase(Zce)/deg','ZangleCe{deg}');%IFPen dans SIMCAL
    ligne = strrep(ligne,'Phase(Zwe-ce)/deg','ZangleWeCe{deg}');%IFPen dans SIMCAL
    ligne = strrep(ligne,'|Zwe-ce|/Ohm','ZWeCe{Ohm}');%IFPen dans SIMCAL
    ligne = strrep(ligne,'Re(Zwe-ce)/Ohm','ReZWeCe{Ohm}');%IFPen dans SIMCAL
    ligne = strrep(ligne,'-Im(Zwe-ce)/Ohm','ImZWeCe{Ohm}');%IFPen dans SIMCAL
    
    ligne = strrep(ligne,'P/W','Pp{W}');%v11.20
end
ligne = strtrim(ligne);%bug v11.20: trailing espaces make extra-empty variable
variables = regexp(ligne,'\s','split');

expr = '{\w+}';
% [s e] = regexp(variables,expr, 'start', 'end','once');
% 
% for ind = 1 : length(variables)
%     unitNames{ind} = variables{ind}(s{ind}+1:e{ind}-1);
% end
% unitNames{cellfun(@isempty,unitNames)} = '';
unitNames = regexp(variables,expr, 'match', 'once');
unitNames = regexprep(unitNames,'{|}', '');
variableNames = regexprep(variables,expr,'');
end

