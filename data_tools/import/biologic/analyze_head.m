function [variable_names, unit_names, date_test, type_test, source_file,test_params] = analyze_head(file_name)
% analyze_head Analyse header and variables of biologic files
%
% [variable_names, unit_names, date_test, type_test, source_file] = analyze_head(file_name)
% Read the Biologic result file and analyse header and variables
%
% Usage:
% [variable_names, unit_names, date_test, type_test, source_file] = analyze_head(file_name)
% Inputs : 
% - file_name: Result file_name from the Biologic cycler
% Outputs : 
% - variable_names: [1xn cell] Names of the variables
% - unit_names: [1xn cell] Names of the variables units
% - date_test: [1xn cell] Date of the test
% - type_test: [1xn cell] Type of the test
% - source_file: [1xn cell] Source file
%
%   See also biologic_head, import_biologic
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

[head, date_test, type_test, source_file, empty_file,test_params] = biologic_head(file_name);

[variable_names, unit_names] = analyseVariables(head{end}, type_test);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%function [variable_names unit_names] = analyseVariables(line, type_test)
function [variable_names, unit_names] = analyseVariables(line, type_test)
%variables
variable_names = cell(0);
unit_names = cell(0);
%variables communes:
line = strrep(line,'time/s','tc{s}');
line = strrep(line,'Ewe/V','U{V}');%OVC SCGPL
line = strrep(line,'I/mA','I{mA}');%MB et autres?
line = strrep(line,'Energy/W.h','Energy{Wh}');%MB et autres?
line = strrep(line,'|Energy|/W.h','Energy{Wh}');%MB et autres?
line = strrep(line,'<Ewe>/V','U{V}');%GEIS
line = regexprep(line,'Ewe-Ece/V','EweEceDiff{V}');%IFPen dans SIMCAL
line = regexprep(line,'Ece/V','Ece{V}');%IFPen dans SIMCAL
line = regexprep(line,'<Ece>/V','Ece{V}');%MB GEIS, 2022-07

line = regexprep(line,'z cycle','z_cycle');%202101 v1.31 MB et autres?
line(line==65533)='u';%v10.40 'micro' par 'u'
%BT-Lab
%line(line=='µ')='u';%EC-LAB mars 2021
line(line==181)='u';%EC-LAB mars 2021, adapted to octave
line = strrep(line,'°C','degC');%BT-LAB mars 2021
line = strrep(line,'Temperature/degC','Temperature{degC}');%BT-LAB mars 2021
line = strrep(line,'Ecell/V','U{V}');%OVC SCGPL
line = regexprep(line,'Temperature/.C','T{degC}');%2023: file encoding problems with degres
line = strrep(line,'I Range','I_Range');%EC-Lab mars 2021 (GCPL)
line = strrep(line,'(Q-Qo)/mA.h','Qp{mAh}');%EC-Lab mars 2021 (GEIS)
line = strrep(line,'dq/mA.h','dq{mAh}');%EC-Lab mars 2021 (GEIS)
if strcmp(type_test,'SGCPL') || strcmp(type_test,'GCPL')
    %variables du SGCPL: 'mode','ox_red','error','control_changes','Ns_changes','counter','time','control','Ewe','dq','Analog_IN_1','I','Qp','x'
    %version: 10.23
    %variables du GCPL: 'mode','ox/red','error','control changes','Ns changes','counter inc.','Ns','time/s','control/V/mA','Ewe/V','dq/mA.h','Analog IN 1/V','P/W','<I>/mA','(Q-Qo)/mA.h','x','Capacity/mA.h'
    line = strrep(line,'ox/red','ox_red');
    line = strrep(line,'control changes','control_changes');
    line = strrep(line,'Ns changes','Ns_changes');
    line = strrep(line,'counter inc.','counter');
    line = strrep(line,'control/V/mA','control{V_or_mA}');
    line = strrep(line,'control/V','control{V}');%v10.40
    line = strrep(line,'control/mA','control{mA}');%v10.40
    line = strrep(line,'dq/mA.h','dq{mAh}');
    line = strrep(line,'Analog IN ','Analog_IN_');%%%%%%%%%%%%%%%%%%%%%%%%%
    line = strrep(line,'Analog_IN_1/V','Analog_IN_1{V}');%%%%%%%%%%%%%%%%%%%%%%%%%
    line = strrep(line,'Analog_IN_1/C','Analog_IN_1{C}');%%%%%%%%%%%%%%%%%%%%%%%%%
    line = strrep(line,'Analog_IN_2/V','Analog_IN_2{V}');%%%%%%%%%%%%%%%%%%%%%%%%%
    line = strrep(line,'Analog_IN_2/C','Analog_IN_2{C}');%%%%%%%%%%%%%%%%%%%%%%%%%
    line = strrep(line,'Analog OUT','Analog_OUT');%%%%%%%%%%%%%%%%%%%%%%%%%
    line = strrep(line,'Analog_OUT/V','Analog_OUT{V}');
    line = strrep(line,'(Q-Qo)/mA.h','Qc{mAh}');
    line = strrep(line,'Q charge/discharge/mA.h','Qp{mAh}');%10.40 bis
    line = strrep(line,'Q discharge/mA.h','Qdischarge{mAh}');%10.40 bis
    line = strrep(line,'Q charge/mA.h','Qcharge{mAh}');%10.40 bis
    line = strrep(line,'Energy discharge/W.h','Edischarge{Wh}');%10.40 bis
    line = strrep(line,'Energy charge/W.h','Echarge{Wh}');%10.40 bis
    line = strrep(line,'half cycle','half_cycle');%10.40 bis
    line = strrep(line,'<I>/mA','I{mA}');
    line = strrep(line,'P/W','Pp{W}');%v10.23
    line = strrep(line,'Capacity/mA.h','Capacity{mAh}');%v10.23
    line = strrep(line,'Efficiency/%','Efficiency{pc}');%10.40 bis
    line = strrep(line,'Capacitance ','Capacitance_');%v10.40 (Capacitance_charge o Capacitance_discharge)
    line = strrep(line,'/uF','{uF}');%v10.40 (microFarads)
    line = regexprep(line,'/.F','{uF}');%v10.40bis (microFarads avec letrte grecque)
    line = strrep(line,'cycle number','cycle_number');%v10.40bis
elseif strcmp(type_test,'GPI')%v10.23
    %variables du GPI: 'mode','ox/red','error','control changes','Ns changes','counter inc.','Ns','time/s','control/mA','Ewe/V','<I>/mA','(Q-Qo)/mA.h','Energy/W.h','Analog IN 1/V','P/W'
    line = strrep(line,'ox/red','ox_red');
    line = strrep(line,'control changes','control_changes');
    line = strrep(line,'Ns changes','Ns_changes');
    line = strrep(line,'counter inc.','counter');
    line = strrep(line,'control/mA','control{mA}');
    line = strrep(line,'dq/mA.h','dq{mAh}');
    line = strrep(line,'Analog IN ','Analog_IN_');%%%%%%%%%%%%%%%%%%%%%%%%%
    line = strrep(line,'Analog_IN_1/V','Analog_IN_1{V}');%%%%%%%%%%%%%%%%%%%%%%%%%
    line = strrep(line,'Analog_IN_1/C','Analog_IN_1{C}');%%%%%%%%%%%%%%%%%%%%%%%%%
    line = strrep(line,'Analog_IN_2/V','Analog_IN_2{V}');%%%%%%%%%%%%%%%%%%%%%%%%%
    line = strrep(line,'Analog_IN_2/C','Analog_IN_2{C}');%%%%%%%%%%%%%%%%%%%%%%%%%
    line = strrep(line,'Analog OUT','Analog_OUT');%%%%%%%%%%%%%%%%%%%%%%%%%
    line = strrep(line,'Analog_OUT/V','Analog_OUT{V}');
    line = strrep(line,'(Q-Qo)/mA.h','Qp{mAh}');
    line = strrep(line,'Energy/W.h','Ep{Wh}');
    line = strrep(line,'P/W','Pp{W}');
    line = strrep(line,'<I>/mA','I{mA}');
elseif strcmp(type_test,'GEIS') || strcmp(type_test,'PEIS')
    %variables du GEIS: 'freq','Re_Z','Im_Z','Z_mod','Z_angle','time','Ewe','I','cycle_number','Ewe_mod','I_mod','Re_Y','Im_Y','Y_mod','Y_angle'
    %%v10.23: Cs/uF,	Cp/uF
    line = strrep(line,'freq/Hz','freq{Hz}');
    line = strrep(line,'<I>/mA','I{mA}');
    line = strrep(line,'Re(Z)/Ohm','ReZ{Ohm}');
    line = strrep(line,'-Im(Z)/Ohm','ImZ{Ohm}');
    line = strrep(line,'|Z|/Ohm','Zmod{Ohm}');
    line = strrep(line,'Phase(Z)/deg','Zangle{deg}');
    line = strrep(line,'cycle number','cycle_number');
    line = strrep(line,'I Range','I_Range{A}');
    line = strrep(line,'|Ewe|/V','Umod{V}');
    
    line = strrep(line,'|I|/A','Imod{A}');
    line = strrep(line,'Re(Y)/Ohm-1','ReY{1_Ohm}');
    line = strrep(line,'Im(Y)/Ohm-1','ImY{1_Ohm}');
    line = strrep(line,'|Y|/Ohm-1','Ymod{1_Ohm}');
    line = strrep(line,'Phase(Y)/deg','Yangle{deg}');
    line = regexprep(line,'Cs/.F','Cs{uF}');%LINUX
    line = regexprep(line,'Cp/.F','Cp{uF}');%LINUX
    line = strrep(line,'|Ece|/V','Ucemod{V}');%IFPen dans SIMCAL
    line = strrep(line,'|Zce|/Ohm','Zcemod{Ohm}');%IFPen dans SIMCAL
    line = strrep(line,'Re(Zce)/Ohm','ReZce{Ohm}');%IFPen dans SIMCAL
    line = strrep(line,'-Im(Zce)/Ohm','ImZce{Ohm}');%IFPen dans SIMCAL
    line = strrep(line,'Phase(Zce)/deg','ZangleCe{deg}');%IFPen dans SIMCAL
    line = strrep(line,'Phase(Zwe-ce)/deg','ZangleWeCe{deg}');%IFPen dans SIMCAL
    line = strrep(line,'|Zwe-ce|/Ohm','ZWeCe{Ohm}');%IFPen dans SIMCAL
    line = strrep(line,'Re(Zwe-ce)/Ohm','ReZWeCe{Ohm}');%IFPen dans SIMCAL
    line = strrep(line,'-Im(Zwe-ce)/Ohm','ImZWeCe{Ohm}');%IFPen dans SIMCAL
    
    line = strrep(line,'P/W','Pp{W}');%v11.20
    
elseif strcmp(type_test,'OCV')
    %variables du OCV: 'mode','error','time','Ewe','Analog_IN_1'
    line = strrep(line,'Analog IN ','Analog_IN_');
    line = strrep(line,'Analog_IN_1/V','Analog_IN_1{V}');
    line = strrep(line,'Analog_IN_1/C','Analog_IN_1{C}');
    line = strrep(line,'Analog_IN_2/V','Analog_IN_2{V}');
    line = strrep(line,'Analog_IN_2/C','Analog_IN_2{C}');
    line = strrep(line,'Analog OUT','Analog_OUT');
    line = strrep(line,'Analog_OUT/V','Analog_OUT{V}');
    line = strrep(line,'<I>/mA','I{mA}');
elseif strcmp(type_test,'Wait')
    %variables du Wait: 'mode','error','time/s','Ewe/V','I/mA','Analog IN 1/V','P/W','Analog OUT/V'
    line = strrep(line,'Analog IN ','Analog_IN_');
    line = strrep(line,'Analog_IN_1/V','Analog_IN_1{V}');
    line = strrep(line,'Analog_IN_1/C','Analog_IN_1{C}');
    line = strrep(line,'Analog_IN_2/V','Analog_IN_2{V}');
    line = strrep(line,'Analog_IN_2/C','Analog_IN_2{C}');
    line = strrep(line,'Analog OUT','Analog_OUT');
    line = strrep(line,'Analog_OUT/V','Analog_OUT{V}');
    line = strrep(line,'P/W','Pp{W}');
    line = strrep(line,'I/mA','I{mA}');
elseif strcmp(type_test,'MB') %modulo bat
    line = strrep(line,'ox/red','ox_red');
    line = strrep(line,'control changes','control_changes');
    line = strrep(line,'Ns changes','Ns_changes');
    line = strrep(line,'counter inc.','counter');
    line = strrep(line,'control/mA','control{mA}');
    line = strrep(line,'control/V/mA','control{V_or_mA}');
    line = strrep(line,'control/V','control{V}');%202101 v1.37?
    line = strrep(line,'dq/mA.h','dq{mAh}');
    line = strrep(line,'Analog IN ','Analog_IN_');%%%%%%%%%%%%%%%%%%%%%%%%%
    line = strrep(line,'Analog_IN_1/V','Analog_IN_1{V}');%%%%%%%%%%%%%%%%%%%%%%%%%
    line = strrep(line,'Analog_IN_1/C','Analog_IN_1{C}');%%%%%%%%%%%%%%%%%%%%%%%%%
    line = strrep(line,'Analog_IN_2/V','Analog_IN_2{V}');%%%%%%%%%%%%%%%%%%%%%%%%%
    line = strrep(line,'Analog_IN_2/C','Analog_IN_2{C}');%%%%%%%%%%%%%%%%%%%%%%%%%
    line = strrep(line,'Analog OUT','Analog_OUT');%%%%%%%%%%%%%%%%%%%%%%%%%
    line = strrep(line,'Analog_OUT/V','Analog_OUT{V}');
%     line = strrep(line,'(Q-Qo)/mA.h','Qp{mAh}');
    line = strrep(line,'(Q-Qo)/mA.h','Qc{mAh}');%v11.20
    line = strrep(line,'Q charge/discharge/mA.h','Qp{mAh}');%v11.20
    line = strrep(line,'Q discharge/mA.h','Qdischarge{mAh}');%v11.20
    line = strrep(line,'Q charge/mA.h','Qcharge{mAh}');%v11.20
    line = strrep(line,'Energy discharge/W.h','Edischarge{Wh}');%v11.20
    line = strrep(line,'Energy charge/W.h','Echarge{Wh}');%v11.20
    line = strrep(line,'<I>/mA','I{mA}');
    line = strrep(line,'P/W','Pp{W}');%v10.23
    line = strrep(line,'Capacity/mA.h','Capacity{mAh}');%v10.23
    line = strrep(line,'I Range','I_Range');%v11.20
    line = strrep(line,'half cycle','half_cycle');%v11.20
%     line = strrep(line,'Capacitance charge/uF','Capacitance_charge{uF}');%v11.20
%     line = strrep(line,'Capacitance discharge/uF','Capacitance_discharge{uF}');%v11.20
    line = strrep(line,'Capacitance ','Capacitance_');%v10.40 (Capacitance_charge o Capacitance_discharge)
    line = strrep(line,'/uF','{uF}');%v10.40 (microFarads)
    line = regexprep(line,'/.F','{uF}');%v10.40bis (microFarads avec letrte grecque)
    line = strrep(line,'Capacity/mA.h','Capacity{mAh}');%v11.20
    line = strrep(line,'Efficiency/%','Efficiency{pc}');%v11.20
    line = strrep(line,'cycle number','cycle_number');%v11.20
    line = strrep(line,'R/Ohm','R{Ohm}');%v11.20
    
    %EIS in MB techniques:
    line = strrep(line,'freq/Hz','freq{Hz}');
    line = strrep(line,'<I>/mA','I{mA}');
    line = strrep(line,'Re(Z)/Ohm','ReZ{Ohm}');
    line = strrep(line,'-Im(Z)/Ohm','ImZ{Ohm}');
    line = strrep(line,'|Z|/Ohm','Zmod{Ohm}');
    line = strrep(line,'Phase(Z)/deg','Zangle{deg}');
    line = strrep(line,'cycle number','cycle_number');
    line = strrep(line,'I Range','I_Range{A}');
    line = strrep(line,'|Ewe|/V','Umod{V}');
    
    line = strrep(line,'|I|/A','Imod{A}');
    line = strrep(line,'Re(Y)/Ohm-1','ReY{1_Ohm}');
    line = strrep(line,'Im(Y)/Ohm-1','ImY{1_Ohm}');
    line = strrep(line,'|Y|/Ohm-1','Ymod{1_Ohm}');
    line = strrep(line,'Phase(Y)/deg','Yangle{deg}');
    line = regexprep(line,'Cs/.F','Cs{uF}');%LINUX
    line = regexprep(line,'Cp/.F','Cp{uF}');%LINUX
    line = strrep(line,'|Ece|/V','Ucemod{V}');%IFPen dans SIMCAL
    line = strrep(line,'|Zce|/Ohm','Zcemod{Ohm}');%IFPen dans SIMCAL
    line = strrep(line,'Re(Zce)/Ohm','ReZce{Ohm}');%IFPen dans SIMCAL
    line = strrep(line,'-Im(Zce)/Ohm','ImZce{Ohm}');%IFPen dans SIMCAL
    line = strrep(line,'Phase(Zce)/deg','ZangleCe{deg}');%IFPen dans SIMCAL
    line = strrep(line,'Phase(Zwe-ce)/deg','ZangleWeCe{deg}');%IFPen dans SIMCAL
    line = strrep(line,'|Zwe-ce|/Ohm','ZWeCe{Ohm}');%IFPen dans SIMCAL
    line = strrep(line,'Re(Zwe-ce)/Ohm','ReZWeCe{Ohm}');%IFPen dans SIMCAL
    line = strrep(line,'-Im(Zwe-ce)/Ohm','ImZWeCe{Ohm}');%IFPen dans SIMCAL
    
    line = strrep(line,'P/W','Pp{W}');%v11.20
else %essai inconnu comme MB (2021/08 v11.36)
    line = strrep(line,'ox/red','ox_red');
    line = strrep(line,'control changes','control_changes');
    line = strrep(line,'Ns changes','Ns_changes');
    line = strrep(line,'counter inc.','counter');
    line = strrep(line,'control/mA','control{mA}');
    line = strrep(line,'control/V/mA','control{V_or_mA}');
    line = strrep(line,'control/V','control{V}');%202101 v1.37?
    line = strrep(line,'dq/mA.h','dq{mAh}');
    line = strrep(line,'Analog IN ','Analog_IN_');%%%%%%%%%%%%%%%%%%%%%%%%%
    line = strrep(line,'Analog_IN_1/V','Analog_IN_1{V}');%%%%%%%%%%%%%%%%%%%%%%%%%
    line = strrep(line,'Analog_IN_1/C','Analog_IN_1{C}');%%%%%%%%%%%%%%%%%%%%%%%%%
    line = strrep(line,'Analog_IN_2/V','Analog_IN_2{V}');%%%%%%%%%%%%%%%%%%%%%%%%%
    line = strrep(line,'Analog_IN_2/C','Analog_IN_2{C}');%%%%%%%%%%%%%%%%%%%%%%%%%
    line = strrep(line,'Analog OUT','Analog_OUT');%%%%%%%%%%%%%%%%%%%%%%%%%
    line = strrep(line,'Analog_OUT/V','Analog_OUT{V}');
%     line = strrep(line,'(Q-Qo)/mA.h','Qp{mAh}');
    line = strrep(line,'(Q-Qo)/mA.h','Qc{mAh}');%v11.20
    line = strrep(line,'Q charge/discharge/mA.h','Qp{mAh}');%v11.20
    line = strrep(line,'Q discharge/mA.h','Qdischarge{mAh}');%v11.20
    line = strrep(line,'Q charge/mA.h','Qcharge{mAh}');%v11.20
    line = strrep(line,'Energy discharge/W.h','Edischarge{Wh}');%v11.20
    line = strrep(line,'Energy charge/W.h','Echarge{Wh}');%v11.20
    line = strrep(line,'<I>/mA','I{mA}');
    line = strrep(line,'P/W','Pp{W}');%v10.23
    line = strrep(line,'Capacity/mA.h','Capacity{mAh}');%v10.23
    line = strrep(line,'I Range','I_Range');%v11.20
    line = strrep(line,'half cycle','half_cycle');%v11.20
    line = strrep(line,'Capacitance charge/uF','Capacitance_charge{uF}');%v11.20
    line = strrep(line,'Capacitance discharge/uF','Capacitance_discharge{uF}');%v11.20
    line = strrep(line,'Capacity/mA.h','Capacity{mAh}');%v11.20
    line = strrep(line,'Efficiency/%','Efficiency{pc}');%v11.20
    line = strrep(line,'cycle number','cycle_number');%v11.20
    line = strrep(line,'R/Ohm','R{Ohm}');%v11.20
    
    %EIS in MB techniques:
    line = strrep(line,'freq/Hz','freq{Hz}');
    line = strrep(line,'<I>/mA','I{mA}');
    line = strrep(line,'Re(Z)/Ohm','ReZ{Ohm}');
    line = strrep(line,'-Im(Z)/Ohm','ImZ{Ohm}');
    line = strrep(line,'|Z|/Ohm','Zmod{Ohm}');
    line = strrep(line,'Phase(Z)/deg','Zangle{deg}');
    line = strrep(line,'cycle number','cycle_number');
    line = strrep(line,'I Range','I_Range{A}');
    line = strrep(line,'|Ewe|/V','Umod{V}');
    
    line = strrep(line,'|I|/A','Imod{A}');
    line = strrep(line,'Re(Y)/Ohm-1','ReY{1_Ohm}');
    line = strrep(line,'Im(Y)/Ohm-1','ImY{1_Ohm}');
    line = strrep(line,'|Y|/Ohm-1','Ymod{1_Ohm}');
    line = strrep(line,'Phase(Y)/deg','Yangle{deg}');
    line = regexprep(line,'Cs/.F','Cs{uF}');%LINUX
    line = regexprep(line,'Cp/.F','Cp{uF}');%LINUX
    line = strrep(line,'|Ece|/V','Ucemod{V}');%IFPen dans SIMCAL
    line = strrep(line,'|Zce|/Ohm','Zcemod{Ohm}');%IFPen dans SIMCAL
    line = strrep(line,'Re(Zce)/Ohm','ReZce{Ohm}');%IFPen dans SIMCAL
    line = strrep(line,'-Im(Zce)/Ohm','ImZce{Ohm}');%IFPen dans SIMCAL
    line = strrep(line,'Phase(Zce)/deg','ZangleCe{deg}');%IFPen dans SIMCAL
    line = strrep(line,'Phase(Zwe-ce)/deg','ZangleWeCe{deg}');%IFPen dans SIMCAL
    line = strrep(line,'|Zwe-ce|/Ohm','ZWeCe{Ohm}');%IFPen dans SIMCAL
    line = strrep(line,'Re(Zwe-ce)/Ohm','ReZWeCe{Ohm}');%IFPen dans SIMCAL
    line = strrep(line,'-Im(Zwe-ce)/Ohm','ImZWeCe{Ohm}');%IFPen dans SIMCAL
    
    line = strrep(line,'P/W','Pp{W}');%v11.20
end
line = strtrim(line);%bug v11.20: trailing espaces make extra-empty variable
variables = regexp(line,'\s','split');

expr = '{\w+}';
% [s e] = regexp(variables,expr, 'start', 'end','once');
% 
% for ind = 1 : length(variables)
%     unit_names{ind} = variables{ind}(s{ind}+1:e{ind}-1);
% end
% unit_names{cellfun(@isempty,unit_names)} = '';
unit_names = regexp(variables,expr, 'match', 'once');
unit_names = regexprep(unit_names,'{|}', '');
variable_names = regexprep(variables,expr,'');
end

