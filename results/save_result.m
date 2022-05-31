function err = save_result(result,config,phases)
%save_result save the results of dattes
%save_result(XMLfile,resultat,config,phases) sauvegarde resultat,config,phases
%dans XMLfile_result.mat.
%
%See also dattes, load_result, edit_result

err = 0;
if length(result)==1
%     XMLfile = {XMLfile};
    phases = {phases};
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
%sauvegarde 1 fichier de resultats
err = 0;
%get file name
if isfield(result,'file_in')
    fileOut = result_filename(result.file_in);
else
    fprintf('save_result:ERROR, result structure is not valid (no field ''file_in'')\n');
    err = -1;
    return
end
%save these variables in this file
save(fileOut,'result','config','phases');
end