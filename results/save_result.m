function err = save_result(result,config,phases)
%save_result save the results of dattes
%save_result(XMLfile,resultat,config,phases) sauvegarde resultat,config,phases
%dans XMLfile_result.mat.
%
%See also dattes, load_result, edit_result

%TODO: verification de types en entree (1x1 struct,1x1 struct,1xp struct)
%ou (1xn struct,1xn struct,1xn cell de struct)
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
if isfield(result,'fileIn')
    fileOut = result_filename(result.fileIn);
else
    fprintf('save_result:ERROR, result structure is not valid (no field ''fileIn'')\n');
    err = -1;
    return
end
%save these variables in this file
save(fileOut,'result','config','phases');
end