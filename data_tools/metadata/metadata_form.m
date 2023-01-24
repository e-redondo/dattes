function metadata = metadata_form


fprintf('Welcome to DATTES metadata survey.\n');
fprintf('This function allows to create DATTES metadata by answering some questions.\n');
fprintf('You can skip some questions with empty answers (hit ENTER).\n');


metadata = struct;

%% 0. test information
prompt = 'Do you want to fill test details (institution / laboratory / experimenter / datetime / temperature / purpose)? Y/N [N]: ';
answer = input(prompt,'s');

if strcmpi(answer,'Y')
    prompt = 'institution name (Univ. of ... / Center for ...)? ';
    answer = input(prompt,'s');
% metadata.test.institution = 'Univ. Eiffel';
if ~isempty(answer)
    metadata.test.institution = answer;
end
% metadata.test.laboratory = 'LICIT-ECO7';
    prompt = 'laboratory name (Battery Lab, ...)? ';
    answer = input(prompt,'s');
if ~isempty(answer)
    metadata.test.laboratory = answer;
end
% metadata.test.experimenter = 'Eduardo';
    prompt = 'experimenter name (e.g.: John Smith)? ';
    answer = input(prompt,'s');
if ~isempty(answer)
    metadata.test.experimenter = answer;
end
% metadata.test.datetime = '2022/06/22 08:30';
    prompt = 'date and time of test (e.g.: 2022/06/22 08:30)? ';
    answer = input(prompt,'s');
if ~isempty(answer)
    metadata.test.datetime = answer;
end
% metadata.test.temperature = 25; % ambient temperature
    prompt = 'test temperature? ';
    answer = input(prompt,'s');
    answer = str2num(answer);
if ~isempty(answer)
    metadata.test.temperature = answer;
end

% metadata.test.purpose = 'capacity, HPPC, EIS';
    prompt = 'test purpose (e.g. capacity measurement, cycling, etc.)? ';
    answer = input(prompt,'s');
if ~isempty(answer)
    metadata.test.purpose = answer;
end

end


%% 1. cell information
prompt = 'Do you want to fill cell details (id/brand/model/specs/etc.)? Y/N [N]: ';
answer = input(prompt,'s');

if strcmpi(answer,'Y')
% metadata.cell.id = 'BUGE187'; % unique identifier
    prompt = 'cell unique id (e.g. REF999)? ';
    answer = input(prompt,'s');
if ~isempty(answer)
    metadata.cell.id = answer;
end
% metadata.cell.brand = 'Samsung';
% metadata.test.purpose = 'capacity, HPPC, EIS';
    prompt = 'cell brand (e.g. Samsung, Panasonic, A123, etc.)? ';
    answer = input(prompt,'s');
if ~isempty(answer)
    metadata.cell.brand = answer;
end
% metadata.cell.model = 'INR18650_20R';
    prompt = 'cell model (e.g. INR18650_20R)? ';
    answer = input(prompt,'s');
if ~isempty(answer)
    metadata.cell.model = answer;
end
% metadata.cell.max_voltage = 4.2;
    prompt = 'cell max_voltage (e.g. 4.2)? ';
    answer = input(prompt,'s');
    answer = str2num(answer);
if ~isempty(answer)
    metadata.cell.max_voltage = answer;
end
% metadata.cell.min_voltage = 2.5;
    prompt = 'cell min_voltage (e.g. 2.5)?';
    answer = input(prompt,'s');
    answer = str2num(answer);
if ~isempty(answer)
    metadata.cell.min_voltage = answer;
end
% metadata.cell.nom_voltage = 3.7;
    prompt = 'cell nominal voltage (e.g. 3.7)?';
    answer = input(prompt,'s');
    answer = str2num(answer);
if ~isempty(answer)
    metadata.cell.nom_voltage = answer;
end
% metadata.cell.nom_capacity = 3.5;
    prompt = 'cell nominal capacity in Ah (e.g. 3.5)? ';
    answer = input(prompt,'s');
    answer = str2num(answer);
if ~isempty(answer)
    metadata.cell.nom_capacity = answer;
end
% metadata.cell.max_dis_current_cont = 22;
    prompt = 'cell max discharge current in Amps (e.g. 35)? ';
    answer = input(prompt,'s');
    answer = str2num(answer);
if ~isempty(answer)
    metadata.cell.max_dis_current_cont = answer;
end
% metadata.cell.max_cha_current_cont = 4;
    prompt = 'cell max charge current in Amps (e.g. 7)? ';
    answer = input(prompt,'s');
    answer = str2num(answer);
if ~isempty(answer)
    metadata.cell.max_cha_current_cont = answer;
end
% metadata.cell.min_temperature = -20;%degC
    prompt = 'cell minimal operating temperature in degC (e.g. -20)? ';
    answer = input(prompt,'s');
    answer = str2num(answer);
if ~isempty(answer)
    metadata.cell.min_temperature = answer;
end
% metadata.cell.max_temperature = 60;%degC
    prompt = 'cell maximal operating temperature in degC (e.g. 60)? ';
    answer = input(prompt,'s');
    answer = str2num(answer);
if ~isempty(answer)
    metadata.cell.max_temperature = answer;
end
% metadata.cell.geometry = 'cylindrical';
    prompt = 'cell geometry (e.g. prismatic, cylindrical)? ';
    answer = input(prompt,'s');
if ~isempty(answer)
    metadata.cell.geometry = answer;
end
% metadata.cell.dimensions = [18 65]; %LxWxH if prismatic, DxL if cylindrical (mm)
    prompt = 'cell dimensions LxWxH if prismatic, DxL if cylindrical (mm)(e.g. [18 65])? ';
    answer = input(prompt,'s');
    answer = str2num(answer);
if ~isempty(answer)
%TODO convert to number, check dimensions of array
    metadata.cell.dimensions = answer;
end
% metadata.cell.weight = 45; %(grams)
    prompt = 'cell weight in grams (e.g. 45)? ';
    answer = input(prompt,'s');
    answer = str2num(answer);
if ~isempty(answer)
    metadata.cell.weight = answer;
end
% metadata.cell.cathode = 'NMC'; %
    prompt = 'cell cathode (e.g. LCO, NMC)? ';
    answer = input(prompt,'s');
if ~isempty(answer)
    metadata.cell.cathode = answer;
end
% metadata.cell.anode = 'graphite'; %
    prompt = 'cell anode (e.g. graphite, LTO)? ';
    answer = input(prompt,'s');
if ~isempty(answer)
    metadata.cell.anode = answer;
end
end


%% 2. equipement information: cycler
prompt = 'Do you want to fill cycler details? Y/N [N]: ';
answer = input(prompt,'s');
if strcmpi(answer,'Y')
% metadata.cycler.brand = 'Bitrode';
    prompt = 'cycler brand (e.g. Bitrode, Arbin, Biologic)? ';
    answer = input(prompt,'s');
if ~isempty(answer)
    metadata.cycler.brand = answer;
end
% metadata.cycler.model = 'FTV60-250';
    prompt = 'cycler model (e.g. FTV60-250)? ';
    answer = input(prompt,'s');
if ~isempty(answer)
    metadata.cycler.model = answer;
end
% metadata.cycler.voltage_resolution = 0.001;
    prompt = 'cycler voltage resolution [Volts] (e.g. 0.001)? ';
    answer = input(prompt,'s');
if ~isempty(answer)
% TODO convert to number
    metadata.cycler.voltage_resolution = answer;
end
% metadata.cycler.current_resolution = 0.01;
    prompt = 'cycler current resolution [Amps] (e.g. 0.001)? ';
    answer = input(prompt,'s');
if ~isempty(answer)
% TODO convert to number
    metadata.cycler.current_resolution = answer;
end
% metadata.cycler.cell_voltage_name = 'Voltage-1';%aux voltage measurement
    prompt = 'cycler cell voltage variable name (e.g. Voltage-1)? ';
    answer = input(prompt,'s');
if ~isempty(answer)
    metadata.cycler.cell_voltage_name = answer;
end
% metadata.cycler.cell_temperature_name = 'Temperature-1';%cell temperature sensor
    prompt = 'cycler cell temperature variable name (e.g. Temperature-1)? ';
    answer = input(prompt,'s');
if ~isempty(answer)
    metadata.cycler.cell_temperature_name = answer;
end
% metadata.chamber.brand = 'Friocell';
    prompt = 'chamber brand (e.g. Friocell, Vostch)? ';
    answer = input(prompt,'s');
if ~isempty(answer)
    metadata.cycler.brand = answer;
end
% metadata.chamber.model = 'Friocell 707';
    prompt = 'cycler model (e.g. Friocell 707)? ';
    answer = input(prompt,'s');
if ~isempty(answer)
    metadata.cycler.model = answer;
end
end
%% 3. equipement information: climatic chamnber
prompt = 'Do you want to fill climatic chamber details? Y/N [N]: ';
answer = input(prompt,'s');
if strcmpi(answer,'Y')
% metadata.chamber.brand = 'Friocell';
    prompt = 'chamber brand (e.g. Friocell, Vostch)? ';
    answer = input(prompt,'s');
if ~isempty(answer)
    metadata.chamber.brand = answer;
end
% metadata.chamber.model = 'Friocell 707';
    prompt = 'chamber model (e.g. Friocell 707)? ';
    answer = input(prompt,'s');
if ~isempty(answer)
    metadata.chamber.model = answer;
end
% metadata.cell.min_temperature = -20;%degC
    prompt = 'cell minimal operating temperature in degC (e.g. -20)? ';
    answer = input(prompt,'s');
    answer = str2num(answer);
if ~isempty(answer)
    metadata.cell.min_temperature = answer;
end
% metadata.cell.max_temperature = 60;%degC
    prompt = 'cell maximal operating temperature in degC (e.g. 60)? ';
    answer = input(prompt,'s');
    answer = str2num(answer);
if ~isempty(answer)
    metadata.cell.max_temperature = answer;
end
end
%% 4. other info
prompt = 'Do you want to fill regional details (date_format/time_format)? Y/N [N]: ';
answer = input(prompt,'s');
if strcmpi(answer,'Y')
% metadata.regional.date_format = 'yyyy/mm/dd';
    prompt = 'date format (e.g. yyyy/mm/dd)? ';
    answer = input(prompt,'s');
if ~isempty(answer)
    metadata.regional.date_format = answer;
end
% metadata.regional.time_format = 'HH:MM:SS.SSS';
    prompt = 'time format (e.g. HH:MM:SS.SSS)? ';
    answer = input(prompt,'s');
if ~isempty(answer)
    metadata.regional.time_format = answer;
end
end

%save result:
prompt = 'Save metadata in a file? Y/N [Y]: ';
answer = input(prompt,'s');
if strcmpi(answer,'Y') || isempty(answer)
   prompt = 'Does metada apply to a folder [D] or to a single file [F]? D/F [D]: ';
   answer = input(prompt,'s');
   if strcmpi(answer,'D') || isempty(answer)
       outfile = uigetdir();
       if ischar(outfile)
           outfile = [outfile '.meta'];
           write_json_struct(outfile, metadata);
       end
   end
   if strcmpi(answer,'F')
       outfile = uigetfile();
       if ischar(outfile)
           [D, F, E] = fileparts(outfile);
           outfile = [D, F, '.meta'];
           write_json_struct(outfile, metadata);
       end
   end

end

end
