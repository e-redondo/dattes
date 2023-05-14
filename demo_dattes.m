%% DATTES demo
% Thanks for trying DATTES !
% This script will present you the main features of DATTES.

% 1- Get all DATTES tools
% Before running, this script please collect all DATTES tools by running:
% initpath_dattes

% 2 - Get experimental data for this demo
% Experimental data for this demo are available with the following
% information
% URL: https://cloud.univ-eiffel.fr/s/q5c5pBfKyzrHHT6
% password: demo_DATTES_23.05

% 3- Go to the folder containing downloaded experimental data
% In MATLAB/Octave, go to the folder containing 20230414_1501_BUGE382_M3_L1_caracini.zip

% Important information 
% The shared file is very large leading to a rather slow analysis process.
% The long analysis duration is mainly due to the preprocessing function dattes_import.
% This function is the most time consuming, it is only necessary for the
% very first analysis.
% Future analysis will be much faster
function demo_dattes()

url = 'https://cloud.univ-eiffel.fr/s/q5c5pBfKyzrHHT6';
pass = 'demo_DATTES_23.05';
zip_file = '20230414_1501_BUGE382_M3_L1_caracini.zip';

zip_list = lsFiles('./','.zip');
zip_list = regexpFiltre(zip_list,zip_file);

if isempty(zip_list) % zip file not found in this folder or subfolders
    fprintf('Demo data not found, please download it from Univ. Eiffel cloud:\n');
    fprintf('URL: %s\n',url);
    fprintf('password: %s\n',pass);
    return
end

%get zip file full pathname and unzip it:
zip_file = zip_list{1};
unzip(zip_file,'./');


close all
clear all

% Import all biologic tests in src_folder:
% 'v' = verbose, 'm'= merge files in each folder to single xml file
xml_filelist = dattes_import('./','biologic','vm');


file_in = xml_filelist{1};

% Structure data: convert
result = dattes_structure(file_in,'v');
dattes_plot(result,'x');
dattes_plot(result,'p');

result = dattes_configure(result);
dattes_plot(result,'c');

% Capacity measurements
result = dattes_analyse(result,'C');
dattes_plot(result,'C');

% Resistance measurements
result = dattes_analyse(result,'R');
dattes_plot(result,'R');

% Impedance identification
result = dattes_analyse(result,'Z');
dattes_plot(result,'Z');

% OCV by points
result = dattes_analyse(result,'O');
dattes_plot(result,'O');


% pseudo OCV
result = dattes_analyse(result,'P');
dattes_plot(result,'P');

% Incremental Capacity Analysis
result = dattes_analyse(result,'I');
dattes_plot(result,'I');

%save results:
save_result(result);

end
