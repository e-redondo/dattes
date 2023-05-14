% First step: Run initpah_dattes

% Second step: download data for this demo:
% URL: https://cloud.univ-eiffel.fr/s/q5c5pBfKyzrHHT6
% password: demo_DATTES_23.05

% Third step: In MATLAB/Octave, go to the folder containing 20230414_1501_BUGE382_M3_L1_caracini.zip

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
##result = dattes_analyse(result,'C');
##dattes_plot(result,'C');

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
