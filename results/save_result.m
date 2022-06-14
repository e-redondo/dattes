function err = save_result(result,config,phases)
%save_result save the result,config and phases of in a XMLfile_result.mat
%
% err = save_result(result,config,phases)
% save the results of DATTES analysis
%
% Usage:
% err = save_result(result,config,phases)
% Inputs : 
% - result: [1x1 struct] structure containing analysis results 
% - config:  [1x1 struct] function name used to configure the behavior (see configurator)
% - phases: [1x1 struct] structure containing information about the different phases of the test
%
% Outputs : 
% - err [1x1 double] 
%    - 0 : No error
%    - -1 : Size of result and config structure are not the same
%    - -2 : result.test structure is not valid
%
% See also dattes, load_result, edit_result
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

%% 0.1.- check inputs:
err = 0;

if length(result)==1
%     XMLfile = {XMLfile};
    phases = {phases};
end
if ~isstruct(result) || ~isstruct(config) || ~iscell(phases)
    error('save_result: wrong type of parameters\n');
end

if ~isequal(size(result),size(config))
    fprintf('save_result:ERROR, inputs'' sizes must be coherent\n');
    err = -1;
    return
end

for ind = 1:length(result)
    err(ind) = save1result(result(ind),config(ind),phases{ind});
end
end

function err = save1result(result,config,phases)
% save a result file
err = 0;
%get file name
if isfield(result,'test')
    if isfield(result.test,'file_in')
        fileOut = result_filename(result.test.file_in);
    else
        fprintf('save_result:ERROR, result.test structure is not valid (no field ''file_in'')\n');
        err = -2;
        return
    end
else
    fprintf('save_result:ERROR, result structure is not valid (no field ''test'')\n');
    err = -1;
    return
end
%save these variables in this file
save(fileOut,'result','config','phases');
end
