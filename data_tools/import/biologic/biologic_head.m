function [head, date_test, type_test, source_file, empty_file,test_params] = biologic_head(file_name)
% biologic_head Read and analyse .mpt Biologic files header
%
% Usage :
% [head, date_test, type_test, source_file, empty_file] = biologic_head(file_name)
% Inputs :
%   - file_name: [string] Path to the Biologic file
% Outputs :
%   - head: [(mx1) cell string] Header information
%   - date_test: [string]  Test date with format yyyymmdd_HHMMSS
%   - type_test : [string]  Test type
%   - source_file: [string]  Source file
%   - empty_file : [Boolean]  True if just header in file (no data)
%
% See also read_biologic_file, analyze_head
%
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab:
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

if nargin==0
    print_usage
end
head = '';
date_test = '';

%1.-Reading file
[D, F, E] = fileparts(file_name);
F = [F,E];
fid = fopen_safe(file_name);
if fid<0
    fprintf('biologic_head: Error in the file %s\n',F);
    return;
end
% [head] = lectureBiologicTete(fid);
[head] = read_biologic_file(fid,true);
if isempty(head)
    fprintf('biologic_head: Error in the file %s\n',F);
    return%on force l'erreur si pas ECLAB file
end
%check if it was last line in file
ligne = fgetl(fid);
if ligne == -1
    empty_file = true;
else
    empty_file = false;
end
fclose(fid);

%2.- date essai
date_test = '';
ligneDate = regexpFiltre(head,'^Acquisition started on : ');
if ~isempty(ligneDate)
    date_test = regexprep(ligneDate{1},'^Acquisition started on : ','');
    aNum = datenum_guess(date_test);%default date format in MATLAB = Biologic MM/DD/YY
    date_test = datestr(aNum,'yymmdd_HHMMSS.FFF');%v10.23
else%try to deduct date time from file_name
    %try on file_name
    ligneDate = regexp(F,'^[0-9]{8,8}_[0-9]{4,4}','match','once');
    if isempty(ligneDate) %try on last level folder name
        [~, D1] = fileparts(D);
        ligneDate = regexp(D1,'^[0-9]{8,8}_[0-9]{4,4}','match','once');
    end
    if ~isempty(ligneDate)
        aNum = datenum_guess(ligneDate,'yyyymmdd_HHMM');
        date_test = datestr(aNum,'yymmdd_HHMMSS.FFF');
    end
end
%3.- type_test
if length(head)>3
    if  ~isempty(regexp(head{4},'^Special Galvanostatic Cycling with Potential Limitation'))
        type_test = 'SGCPL';
    elseif ~isempty(regexp(head{4},'^Galvanostatic Cycling with Potential Limitation'))
        type_test = 'GCPL';
    elseif ~isempty(regexp(head{4},'^Galvano Profile Importation'))
        type_test = 'GPI';
    elseif  ~isempty(regexp(head{4},'^Galvano Electrochemical Impedance Spectroscopy'))
        type_test = 'GEIS';
    elseif  ~isempty(regexp(head{4},'^Potentio Electrochemical Impedance Spectroscopy'))
        type_test = 'PEIS';
    elseif  ~isempty(regexp(head{4},'^Open Circuit Voltage'))
        type_test = 'OCV';
    elseif  ~isempty(regexp(head{4},'^Wait'))
        type_test = 'Wait';
    elseif  ~isempty(regexp(head{4},'^Modulo Bat'))
        type_test = 'MB';
    else
        type_test = 'inconnu';
    end
else
    if  ~isempty(strfind(file_name,'SGCPL'))
        type_test = 'SGCPL';
    elseif ~isempty(strfind(file_name,'GCPL'))
        type_test = 'GCPL';
    elseif ~isempty(strfind(file_name,'GPI'))
        type_test = 'GPI';
    elseif ~isempty(strfind(file_name,'GEIS'))
        type_test = 'GEIS';
    elseif ~isempty(strfind(file_name,'PEIS'))
        type_test = 'PEIS';
    elseif ~isempty(strfind(file_name,'OCV'))
        type_test = 'OCV';
    else
        type_test = 'inconnu';
    end
end
%4.- source_file
[s] = regexp(head,'([a-zA-Z%�_0-9-]+).mpr$','match','once');
indices = find(cellfun(@(x) ~isempty(x),s));
if length(indices)~=1%not found, mpt filename is considered
    [D source_file E] = fileparts(file_name);
    source_file = sprintf('%s%s',source_file,E);
else
    source_file = s{indices};
end
%5.- extra params
test_params = struct;
if strcmp(type_test,'GEIS')
    %average current
    Is_line = regexpFiltre(head,'^Is');
    if ~isempty(Is_line)
        %search for line containing Is setting:
        Is_line = regexp(Is_line{1},'\s+','split');
        Is_units = regexpFiltre(head,'unit Is');
        Is_units = regexp(Is_units{1},'\s+','split');

        Is = sscanf(Is_line{2},'%f');
        scale = 1;
        if strcmp(Is_units{3},'mA')
            scale = 0.001;%TODO other possible scales? µA?
        end
        test_params.Is = scale*Is;%convert to A
    end
    %current amplitude
    Ia_line = regexpFiltre(head,'^Ia\s+');
    if ~isempty(Is_line)
        %search for line containing Is setting:
        Ia_line = regexp(Ia_line{1},'\s+','split');
        Ia_units = regexpFiltre(head,'unit\s+Ia');
        Ia_units = regexp(Ia_units{1},'\s+','split');

        Ia = sscanf(Ia_line{2},'%f');
        scale = 1;
        if strcmp(Ia_units{3},'mA')
            scale = 0.001;%TODO other possible scales? µA?
        end
        test_params.Ia = scale*Ia;%convert to A
    end
    %TODO do the same for other test types, e.g. PEIS (Is?,Va, etc.)
elseif strcmp(type_test,'PEIS')
    %average voltage
    Vs_line = regexpFiltre(head,'^E \(.+\)');
    if ~isempty(Vs_line)
        %search for line containing Is setting:
        Vs_units = regexp(Vs_line{1},'\(.+\)','match','once');
        Vs_units = regexprep(Vs_units,'\(','');
        Vs_units = regexprep(Vs_units,'\)','');
        
        Vs_words = regexp(Vs_line{1},'\s+','split');
        Vs = cellfun(@(x) sscanf(x,'%f'),Vs_words,'UniformOutput',false);
        Ie = cellfun(@isempty,Vs);
        Vs = Vs{~Ie};

        scale = 1;
        if strcmp(Vs_units,'mV')
            scale = 0.001;%TODO other possible scales? µA?
        end
        test_params.Us = scale*Vs;%convert to V
    end
    %voltage amplitude
    Va_line = regexpFiltre(head,'^Va\s+');
    if ~isempty(Vs_line)
        Va_units = regexp(Va_line{1},'\(.+\)','match','once');
        Va_units = regexprep(Va_units,'\(','');
        Va_units = regexprep(Va_units,'\)','');
        
        Va_words = regexp(Va_line{1},'\s+','split');
        Va = cellfun(@(x) sscanf(x,'%f'),Va_words,'UniformOutput',false);
        Ie = cellfun(@isempty,Va);

        Va = Va{~Ie};
        scale = 1;
        if strcmp(Va_units,'mV')
            scale = 0.001;%TODO other possible scales? µV?
        end
        test_params.Ua = scale*Va;%convert to V
    end
    %TODO do the same for other test types, e.g. PEIS (Vs?,Va, etc.)
elseif strcmp(type_test,'MB')

    %get control type in line
    control_type_line = regexpFiltre(head,'^ctrl_type');
    control_types = regexp(control_type_line{1},'\s+','split');
    control_types = control_types(2:end-1);%remove first and last column as in Ns
    [~,~,geis_sequences] = regexpFiltre(control_types,'GEIS');
    [~,~,peis_sequences] = regexpFiltre(control_types,'PEIS');
    
    Ns = 0:length(control_types)-1;
    %get control val in line
    control_val1_line = regexpFiltre(head,'^ctrl1_val\s+');
    %get control unit in line
    control_unit1_line = regexpFiltre(head,'^ctrl1_val_unit\s+');

    %TODO: find Iavg in settings file. (control_val4?, ApplyI/C?)

    start_cuts = regexp(control_type_line{1},'\s[A-Z]')+1;
    end_cuts = [start_cuts(2:end)-1 length(control_val1_line{1})];
    for ind = 1:length(start_cuts)
        control_vals1{ind} = control_val1_line{1}(start_cuts(ind):end_cuts(ind));
        control_units1{ind} = control_unit1_line{1}(start_cuts(ind):end_cuts(ind));
    end
    
    % prevent comma decimal separator error
    control_vals1 = strrep(control_vals1,',','.');
    
    %convert string to numbers, fill empty values with nans
    control_vals1 = cellfun(@str2num,control_vals1,'UniformOutput',false);
    Ie = cellfun(@isempty,control_vals1);
    control_vals1(Ie) = {nan};
    %convert cell to array
    control_vals1 = cell2mat(control_vals1);

    scale = ones(size(Ns));
    [~,~,Ism] = regexpFiltre(control_units1,'mA');%TODO same for mV?
    [~,~,Usm] = regexpFiltre(control_units1,'mV');%TODO same for mV?
    scale(Ism) = 0.001;
    scale(Usm) = 0.001;
    %TODO, put values to avoid errors:
    test_params.Is = nan(size(Ns));%TODO
    test_params.Ia = control_vals1.*scale;
    test_params.Ia(~geis_sequences) = nan;
    %TODO, put values to avoid errors:
    test_params.Us = nan(size(Ns));%TODO
    test_params.Ua = control_vals1.*scale;
    test_params.Ua(~peis_sequences) = nan;

end

end
