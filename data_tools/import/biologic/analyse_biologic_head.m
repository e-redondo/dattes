function [variable_names, unit_names, date_test, source_file,test_params] = analyse_biologic_head(file_name,header)
% analyse_biologic_head Analyse header and variables of biologic files
%
% [variable_names, unit_names, date_test, source_file, test_params] = analyse_biologic_head(file_name)
% Read the Biologic result file and analyse header and variables
%
% Usage(1):
% [variable_names, unit_names, date_test, type_test, source_file] = analyse_biologic_head(file_name)
% Usage(2):
% [variable_names, unit_names, date_test, type_test, source_file] = analyse_biologic_head(file_name,header)
% Inputs :
% - file_name [1xp char]:  pathname to the biologic results file (*.mpt)
% - header [nx1 cell]: header lines of the biologic results file (*.mpt)
% Outputs :
% - variable_names: [1xn cell] Names of the variables
% - unit_names: [1xn cell] Names of the variables units
% - date_test: [1xn cell] Date of the test
% - source_file: [1xn cell] Source file
% - test_params: [struct]  with fields
%       - type_test : [string]  Test type (GCPL, MB, GPI, GEIS, etc.)
%       - empty_file : [Boolean]  True if just header in file (no data)
%   See also import_biologic, read_biologic_file
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab:
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

if ~exist('head','var')
    [header, date_test, source_file, test_params] = biologic_head(file_name);
else
    [header, date_test, source_file, test_params] = biologic_head(file_name,header);
end
[variable_names, unit_names] = biologic_variables(header{end}, test_params);

%replace 'Ns' variable by 'step' to standardise with other cyclers:
variable_names = regexprep(variable_names,'^Ns$','step');

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%function [variable_names unit_names] = biologic_variables(line, test_params)
function [variable_names, unit_names] = biologic_variables(line, test_params)

type_test = test_params.type_test;
%variables
variable_names = cell(0);
unit_names = cell(0);
%variables communes:
line = strrep(line,' ','_');%replace every space in varname by underscore
line = strrep(line,'.','');%replace every dot in varname by nothing
line = strrep(line,'time/s','tc{s}');
line = strrep(line,'I/mA','I{mA}');%MB et autres?
line = strrep(line,'Rwe/Ohm','Rwe{Ohm}');%EC-Lab 11.61
line = strrep(line,'Rce/Ohm','Rce{Ohm}');%EC-Lab 11.61
line = strrep(line,'Rwe-ce/Ohm','Rwece{Ohm}');%EC-Lab 11.61
line = strrep(line,'Ewe/V','U{V}');%OVC SCGPL
line = strrep(line,'<Ewe>/V','U{V}');%GEIS
line = regexprep(line,'Ewe-Ece/V','EweEceDiff{V}');%IFPen dans SIMCAL
line = regexprep(line,'Ece/V','Ece{V}');%IFPen dans SIMCAL
line = regexprep(line,'<Ece>/V','Ece{V}');%MB GEIS, 2022-07

line = strrep(line,'U/V','U{V}');%COMUTES2 EIGSI files
line = regexprep(line,'Tamb/.C','Tamb{degC}');%COMUTES2 EIGSI files
line = regexprep(line,'Tcell/.C','Temperature{degC}');%COMUTES2 EIGSI files

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
line = strrep(line,'Analog_IN_1/V','Analog_IN_1{V}');%%%%%%%%%%%%%%%%%%%%%%%%%
line = strrep(line,'Analog_IN_1/C','Analog_IN_1{C}');%%%%%%%%%%%%%%%%%%%%%%%%%
line = strrep(line,'Analog_IN_2/V','Analog_IN_2{V}');%%%%%%%%%%%%%%%%%%%%%%%%%
line = strrep(line,'Analog_IN_2/C','Analog_IN_2{C}');%%%%%%%%%%%%%%%%%%%%%%%%%
line = strrep(line,'Analog OUT','Analog_OUT');%%%%%%%%%%%%%%%%%%%%%%%%%
line = strrep(line,'Analog_OUT/V','Analog_OUT{V}');

% step counter
line = strrep(line,'Ns changes','Ns_changes');

%Amp hours counters:
line = strrep(line,'dq/mAh','dq{mAh}');
line = strrep(line,'dq/mA.h','dq{mAh}');

line = strrep(line,'(Q-Qo)/mA.h','ah{mAh}');
line = strrep(line,'(Q-Qo)/mAh','ah{mAh}');

line = strrep(line,'Q_charge/discharge/mAh','Qp{mAh}');%10.40 bis
line = strrep(line,'Q charge/discharge/mA.h','Qp{mAh}');%v11.20

line = strrep(line,'Q_charge/mAh','ah_cha{mAh}');%10.40 bis
line = strrep(line,'Q charge/mA.h','ah_cha{mAh}');%v11.20line = strrep(line,'Energy/Wh','Ep{Wh}');
line = strrep(line,'Q discharge/mA.h','ah_dis{mAh}');%v11.20
line = strrep(line,'Q_discharge/mAh','ah_dis{mAh}');%10.40 bis
line = strrep(line,'Capacity/mAh','Capacity{mAh}');%v10.23

%energy
line = strrep(line,'Energy/Wh','Energy{Wh}');%MB et autres?
line = strrep(line,'|Energy|/Wh','Energy{Wh}');%MB et autres?
line = strrep(line,'Energy_charge/Wh','Energy_charge{Wh}');
line = strrep(line,'Energy_discharge/Wh','Energy_discharge{Wh}');
line = strrep(line,'Energy_we/Wh','Energy_we{Wh}');%EC-Lab 11.61
line = strrep(line,'Energy_we_charge/Wh','Energy_we_charge{Wh}');%EC-Lab 11.61
line = strrep(line,'Energy_we_discharge/Wh','Energy_we_discharge{Wh}');%EC-Lab 11.61
line = strrep(line,'Energy_ce/Wh','Energy_ce{Wh}');%EC-Lab 11.61
line = strrep(line,'Energy_we-ce/Wh','Energy_wece{Wh}');%EC-Lab 11.61

%power
line = strrep(line,'P/W','Pp{W}');%v10.23
line = strrep(line,'Pwe/W','Pwe{W}');%EC-Lab 11.61
line = strrep(line,'Pce/W','Pce{W}');%EC-Lab 11.61
line = strrep(line,'Pwe-ce/W','Pwece{W}');%EC-Lab 11.61


%Other
% line = strrep(line,'Capacitance ','Capacitance_');%v10.40 (Capacitance_charge o Capacitance_discharge)
line = strrep(line,'/uF','{uF}');%v10.40 (microFarads)
line = regexprep(line,'/.F','{uF}');%v10.40bis (microFarads avec letrte grecque)

if strcmp(type_test,'SGCPL') || strcmp(type_test,'GCPL')
    %variables du SGCPL: 'mode','ox_red','error','control_changes','Ns_changes','counter','time','control','Ewe','dq','Analog_IN_1','I','Qp','x'
    %version: 10.23
    %variables du GCPL: 'mode','ox/red','error','control changes','Ns changes','counter inc.','Ns','time/s','control/V/mA','Ewe/V','dq/mA.h','Analog IN 1/V','P/W','<I>/mA','(Q-Qo)/mA.h','x','Capacity/mA.h'
    line = strrep(line,'ox/red','ox_red');
    line = strrep(line,'control changes','control_changes');
    line = strrep(line,'counter inc.','counter');
    line = strrep(line,'control/V/mA','control{V_or_mA}');
    line = strrep(line,'control/V','control{V}');%v10.40
    line = strrep(line,'control/mA','control{mA}');%v10.40
    line = strrep(line,'Energy discharge/W.h','Edischarge{Wh}');%10.40 bis
    line = strrep(line,'Energy charge/W.h','Echarge{Wh}');%10.40 bis
    line = strrep(line,'half cycle','half_cycle');%10.40 bis
    line = strrep(line,'<I>/mA','I{mA}');
    line = strrep(line,'Efficiency/%','Efficiency{pc}');%10.40 bis
    line = strrep(line,'cycle number','cycle_number');%v10.40bis
elseif strcmp(type_test,'GPI')%v10.23
    %variables du GPI: 'mode','ox/red','error','control changes','Ns changes','counter inc.','Ns','time/s','control/mA','Ewe/V','<I>/mA','(Q-Qo)/mA.h','Energy/W.h','Analog IN 1/V','P/W'
    line = strrep(line,'ox/red','ox_red');
    line = strrep(line,'control changes','control_changes');
    line = strrep(line,'Ns changes','Ns_changes');
    line = strrep(line,'counter inc.','counter');
    line = strrep(line,'control/mA','control{mA}');
    line = strrep(line,'Analog IN ','Analog_IN_');%%%%%%%%%%%%%%%%%%%%%%%%%
    line = strrep(line,'Analog_IN_1/V','Analog_IN_1{V}');%%%%%%%%%%%%%%%%%%%%%%%%%
    line = strrep(line,'Analog_IN_1/C','Analog_IN_1{C}');%%%%%%%%%%%%%%%%%%%%%%%%%
    line = strrep(line,'Analog_IN_2/V','Analog_IN_2{V}');%%%%%%%%%%%%%%%%%%%%%%%%%
    line = strrep(line,'Analog_IN_2/C','Analog_IN_2{C}');%%%%%%%%%%%%%%%%%%%%%%%%%
    line = strrep(line,'Analog OUT','Analog_OUT');%%%%%%%%%%%%%%%%%%%%%%%%%
    line = strrep(line,'Analog_OUT/V','Analog_OUT{V}');
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
    %BTLab update 2024/10, a lot of new variables
    line = strrep(line,'Re(C)','ReC');
    line = strrep(line,'Im(C)','ImC');
    line = strrep(line,'|C|','Cmod');
    line = strrep(line,'Phase(C)/deg','Cangle{deg}');
    line = strrep(line,'Re(M)','ReM');
    line = strrep(line,'Im(M)','ImM');
    line = strrep(line,'|M|','Mmod');
    line = strrep(line,'Phase(M)/deg','Mangle{deg}');
    line = strrep(line,'Re(Permittivity)','RePermittivity');
    line = strrep(line,'Im(Permittivity)','ImPermittivity');
    line = strrep(line,'|Permittivity|','Permittivity_mod');
    line = strrep(line,'Phase(Permittivity)/deg','Permittivity_angle{deg}');
    line = strrep(line,'Re(Resistivity)/Ohmcm','ReResistivity{Ohmcm}');
    line = strrep(line,'Im(Resistivity)/Ohmcm','ImResistivity{Ohmcm}');
    line = strrep(line,'|Resistivity|/Ohmcm','Resistivity_mod{Ohmcm}');
    line = strrep(line,'Phase(Resistivity)/deg','Resistivity_angle{deg}');
    line = strrep(line,'Re(Conductivity)/mS/cm','ReConductivity{mS_cm}');
    line = strrep(line,'Im(Conductivity)/mS/cm','ImConductivity{mS_cm}');
    line = strrep(line,'|Conductivity|/mS/cm','Conductivity_mod{mS_cm}');
    line = strrep(line,'Phase(Conductivity)/deg','Conductivity_angle{deg}');
    line = strrep(line,'Tan(Delta)','Tan_Delta');
    line = strrep(line,'Loss_Angle(Delta)/deg','Loss_Angle_Delta{deg}');
    line = regexprep(line,'<Ewe-Ece>/V','EweEceDiff{V}');

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

    line = strrep(line,'I/mA','I{mA}');
elseif strcmp(type_test,'MB') %modulo bat
    line = strrep(line,'ox/red','ox_red');
    line = strrep(line,'control changes','control_changes');
    line = strrep(line,'Ns changes','Ns_changes');
    line = strrep(line,'counter inc.','counter');
    line = strrep(line,'control/mA','control{mA}');
    line = strrep(line,'control/V/mA','control{V_or_mA}');
    line = strrep(line,'control/V','control{V}');%202101 v1.37?
    line = strrep(line,'Analog IN ','Analog_IN_');%%%%%%%%%%%%%%%%%%%%%%%%%
    line = strrep(line,'Analog_IN_1/V','Analog_IN_1{V}');%%%%%%%%%%%%%%%%%%%%%%%%%
    line = strrep(line,'Analog_IN_1/C','Analog_IN_1{C}');%%%%%%%%%%%%%%%%%%%%%%%%%
    line = strrep(line,'Analog_IN_2/V','Analog_IN_2{V}');%%%%%%%%%%%%%%%%%%%%%%%%%
    line = strrep(line,'Analog_IN_2/C','Analog_IN_2{C}');%%%%%%%%%%%%%%%%%%%%%%%%%
    line = strrep(line,'Analog OUT','Analog_OUT');%%%%%%%%%%%%%%%%%%%%%%%%%
    line = strrep(line,'Analog_OUT/V','Analog_OUT{V}');
    line = strrep(line,'Energy discharge/W.h','Edischarge{Wh}');%v11.20
    line = strrep(line,'Energy charge/W.h','Echarge{Wh}');%v11.20
    line = strrep(line,'<I>/mA','I{mA}');

    line = strrep(line,'Capacity/mA.h','Capacity{mAh}');%v10.23
    line = strrep(line,'I Range','I_Range');%v11.20
    line = strrep(line,'half cycle','half_cycle');%v11.20
    %     line = strrep(line,'Capacitance charge/uF','Capacitance_charge{uF}');%v11.20
    %     line = strrep(line,'Capacitance discharge/uF','Capacitance_discharge{uF}');%v11.20
    line = strrep(line,'Capacitance ','Capacitance_');%v10.40 (Capacitance_charge o Capacitance_discharge)

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
    line = strrep(line,'Analog IN ','Analog_IN_');%%%%%%%%%%%%%%%%%%%%%%%%%
    line = strrep(line,'Analog_IN_1/V','Analog_IN_1{V}');%%%%%%%%%%%%%%%%%%%%%%%%%
    line = strrep(line,'Analog_IN_1/C','Analog_IN_1{C}');%%%%%%%%%%%%%%%%%%%%%%%%%
    line = strrep(line,'Analog_IN_2/V','Analog_IN_2{V}');%%%%%%%%%%%%%%%%%%%%%%%%%
    line = strrep(line,'Analog_IN_2/C','Analog_IN_2{C}');%%%%%%%%%%%%%%%%%%%%%%%%%
    line = strrep(line,'Analog OUT','Analog_OUT');%%%%%%%%%%%%%%%%%%%%%%%%%
    line = strrep(line,'Analog_OUT/V','Analog_OUT{V}');
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
%remove 'empty' variables (two consecutive column separators, from 2024/10 BT-Lab update)
ind_empty = cellfun(@isempty,variables);
variables = variables(~ind_empty);
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


function [head, date_test, source_file, test_params] = biologic_head(file_name,head)
% biologic_head Read and analyse .mpt Biologic files header
%
% Usage(1) :
% [head, date_test, type_test, source_file, test_params] = biologic_head(file_name)
% Usage(2) :
% [head, date_test, type_test, source_file, test_params] = biologic_head(file_name,head)
% Inputs :
%   - file_name: [string] Path to the Biologic file
%   - head: [(mx1) cell string] Header information
% Outputs :
%   - head: [(mx1) cell string] Header information
%   - date_test: [string]  Test date with format yyyymmdd_HHMMSS
%   - source_file: [string]  Source file
%   - test_params: [struct]  with fields
%       - type_test : [string]  Test type (GCPL, MB, GPI, GEIS, etc.)
%       - empty_file : [Boolean]  True if just header in file (no data)
%
% See also read_biologic_file, analyze_head
%
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab:
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

if nargin==0
    print_usage
end

date_test = '';

%1.-Reading file
if ~exist('head','var')

    [D, F, E] = fileparts(file_name);
    F = [F,E];
    fid = fopen_safe(file_name);
    if fid<0
        fprintf('biologic_head: Error in the file %s\n',F);
        return;
    end
    % [head] = read_biologic_file(fid);
    [head] = read_biologic_file(fid,true);
    if isempty(head)
        fprintf('biologic_head: Error in the file %s\n',F);
        return%on force l'erreur si pas ECLAB file
    end
    %     %check if it was last line in file
    %     ligne = fgetl(fid);
    %     if ligne == -1
    %         empty_file = true;
    %     else
    %         empty_file = false;
    %     end
    fclose(fid);
end

%2.- date essai
date_test = '';
ligneDate = regexpFiltre(head,'^Acquisition started on : ');
if ~isempty(ligneDate)
    date_test = regexprep(ligneDate{1},'^Acquisition started on : ','');
    aNum = datenum_guess(date_test);%default date format in MATLAB = Biologic MM/DD/YY
    date_test = datestr(aNum,'yymmdd_HHMMSS.FFF');%v10.23
else%try to deduct date time from file_name
    %try on file_name
    ligneDate = regexp(F,'^[0-9]{8,8}_[0-9]{4,4}','match','once');
    if isempty(ligneDate) %try on last level folder name
        [~, D1] = fileparts(D);
        ligneDate = regexp(D1,'^[0-9]{8,8}_[0-9]{4,4}','match','once');
    end
    if ~isempty(ligneDate)
        aNum = datenum_guess(ligneDate,'yyyymmdd_HHMM');
        date_test = datestr(aNum,'yymmdd_HHMMSS.FFF');
    end
end
%3.- type_test
if length(head)>3
    if  ~isempty(regexp(head{4},'^Special Galvanostatic Cycling with Potential Limitation'))
        type_test = 'SGCPL';
    elseif ~isempty(regexp(head{4},'^Galvanostatic Cycling with Potential Limitation'))
        type_test = 'GCPL';
    elseif ~isempty(regexp(head{4},'^Galvano Profile Importation'))
        type_test = 'GPI';
    elseif  ~isempty(regexp(head{4},'^Galvano Electrochemical Impedance Spectroscopy'))
        type_test = 'GEIS';
    elseif  ~isempty(regexp(head{4},'^Potentio Electrochemical Impedance Spectroscopy'))
        type_test = 'PEIS';
    elseif  ~isempty(regexp(head{4},'^Open Circuit Voltage'))
        type_test = 'OCV';
    elseif  ~isempty(regexp(head{4},'^Wait'))
        type_test = 'Wait';
    elseif  ~isempty(regexp(head{4},'^Modulo Bat'))
        type_test = 'MB';
    else
        type_test = 'inconnu';
    end
else
    if  ~isempty(strfind(file_name,'SGCPL'))
        type_test = 'SGCPL';
    elseif ~isempty(strfind(file_name,'GCPL'))
        type_test = 'GCPL';
    elseif ~isempty(strfind(file_name,'GPI'))
        type_test = 'GPI';
    elseif ~isempty(strfind(file_name,'GEIS'))
        type_test = 'GEIS';
    elseif ~isempty(strfind(file_name,'PEIS'))
        type_test = 'PEIS';
    elseif ~isempty(strfind(file_name,'OCV'))
        type_test = 'OCV';
    else
        type_test = 'inconnu';
    end
end
%4.- source_file
[s] = regexp(head,'([a-zA-Z%�_0-9-]+).mpr$','match','once');
indices = find(cellfun(@(x) ~isempty(x),s));
if length(indices)~=1%not found, mpt filename is considered
    [D source_file E] = fileparts(file_name);
    source_file = sprintf('%s%s',source_file,E);
else
    source_file = s{indices};
end
%5.- extra params
test_params = struct;
if strcmp(type_test,'GEIS')
    %average current
    Is_line = regexpFiltre(head,'^Is');
    if ~isempty(Is_line)
        %search for line containing Is setting:
        Is_line = regexp(Is_line{1},'\s+','split');
        Is_units = regexpFiltre(head,'unit Is');
        Is_units = regexp(Is_units{1},'\s+','split');

        Is = sscanf(Is_line{2},'%f');
        scale = 1;
        if strcmp(Is_units{3},'mA')
            scale = 0.001;%TODO other possible scales? µA?
        end
        test_params.Is = scale*Is;%convert to A
    end
    %current amplitude
    Ia_line = regexpFiltre(head,'^Ia\s+');
    if ~isempty(Is_line)
        %search for line containing Is setting:
        Ia_line = regexp(Ia_line{1},'\s+','split');
        Ia_units = regexpFiltre(head,'unit\s+Ia');
        Ia_units = regexp(Ia_units{1},'\s+','split');

        Ia = sscanf(Ia_line{2},'%f');
        scale = 1;
        if strcmp(Ia_units{3},'mA')
            scale = 0.001;%TODO other possible scales? µA?
        end
        test_params.Ia = scale*Ia;%convert to A
    end
    %TODO do the same for other test types, e.g. PEIS (Is?,Va, etc.)
elseif strcmp(type_test,'PEIS')
    %average voltage
    Vs_line = regexpFiltre(head,'^E \(.+\)');
    if ~isempty(Vs_line)
        %search for line containing Is setting:
        Vs_units = regexp(Vs_line{1},'\(.+\)','match','once');
        Vs_units = regexprep(Vs_units,'\(','');
        Vs_units = regexprep(Vs_units,'\)','');

        Vs_words = regexp(Vs_line{1},'\s+','split');
        Vs = cellfun(@(x) sscanf(x,'%f'),Vs_words,'UniformOutput',false);
        Ie = cellfun(@isempty,Vs);
        Vs = Vs{~Ie};

        scale = 1;
        if strcmp(Vs_units,'mV')
            scale = 0.001;%TODO other possible scales? µA?
        end
        test_params.Us = scale*Vs;%convert to V
    end
    %voltage amplitude
    Va_line = regexpFiltre(head,'^Va\s+');
    if ~isempty(Vs_line)
        Va_units = regexp(Va_line{1},'\(.+\)','match','once');
        Va_units = regexprep(Va_units,'\(','');
        Va_units = regexprep(Va_units,'\)','');

        Va_words = regexp(Va_line{1},'\s+','split');
        Va = cellfun(@(x) sscanf(x,'%f'),Va_words,'UniformOutput',false);
        Ie = cellfun(@isempty,Va);

        Va = Va{~Ie};
        scale = 1;
        if strcmp(Va_units,'mV')
            scale = 0.001;%TODO other possible scales? µV?
        end
        test_params.Ua = scale*Va;%convert to V
    end
    %TODO do the same for other test types, e.g. PEIS (Vs?,Va, etc.)
elseif strcmp(type_test,'MB')

    %get control type in line
    control_type_line = regexpFiltre(head,'^ctrl_type');
    control_types = regexp(control_type_line{1},'\s+','split');
    control_types = control_types(2:end-1);%remove first and last column as in Ns
    [~,~,geis_sequences] = regexpFiltre(control_types,'GEIS');
    [~,~,peis_sequences] = regexpFiltre(control_types,'PEIS');

    Ns = 0:length(control_types)-1;
    %get control val in line
    control_val1_line = regexpFiltre(head,'^ctrl1_val\s+');
    %get control unit in line
    control_unit1_line = regexpFiltre(head,'^ctrl1_val_unit\s+');

    %TODO: find Iavg in settings file. (control_val4?, ApplyI/C?)

    start_cuts = regexp(control_type_line{1},'\s[A-Z]')+1;
    end_cuts = [start_cuts(2:end)-1 length(control_val1_line{1})];
    for ind = 1:length(start_cuts)
        control_vals1{ind} = control_val1_line{1}(start_cuts(ind):end_cuts(ind));
        control_units1{ind} = control_unit1_line{1}(start_cuts(ind):end_cuts(ind));
    end

    % prevent comma decimal separator error
    control_vals1 = strrep(control_vals1,',','.');

    %convert string to numbers, fill empty values with nans
    control_vals1 = cellfun(@str2num,control_vals1,'UniformOutput',false);
    Ie = cellfun(@isempty,control_vals1);
    control_vals1(Ie) = {nan};
    %convert cell to array
    control_vals1 = cell2mat(control_vals1);

    scale = ones(size(Ns));
    [~,~,Ism] = regexpFiltre(control_units1,'mA');%TODO same for mV?
    [~,~,Usm] = regexpFiltre(control_units1,'mV');%TODO same for mV?
    scale(Ism) = 0.001;
    scale(Usm) = 0.001;
    %TODO, put values to avoid errors:
    test_params.Is = nan(size(Ns));%TODO
    test_params.Ia = control_vals1.*scale;
    test_params.Ia(~geis_sequences) = nan;
    %TODO, put values to avoid errors:
    test_params.Us = nan(size(Ns));%TODO
    test_params.Ua = control_vals1.*scale;
    test_params.Ua(~peis_sequences) = nan;

end

test_params.type_test = type_test;
% test_params.empty_file = empty_file;

end

