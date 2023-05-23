function [results] = calcul_soc_patch(results,options,cellnames)
% calcul_soc_patch - calcul_soc when no SoC100 is found.
% 
% This function handles with a set of results. When some results do not
% have SoC100 points, SoC can be calculated by the preceding or postponing
% test done in the cell.
%
% Usage (1): results = calcul_soc_patch(results,options)
% Search on results with missing SoC for each cell id (metadata.cell.id),
% calculate SoC takin as reference th efinal DoD_Ah of the preceding test.
% Usage (2): results = calcul_soc_patch(results,'f',cellnames)
% Search for cellnames in the filelist ({result.test.file_out}) instead
% cell id.
% Usage (3): results = calcul_soc_patch(filelist,options)
% Use a filelist (cell of pathnames) as input.
% Usage (4): results = calcul_soc_patch(srcdir,options)
% Search in srcdir for mat files.
%
% Inputs:
% - results [cell of struct]: cell containing DATTES structures
% - filelist [cell of char]: cell containing mat files pathnames
% - srcdir [char]: folder name to search mat files
% - options [char]: execution option
%     - 's': save
%     - 'v': verbose
%     - 'f': search cellname pattern in filenames rather than metadata.cell.id
%     - 'b': take soc from results before (default)
%     - 'a': take soc from results after
%     - 'u': unpatch, find precedingly patched results, set them soc to empty
% - cellnames [cell of char]: list of cell id or regex patterns to filter filelist
%
% Output:
% - results [cell of struct]: cell containing DATTES structures
%
% See also dattes_structure, calcul_soc
%
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.


%0.1 check options
if ~exist('cellnames','var')
    cellnames = '';
end
if ~exist('options','var')
    options = 'b';
end

verbose = ismember('v',options);
    
if ismember('u',options)
    mode = 'unpatch';
elseif ismember('a',options)
    mode = 'after';
else
    mode = 'before';
end

if ismember('f',options) && isempty(cellnames)
    fprintf('ERROR calcul_soc_patch: input cellnames is mandatory with ''f'' option\n')
    return
end


%1. Load results
% a) results is cell of structs 
% b) results is cell of chars (mat file list): load each file
% c) results is char (folder name): search mat files and load

if ischar(results)
    srcdir = results;
    if ~isfolder(srcdir)
        fprintf('ERROR calcul_soc_patch: input must be a cell of struct, a cell of chars or a folder name\n')
        return
    end
    mat_list = lsFiles(srcdir,'.mat');
    results = dattes_load(mat_list);%dattes load must filter mat files not containing result
elseif iscell(results)
    %check all elements of results are same type
    % if not: ERROR
    if all(cellfun(@ischar,results))
        % if cell of chars >> dattes_load
        mat_list = results;
        results = dattes_load(mat_list);
    elseif ~all(cellfun(@isstruct,results))
        fprintf('ERROR calcul_soc_patch: input must be a cell of struct, a cell of chars or a folder name\n')
        return
    end
else
    fprintf('ERROR calcul_soc_patch: input must be a cell of struct, a cell of chars or a folder name\n')
    return
end

% filter empty values after dattes_load (invalid mat_files)
ind_empty = cellfun(@(x) isempty(fieldnames(x)),results);
results = results(~ind_empty);
% check result struct
[~,invalid_results] = cellfun(@(x) check_result_struct(x),results,'UniformOutput',false);
invalid_results = cellfun(@(x) x<0,invalid_results);
results = results(~invalid_results);


[cellids, filelist] = get_cellids(results);

% find results concerning cellname
% if 'f' in options, search in filenames (result.test.file_in)
% else search in metadata.cell.id
if ismember('f',options)
    % search for cellnames in filelist instead cellids:
    % overwrite cellids with filelist:
    if verbose
        fprintf('calcul_soc_patch: based on filelist\n');
    end
    cellids = filelist;
else
    if verbose
        fprintf('calcul_soc_patch: based on cell ids\n');
    end
    if isempty(cellnames)
        cellnames = unique(cellids);
    end
end

switch mode
    case 'unpatch'
        results = unpatch_result(results,verbose);
    case 'before'
        for ind = 1:length(cellnames)
            %search for cellnames{ind}
            [~,~,ind_this_cell] = regexpFiltre(cellids,cellnames{ind});
            res_this_cell = results(ind_this_cell);
            %patch
            res_this_cell = patch_result_before(res_this_cell,verbose);
            %return patched to results
            results(ind_this_cell) = res_this_cell;
        end
    case 'after'
        for ind = 1:length(cellnames)
            %search for cellnames{ind}
            [~,~,ind_this_cell] = regexpFiltre(cellids,cellnames{ind});
            res_this_cell = results(ind_this_cell);
            %patch
            res_this_cell = patch_results_after(res_this_cell,verbose);
            %return patched to results
            results(ind_this_cell) = res_this_cell;
        end
end

if ismember('s',options)
            %verbose
        if verbose
            fprintf('calcul_soc_patch: saving results\n');
        end
    dattes_save(results);
end

end

function results = unpatch_result(results,verbose)

for ind = 1:length(results)
    result = results{ind};
    if ~isempty(result.configuration.soc.dod_ah_ini) || ~isempty(result.configuration.soc.dod_ah_fin)
        %was patched > unpatch
        %unpatch result.configuration
        result.configuration.soc.dod_ah_ini = [];
        result.configuration.soc.dod_ah_fin = [];
        %unpatch result.test
        result.test.dod_ah_ini = [];
        result.test.soc_ini = [];
        result.test.dod_ah_fin = [];
        result.test.soc_fin = [];
        %unpatch result.profiles
        result.profiles.soc = [];
        result.profiles.dod_ah = [];
        %verbose
        if verbose
            fprintf('calcul_soc_patch: unpatch_result, reset SOC for %s\n',result.test.file_out);
        end
        %put back in results cell
        results{ind} = result;
    end
end

end

function results = patch_result_before(results,verbose)
% sort by test datetime
test_datetimes = cellfun(@(x) x.test.datetime_ini,results);
[~,ind_sort] = sort(test_datetimes);
results = results(ind_sort);
for ind = 2:length(results)
    result = results{ind};
    if isempty(result.test.soc_ini) 
        if verbose
            fprintf('calcul_soc_patch: patch_result_before for %s',result.test.file_out);
        end
        % need to be patched
        res_before = results{ind-1};
        if ~isempty(res_before.test.soc_ini)
            % can be patched
            result.configuration.soc.dod_ah_ini = res_before.test.dod_ah_fin;
            % calcul soc
            [dod_ah, soc] = calcul_soc(result.profiles.datetime,result.profiles.I,...
                result.configuration);
            if ~isempty(dod_ah)
                %on success update result.profiles
                result.profiles.dod_ah = dod_ah;
                result.profiles.soc = soc;
                %on success update result.test
                result.test.dod_ah_ini = result.profiles.dod_ah(1);
                result.test.soc_ini = result.profiles.soc(1);
                result.test.dod_ah_fin = result.profiles.dod_ah(end);
                result.test.soc_fin = result.profiles.soc(end);
            end
            %put back in results cell
            results{ind} = result;
            if verbose
                fprintf(' OK\n');
            end
        else
            if verbose
                fprintf(' NOK\n');
            end
        end
    end
end

end

function results = patch_results_after(results,verbose)
% sort by test datetime
test_datetimes = cellfun(@(x) x.test.datetime_ini,results);
[~,ind_sort] = sort(test_datetimes);
results = results(ind_sort);
for ind = (length(results)-1):-1:1
    result = results{ind};
    if isempty(result.test.soc_ini)
        if verbose
            fprintf('calcul_soc_patch: patch_results_after for %s',result.test.file_out);
        end
        % need to be patched
        res_after = results{ind+1};
        if ~isempty(res_after.test.soc_ini)
            % can be patched
            result.configuration.soc.dod_ah_ini = res_after.test.dod_ah_fin;
            % calcul soc
            [dod_ah, soc] = calcul_soc(result.profiles.datetime,result.profiles.I,...
                result.configuration);
            if ~isempty(dod_ah)
                %on success update result.profiles
                result.profiles.dod_ah = dod_ah;
                result.profiles.soc = soc;
                %on success update result.test
                result.test.dod_ah_ini = result.profiles.dod_ah(1);
                result.test.soc_ini = result.profiles.soc(1);
                result.test.dod_ah_fin = result.profiles.dod_ah(end);
                result.test.soc_fin = result.profiles.soc(end);
            end
            %put back in results cell
            results{ind} = result;
            if verbose
                fprintf(' OK\n');
            end
        else
            if verbose
                fprintf(' NOK\n');
            end
        end
    end
end
end

function [cellids, filelist] = get_cellids(results)

filelist = cellfun(@(x) x.test.file_out,results,'UniformOutput',false);
cellids = cell(size(results));
for ind = 1:length(results)
    cellids{ind} = '';
    result = results{ind};
    if isfield(result,'metadata')
        if isfield(result.metadata,'cell')
            if isfield(result.metadata.cell,'id')
                cellids{ind} = result.metadata.cell.id;
            end
        end
    end
end

end