function result = dattes_analyse(result,options)
% dattes_configure - DATTES Analysis function
%
% 
% Usage:
% (1) result = dattes_analyse(result,options)
% (2) result = dattes_analyse(file_in,options)
% (3) result = dattes_analyse(file_list,options)
% (4) result = dattes_analyse(src_folder,options)
%
% Input:
% - file_in [1xp string] DATTES mat file pathname
% - result [1x1 struct] DATTES result structure
% - file_list [nx1 cellstr] DATTES mat file list of pathnames
% - src_folder [1xp string] folder to search DATTES mat files in
% - options [1xn string]:
%   -'s': save result
%   -'v': verbose
%   -'C': Capacity measurement
%   -'R': Resistance identification
%   -'Z': impedance identification (CPE, Warburg or other)
%   -'P': pseudoOCV (low current charge/discharge cycles)
%   -'O': OCV by points (partial charge/discharges followed by rests)
%   -'I': ICA/DVA
%   -'A': synonym for 'CRWPOI' (do all)
%
%
% See also dattes_configure, dattes_export
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

%TODO: dst_folder to save results in different file.

%0.1 1st paramater is mandatory
if ~exist('result','var')
    fprintf('ERROR dattes_analyse: result input struct is mandatory\n');
    result = [];
    return
end
%0.2 if 2nd not given, set defaults:
if ~exist('options','var')
    options = '';
elseif ~ischar(options)
    fprintf('ERROR dattes_analyse: options must be string\n');
    result = [];
    return
end

%abbreviation options ('All')
options = strrep(options,'A','CSRWPOI');
%remove duplicate:
options = unique(options);
%Options that will be given as inputs (inherit) to sub-fonctions:
% -g: graphics
% -v: verbose
% -s: save
inher_options = options(ismember(options,'gvs'));

%0.3 1st paramater may be result/file_in/file_list/src_folder
if ischar(result)
    if isfolder(result)
        if ismember('v',options)
            fprintf('dattes_analyse: analysing mat files in %s...\n',result);
        end
        %input is src_folder > get mat files in cellstr
        mat_list = lsFiles(result,'.mat');
        %call dattes_analyse with file_list
        result = dattes_analyse(mat_list,options);
        % stop after
        return
    elseif exist(result,'file')
        %file_in mode
        if ismember('v',options)
            fprintf('dattes_analyse: loading mat file in %s...\n',result);
        end
        result = dattes_load(result);
    end
end

if iscell(result)
    %file_list mode
    result = cellfun(@(x) dattes_analyse(x,options),result,'Uniformoutput',false);
    % stop after
    return
end

%0.5 check result struct
[info,err] = check_result_struct(result);
if err<0
    fprintf('ERROR dattes_analyse: input result is not a valid DATTES struct\n');
    result = [];
    return
end

%0.6 from now we have 1x1 DATTES result struct:
%vectors:
datetime = result.profiles.datetime;
t = result.profiles.t;
U = result.profiles.U;
I = result.profiles.I;
m = result.profiles.mode;
dod_ah = result.profiles.dod_ah;
soc = result.profiles.soc;
%phases and config:
phases = result.phases;
config = result.configuration;

%% 1. Capacity measurements at different C-rates 1C, C/2, C/5....
if ismember('C',options)
    [capacity] = ident_capacity(config,phases,inher_options);
    result.analyse.capacity = capacity;
end

%% 2. Profile processing (datetime,U,I,m,dod_ah) >>> R, CPE, ICA, OCV, etc.
if any(ismember('PORZI',options))
    if isempty(dod_ah)
        %If  calcul_soc have not been processed correctly, none analysis is processed (and neither saved)
        fprintf('dattes: ERREUR il faut calculer le SoC de ce fichier:%s\n',...
            result.test.file_in);
        %         return
    else
        
        
        %6.1. pseudo ocv
        if ismember('P',options)
            [pseudo_ocv] = ident_pseudo_ocv(result.profiles,config,phases,inher_options);
            %save the results
            result.analyse.pseudo_ocv = pseudo_ocv;
            
        end
        
        %6.2. ocv by points
        if ismember('O',options)
            [ocv_by_points] = ident_ocv_by_points(result.profiles,config,phases,inher_options);
            %save the results
            result.analyse.ocv_by_points = ocv_by_points;
        end
        
        %6.3. impedances
        %6.3.1. resistance
        if ismember('R',options)
            [resistance] = ident_r(result.profiles,config,phases,inher_options);
            %save the results
            result.analyse.resistance = resistance;
        end
        %6.3.2. Impedance
        if ismember('Z',options)
            ident_z = config.impedance.ident_fcn;
            if ischar(ident_z)
               % function handle saved as string in octave and in json:
               ident_z = str2func(ident_z);
            end
            [impedance] = ident_z(datetime,U,I,dod_ah,config,phases,inher_options);
            result.analyse.impedance= impedance;
        end
        
        %6.4. ICA/DVA
        if ismember('I',options)
            ica = ident_ica(result.profiles,config,phases,inher_options);
            %sauvegarder les resultats
            result.analyse.ica = ica;
        end
    end
end

%% 3. Save results
if ismember('s',options)
    if ismember('v',options)
        fprintf('dattes: save result...');
    end
    %save outputs result,config and phases in a xml_file_result.mat
    dattes_save(result);
    if ismember('v',options)
        fprintf('OK\n');
    end
end

%% 4. Final message if verbose
if ismember('v',options)
    fprintf('dattes_analyse: processing ...OK\n');
end

end