%DATTES Data Analysis Tools for Tests on Energy Storage
%
% (What DATTES is)
% DATTES is a software which have been developed in order to facilitate
% and accelerate data processing in the field of Energy Storage.
% It is written in MATLAB and all functions are GNU Octave compatible.
%
% With DATTES you can:
% - Read data from a large variety oy battery cyclers
% - Convert this data to standard formats
% - Prepare this data to be processed in an easy way
% - Perform most common analysis:
%     - Capacity
%     - Resistance
%     - Impedance
%     - OCV
%     - ICA/DVA
% - Visualise and export your results
%
% (DATTES Workflow)
% The DATTES workflow is composed of four steps:
% - dattes_import: Convert the cycler data to a standard format (XML).
% - dattes_structure: Preprocess data to easily analyse it.
% - dattes_configure: Customise the way you analyse your data.
% - dattes_analyse: Analyse your data.
%    
%
% (Other DATTES tools)
% - dattes_plot: Visualisation tool, you can plot every DATTES result
% - dattes_export: Export the results to easily inteact with other software
%   
%
% (Examples)
% DATTES let you work in different ways depending on the quantity and
% organisation  of your experimental data and your preferences.
%
% - Working with filelists: You can use filelists to process a batch of files
%       xml_list = dattes_import(list_of_arbin_files,'arbin_csv','v',dest_folder);
%       mat_list = lsFiles(dest_folder,'.mat');
%       dattes_configure(mat_list,'s');
%       dattes_analyse(mat_list,'sCP...');
%       dattes_plot(mat_list,'sCP...');
%
% - Working with folders: You can work directly with folders
%       dattes_import(raw_data_folder,'arbin_csv','v',dattes_folder);
%       dattes_structure(dattes_folder,'s');
%       dattes_configure(dattes_folder,'s');
%       dattes_analyse(dattes_folder,'sCP...');
%       dattes_plot(dattes_folder,'sCP...');
%
% - Working in workspace: you can do all operations in workspace and save later
%       xml_list = dattes_import(raw_data_folder,'arbin_csv','v',dattes_folder);
%       results = dattes_structure(xml_list,'s');
%       results = dattes_configure(results,'s');
%       results = dattes_analyse(results,'sCP...');
%       dattes_plot(results,'sCP...');
%       dattes_save(results);
%
%
% See also dattes_import, dattes_structure, dattes_configure,
% dattes_analyse, dattes_plot, dattes_export
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.


