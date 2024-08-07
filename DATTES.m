%DATTES Data Analysis Tools for Tests on Energy Storage
%
% (What DATTES is)
% DATTES is a software which have been developed in order to facilitate
% and accelerate data processing in the field of Energy Storage.
% It is written in MATLAB and all functions are GNU Octave compatible.
%
% With DATTES you can:
% - Read data from a large variety of battery cyclers
% - Convert this data to standard formats
% - Prepare this data to be processed in an easy way
% - Perform most common analysis:
%     - Capacity
%     - Resistance
%     - Impedance
%     - EIS
%     - OCV
%     - ICA/DVA
% - Visualise and export your results
%
% (DATTES Workflow)
% The DATTES workflow is composed of four steps:
%       - dattes_import: Convert the cycler data to a standard format (XML)
%       - dattes_structure: Preprocess data to easily analyse it
%       - dattes_configure: Customise the way you analyse your data
%       - dattes_analyse: Analyse your data
%
%
% (Other DATTES tools)
%       - dattes_plot: Visualisation tool, you can plot every DATTES result
%       - dattes_export: Export the results to easily interact with other software
%
%
% (Examples)
%       DATTES let you work in different ways depending on the quantity and
%       organisation of your experimental data and your preferences.
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
% (Getting started with DATTES)
% - initpath_dattes
%       To start using DATTES, you need run 'initpath_dattes' to add DATTES
%       code folders to your path.
% - demo_dattes
%       This script helps you to get some experimental data and shows you
%       the main features of DATTES.
%
% See also initpath_dattes, demo_dattes,dattes_import, dattes_structure,
% dattes_configure, dattes_analyse, dattes_plot, dattes_export
%
% DATTES website: https://dattes.gitlab.io/
% License : GNU GPL V3
% Software paper :
% Eduardo Redondo-Iglesias, Marwan Hassini, Pascal Venet and Serge Pelissier,
% DATTES: Data analysis tools for tests on energy storage, SoftwareX,
% Volume 24, 2023, 101584, ISSN 2352-7110,
% https://doi.org/10.1016/j.softx.2023.101584.
% (https://www.sciencedirect.com/science/article/pii/S2352711023002807)
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab:
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

help DATTES
