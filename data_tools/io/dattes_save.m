function err = dattes_save(result)
%dattes_save save the result,config and phases of in a XMLfile_result.mat
%
% err = dattes_save(result)
% save the results of DATTES analysis
%
% Usage:
% err = dattes_save(result)
% Inputs : 
% - result: [1x1 struct] structure containing analysis results 
%
% Outputs : 
% - err [1x1 double] 
%    - 0 : No error
%    - -1 : Size of result and config structure are not the same
%    - -2 : result.test structure is not valid
%
% See also dattes_load, result_filename
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

%% 0.1.- check inputs:
err = 0;

if iscell(result)
    err = cellfun(@dattes_save,result);
    return
end
if ~isstruct(result)
    error('dattes_save: wrong type of parameters\n');
end


for ind = 1:length(result)
    err(ind) = save1result(result(ind));
end
end

function err = save1result(result)
% save a result file
err = 0;
%get file name
if isfield(result,'test')
    if isfield(result.test,'file_out')
        fileOut = result.test.file_out;
    elseif isfield(result.test,'file_in')
        fileOut = result_filename(result.test.file_in);
    else
        fprintf('dattes_save:ERROR, result.test structure is not valid (no field ''file_in'')\n');
        err = -2;
        return
    end
else
    fprintf('dattes_save:ERROR, result structure is not valid (no field ''test'')\n');
    err = -1;
    return
end
%convert all function handlers into strings:
result = func2str_struct(result);

%make folder if it does not exist
folder_out = fileparts(fileOut);
[status, msg, msgID] = mkdir(folder_out);
%save these variables in this file
save(fileOut,'-v7','result');
end
