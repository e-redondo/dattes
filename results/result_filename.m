function file_out = result_filename(file_in, dst_folder,suffix, file_out_ext)
%result_filename Create result file named file_in_suffix.mat
%
% Create result file named file_in_suffix.mat
%
% Usage:
% [result, config] = edit_result(result, config,Field,Values,options)
% Inputs : 
% - file_in [1xn string]: input filename
% - dst_folder [1xp string]: (optional) destinaiton folder (default= src_folder)
% - suffix [1xq string]: (optional) filename suffix (default= 'dattes')
% - file_out_ext [string]: (optional) output extension (default= '.mat')
%
% Outputs : 
% - file_out: [string] full file name of the result file
%
% Examples:
% (1) file_out = result_filename(raw_data/test.xml)
%       file_out = 'raw_data/test_dattes.mat'
% (2) file_out = result_filename(raw_data/test.xml,'processed_data')
%       file_out = 'processed_data/test_dattes.mat'
% (3) file_out = result_filename(raw_data/test.xml,'','analysed')
%       file_out = 'raw_data/test_analysed.mat'
% (4) file_out = result_filename(raw_data/test.xml,'','')
%       file_out = 'raw_data/test.mat'
%
% See also dattes, load_result, save_result
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

if ~exist('suffix','var')
    suffix = 'dattes';
end
if ~exist('dst_folder','var')
    dst_folder = '';
end
if ~exist('file_out_ext','var')
    file_out_ext = '.mat';
end

%separate folder (D), file (F) and extension (E)
[src_folder, F, E] = fileparts(file_in);

%print suffix: filename_result.mat
if isempty(suffix)
    file_out = sprintf('%s%s',F, file_out_ext);
else
    file_out = sprintf('%s_%s%s',F,suffix, file_out_ext);
end
%build the full pathname (folder + filename)
if isempty(dst_folder)
    file_out = fullfile(src_folder, file_out);
else
    file_out = fullfile(dst_folder, file_out);
end
end