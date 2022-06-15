function fileOut = result_filename(XMLfile)
%result_filename Create result file named xml_file_result.mat
%
%  fileOut = result_filename(XMLfile)
% Create result file named xml_file_result.mat
%
% Usage:
% [result, config] = edit_result(result, config,Field,Values,options)
% Inputs : 
% - xml_file:
%     -   [1xn string]: pathame to the xml file
%     -   [nx1 cell string]: xml filelist
% Outputs : 
% - fileOut: [string] full file name of the result file
%
% See also dattes, load_result, edit_result
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.


%separate folder (D), file (F) and extension (E)
[D F E] = fileparts(XMLfile);
%print suffix: filename_result.mat
fileOut = sprintf('%s_dattes.mat',F);
%build the full pathname (folder + filename)
fileOut = fullfile(D, fileOut);
end