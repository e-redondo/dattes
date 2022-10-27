%% Example of metadata:
% This is an example of DATTES metadata
% All fields are optionnal.
% You can use this example to create metadata files:
% 1. uncomment/edit some lines
% 2. run write_json_struct('your_filename.meta'), metadata)
% 3. place your metadata file properly:
% Each .meta file placed beside a folder with same name applies to all test
% files in this folder. Each .meta file placed beside a test file apply to
% this test file. E.g.:
% ├── [drwx------]  inr18650
% │   ├── [drwx------]  checkup_tests
% │   │   ├── [drwx------]  cell1
% │   │   │   ├── [-rwx------]  20190102_1230_initial_checkup.csv
% │   │   │   ├── [-rwx------]  20190102_1230_initial_checkup.meta
% │   │   │   ├── [-rwx------]  20190202_1230_intermediary.csv
% │   │   │   ├── [-rwx------]  20190202_1230_intermediary.meta
% │   │   │   ├── [-rwx------]  20190302_1230_intermediary.csv
% │   │   │   ├── [-rwx------]  20190302_1230_intermediary.meta
% │   │   │   ├── [-rwx------]  20190402_1230_final.csv
% │   │   │   └── [-rwx------]  20190402_1230_final.meta
% │   │   ├── [-rwx------]  cell1.meta
% │   │   ├── [drwx------]  cell2
% │   │   ├── [-rwx------]  cell2.meta
% │   │   ├── [drwx------]  cell3
% │   │   └── [-rwx------]  cell3.meta
% │   ├── [-rwx------]  checkup_tests.meta
%
% In example above, checkup_tests.meta applies to all files under
% checkup_tests folder, then cell1.meta, cell2.meta, cell3.meta apply
% respectively to files under cell1, cell2, cell3 subfolders. Thas is,
% existing fields in preceding metadata will be overwritten by these ones.
% Finally, 20190102_1230_initial_checkup.meta applies only to csv file with
% same name.
%
% See also metadata_collector

metadata = struct;
%% 0. test information
% metadata.test.institution = 'Univ. Eiffel';
% metadata.test.laboratory = 'LICIT-ECO7';
% metadata.test.experimenter = 'Eduardo';
% metadata.test.datetime = '2022/06/22 08:30';
% metadata.test.temperature = 25; % ambient temperature
% metadata.test.purpose = 'capacity, HPPC, EIS';

%% 1. cell information
% metadata.cell.id = 'BUGE187'; % unique identifier
% metadata.cell.brand = 'Samsung';
% metadata.cell.model = 'INR18650_20R';
% metadata.cell.max_voltage = 4.2;
% metadata.cell.min_voltage = 2.5;
% metadata.cell.nom_voltage = 3.7;
% metadata.cell.nom_capacity = 2;
% metadata.cell.max_dis_current_cont = 22;
% metadata.cell.max_cha_current_cont = 4;
% metadata.cell.min_temperature = -20;%degC
% metadata.cell.max_temperature = 60;%degC
% metadata.cell.geometry = 'cylindrical';
% metadata.cell.dimensions = [18 65]; %LxWxH if prismatic, DxL if cylindrical (mm)
% metadata.cell.weight = 45; %(grams)
% metadata.cell.cathode = 'NMC'; %
% metadata.cell.anode = 'graphite'; %

%% 2. equipement information: cycler and climatic chamber
% metadata.cycler.brand = 'Bitrode';
% metadata.cycler.model = 'FTV60-250';
% metadata.cycler.voltage_resolution = 0.001;
% metadata.cycler.current_resolution = 0.01;
% metadata.cycler.cell_voltage_name = 'U1';%aux voltage measurement
% metadata.cycler.cell_temperature_name = 'T1';%cell temperature sensor
% metadata.chamber.brand = 'Friocell';
% metadata.chamber.model = 'Friocell 707';
% metadata.chamber.min_temperature = -30;%min temperature (degC)
% metadata.chamber.max_temperature = 100;%min temperature (degC)

%% 3. other info
% metadata.regional.date_format = 'yyyy/mm/dd';
% metadata.regional.time_format = 'HH:MM:SS.SSS';
