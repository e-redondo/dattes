function xml = import_comutes2(file_in, options)
% import_comutes2 COMUTES2 *.txt to VEHLIB XMLstruct converter
%
% Usage
%   xml = import_comutes2(file_in)
% Read filename (*.txt file) and converts to xml (VEHLIB XMLstruct)
% Inputs:
% - file_in (string): pathname of a txt file
%           (string): folder to search txt files in
% - options (string): containing the following characters
%   - 'v': verbose, tells what it does
%
% Outputs:
% - xml (struct): structure with XML format 4 VEHLIB
%
%   See also csv2profiles
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab:
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.
verveh=2.0;

%0.-Errors:
if ~exist('options','var')
    options = '';
end

% if isfolder(file_in)
%     %batch mode: search all txt files in folder, then put all in a xml
%     file_list = lsFiles(file_in,'.txt',true);
% 
%     %ignore non data files from Arbin:
%     xml = cellfun(@(x) import_comutes2(x,options),file_list,'UniformOutput',false);
%     % remove empty xmls (not valid csv files):
%     ind_empty = cellfun(@isempty,xml);
%     xml = xml(~ind_empty);
%     % merge all xml into first one
%     for ind = 2:length(xml)
%         xml{1} = XMLFusion(xml{1},xml{ind});
%     end
% 
%     if isempty(xml)
%       %no arbin file in folder
%       xml = [];
%     else
%       %return first (merged) xml
%       xml = xml{1};
%     end
% 
%     return
% end

if ~exist(file_in,'file')
    fprintf('import_comutes2: file does not exist: %s\n',file_in);
    xml = [];
    return;
end

%0.1.- Check file existance
[D F E] = fileparts(file_in);
filename = [F E];


% chrono=tic;
fid = fopen_safe(file_in);
[cycler, line1, line2, header_lines, first_data_line] = which_cycler(fid);
fclose(fid);

if ~strncmp(cycler,'comutes2',8)
    %Probably an error reading xls file:
    fprintf('WARNING: not an COMUTES2 csv file: %s\n',file_in);
    xml = [];
    return;
end

[variable_names, unit_names, date_test, source_file,params] = analyse_comutes2_head(file_in,header_lines);


%1.- reading file
% params = struct;  % see csv2profiles if some params are needed
%params.U_thres = 0.01;
%params.I_thres = 0.1;

params.date_fmt = '';
% params.date_fmt = 'yyyy-mm-dd HH:MM:SS';
if strcmp(cycler,'comutes2')
    %dt, tt, u, i, m, T, dod_ah, soc, step, ah, ah_dis, ah_cha
    col_names = {'','Time','U','I',...
        'Mode','Temp','','','','Q',...
        '',''};
elseif strcmp(cycler,'comutes2_dig')
    %dt, tt, u, i, m, T, dod_ah, soc, step, ah, ah_dis, ah_cha
    col_names = {'','ProgTime','U','I',...
        'Mode','Temp','','','','Q',...
        '',''};
end


[profiles, other_cols] = csv2profiles(file_in,col_names,params);
%dt, tt, u, i, m, T, dod_ah, soc, step, ah, ah_dis, ah_cha
profiles_units = {'','s','V','A','','degC','','','','Ah','',''};
					
%2. test datetime:
datetime_ini = 0; % if 0 after this check, no date found, testtime  == datetime
if regexp(date_test,'[0-9]*_[0-9]*')
    %format 'yyyymmdd_HHMMSS
    date_test_str = regexp(date_test,'[0-9]*_[0-9]*','match','once');
    if length(date_test_str)==15
        datetime_ini = m2edate(datenum(date_test,'yyyymmdd_HHMMSS'));
    end
    
end
profiles.datetime = profiles.t + datetime_ini;

%DEBUG
% [D,F,E] = fileparts(file_in);
% save(sprintf('%s.mat',F),'profiles');

%3.- creer XML
%3.1.- introduire entete:
[XMLHead, err] = makeXMLHead('comutes2',date,'',sprintf('comutes2_txt2xml version:%.2f',verveh));
%3.2.- metatable
[XMLMetatable, err] = makeXMLMetatable(filename,date,filename,'');


%3.3.- profiles variables
variables = fieldnames(profiles);
%change some variable names: (see doc/structure specification)
variables_names = variables;
variables_names(ismember(variables,{'datetime'})) = {'tabs'};
variables_names(ismember(variables,{'t'})) = {'tc'};
variables_names(ismember(variables,{'m'})) = {'mode'};

XMLVars = cell(size(variables));
for ind = 1:length(variables)
    if ~isempty(profiles.(variables{ind}))
        %do not put empty vectors in XML
        [XMLVars{ind}, errorcode] = ...
            makeXMLVariable((variables_names{ind}), (profiles_units{ind}), '%f', (variables_names{ind}), profiles.(variables{ind}));
    end
end
% remove 'empty' vars:
Ie = cellfun(@isempty,XMLVars);
XMLVars = XMLVars(~Ie);

%3.4 other_cols
variables = fieldnames(other_cols);

%separate unis
[units,variables] = regexpFiltre(variables,'_units$');


XMLVars_other = cell(size(variables));
for ind = 1:length(variables)
    if isnumeric(other_cols.(variables{ind}))
        %TODO convert cells to double, see csv2profile (try-catch)
        [XMLVars_other{ind}, errorcode] = ...
        makeXMLVariable((new_variables{ind}), other_cols.(units{ind}), '%f', (new_variables{ind}), other_cols.(variables{ind}));
    end
end
% remove 'empty' vars:
Ie = cellfun(@isempty,XMLVars_other);
XMLVars_other = XMLVars_other(~Ie);

%merge all XMLVars:
XMLVars = [XMLVars(:); XMLVars_other(:)];

[xml, errorcode] = makeXMLStruct(XMLHead, XMLMetatable, XMLVars);

end