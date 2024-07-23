function xml = import_neware(file_in,options)
% import_neware Neware *.csv to VEHLIB XMLstruct converter
% 
% Usage 
% xml = import_neware(file_in,options)
% Inputs:
% - file_in (string): pathname for csv file
% - options (string): containing the following characters
%   - 'v': verbose, tells what it does
%
% Outputs:
% - xml (struct): structure with XML format 4 VEHLIB
% 
% See also neware_csv2xml, which_cycler
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

if ~exist('options','var')
    options='';
end
verbose = ismember('v',options);


%0. check if file exists
if ~exist('dirname','var')
    dirname = '';
end

if ~exist(file_in,'file')
    fprintf('import_neware: file does not exist: %s\n',file_in);
    xml = [];
    return;
end


if verbose
    fprintf('import_neware: %s\n',file_in);
end

    fid_in = fopen_safe(file_in);
%0.1 check if file is a neware file
[cycler, ~, ~] = which_cycler(fid_in);
fclose(fid_in);

% not a neware file
if ~strncmp(cycler,'neware_csv',11)
    fprintf('ERROR: file does not seem a neware *.csv file: %s\n',file_in);
    xml = [];
    return;
end

if verbose
    fprintf('read data\n');
end

%TODO: Reasons to split in three files:
% - simpler to process data from step and cycle info
% - last two characters (comma and char(9)) on each line of neware files make textscan not to
% work properly, columns are not cut properly, some values slide to
% preceding column making textscan to stop and putting all in wrong
% order...
% In the split part, each line is copied either to 'cycle' either to 'step'
% either to 'data' file, except two last characters (end-2).

%split csv file in three files:
% lines starting with ',,' = data
% lines starting with ',' = step info
% lines not starting with ',' = cycle info

fid_in = fopen_safe(file_in);
[D,F,E] = fileparts(file_in);
file_out_data = fullfile(D,sprintf('%s_data%s',F,E));
file_out_step = fullfile(D,sprintf('%s_step%s',F,E));
file_out_cycle = fullfile(D,sprintf('%s_cycle%s',F,E));
fid_out_data = fopen (file_out_data,'w+','n','ISO-8859-1');
fid_out_step = fopen (file_out_step,'w+','n','ISO-8859-1');
fid_out_cycle = fopen (file_out_cycle,'w+','n','ISO-8859-1');

while ~feof(fid_in)
    this_line = fgetl(fid_in);
    if length(this_line)>2
        if this_line(1)~=','
            %cycle
            fprintf(fid_out_cycle,'%s\n',this_line(1:end-2));
        elseif this_line(2)~=','
            %step
            fprintf(fid_out_step,'%s\n',this_line(2:end-2));
        else
            %data
            fprintf(fid_out_data,'%s\n',this_line(3:end-2));
        end
    end
end
fclose(fid_in);
fclose(fid_out_cycle);
fclose(fid_out_step);
fclose(fid_out_data);

%read data in csv (treat as string because mixed strings and numbers)
params.all_str = false;
params.col_sep = ',';
[header_lines,data_columns,tail_lines] = parse_mixed_data_csv(file_out_data,params);

% line_cycle = header_lines{end-2};
% line_step = header_lines{end-1};
line_variables = header_lines{end};

% ind_cycle = ~cellfun(@isempty,data_columns{1});
% ind_step = ~cellfun(@isempty,data_columns{2});
% ind_data = ~ind_cycle & ~ind_step;

% data_cycle = cellfun(@(x) x(ind_cycle),data_columns,'UniformOutput',false);
% data_step = cellfun(@(x) x(ind_step),data_columns,'UniformOutput',false);
% data = cellfun(@(x) x(ind_data),data_columns,'UniformOutput',false);

%TODO: analyse line_cycle and data_cycle
%TODO: analyse line_step and data_step

%analyse measurements (line_variables and data):
variables = regexp(line_variables,params.col_sep,'split');
%remove two fisrt columns (for cycle and for step respectively)
% variables = variables(3:end);
% data = data(3:end);

%get variable list


%get units from variable list
units = regexp(variables,'\(.*\)','match','once');
%celsius degres:
units = regexprep(units,'\(.C\)','(degC)');

%clean units in variable list
variables = regexprep(variables,'\(.*\)','');
%clean leading spaces
variables = regexprep(variables,'^\s','');
%clean trailing spaces
variables = regexprep(variables,'\s$','');
%replace midlle spaces with underscores
variables = regexprep(variables,'\s','_');
%replace dashes with underscores
variables = regexprep(variables,'-','_');

%standardise some variable names:
variables = regexprep(variables,'Time','tp');
variables = regexprep(variables,'Realtime','tabs');
variables = regexprep(variables,'Voltage','U');
variables = regexprep(variables,'Current','I');
variables = regexprep(variables,'Temperature','T');
variables = regexprep(variables,'^Capacity$','Q');
variables = regexprep(variables,'^Energy$','E');
variables = regexprep(variables,'^Power$','P');

XMLVars = cell(size(variables));
for ind = 1:length(variables)
    if ~isempty(variables{ind})
        if strcmp(variables{ind},'tp')
%             convert HH:MM:SS.FFF to double
            this_column = time_str_to_number(data_columns{ind});
        elseif strcmp(variables{ind},'tabs')
            %do not calculate datenum for every element just first one:
            % convert 'mm/dd/yyyy HH:MM:SS' to numbers
            tabs_0 = datenum_guess(data_columns{ind}(1));
            
            %datetime columns convert 'mm/dd/yyyy HH:MM:SS' to numbers
%             this_column = datenum(data(:,ind));
            
            test_datetime = datestr(tabs_0,'yyyy-mm-dd HH:MM:SS');
            %convert to DATTES date code (seconds from 1/1/2000)
            tabs_0 = m2edate(tabs_0);
            continue
        else
%             %normal column (numbers) convert data strings to numbers.
% probably faster methods exist, e.g: cat all text of column in string,
% then sscanf('%f'), or textscan.
%             this_column = str2double(data_columns{ind});
            this_column = data_columns{ind};
            if all(isnan(this_column))
                %skip columns with all nans (empty columns)
                continue
            end
            
        end
        
        [XMLVars{ind}, errorcode] = ...
            makeXMLVariable((variables{ind}), (units{ind}), '%f', (variables{ind}), this_column);
        
    end
end
%remove empty variables:
Ie = cellfun(@isempty,XMLVars);
XMLVars = XMLVars(~Ie);

 

    %xml header
    [XMLHead, err] = makeXMLHead('neware',date,'','import_neware (csv to VEHLIB xml)');
    %xml table > metatable
    %TODO: get test name from  metadata?
    test_name = file_in;
    
    [XMLMetatable, err] = makeXMLMetatable(test_name,test_datetime,file_in,'');
    
    
    %xml structure = xml header + xml metatable + xml variables
    [xml, errorcode] = makeXMLStruct(XMLHead, XMLMetatable, XMLVars);
    
    
    %additionnal variables:

%build tc from tp:
tp = xml.table{end}.tp.vector;
dtp = diff(tp);
dtp(dtp<0)=0.1;%introduce minimal diff(t) = 0.1 seconds
tc = [0;cumsum(dtp)];
[xml_tc, errorcode] = makeXMLVariable('tc', 's', '%f', 'tc', tc);
xml.table{end}.tc =  xml_tc;
%build tabs = tc: (tabs in data has 1 second resolution)
tabs = tabs_0+tc;
[xml_tabs, errorcode] = makeXMLVariable('tabs', 's', '%f', 'tabs', tabs);
xml.table{end}.tabs =  xml_tabs;
%build Step from tp
dtp = diff(tp);
dtp(dtp>0)=0;
dtp(dtp<0)=1;
step = [0;cumsum(dtp)];
[xml_step, errorcode] = makeXMLVariable('step', '', '%d', 'step', step);
xml.table{end}.step =  xml_step;
   
    %get cycler mode
    t = xml.table{end}.tc.vector;
    U = xml.table{end}.U.vector;
    I = xml.table{end}.I.vector;
    step = xml.table{end}.step.vector;
    
    seuilI = 5*min(abs(diff(unique(I))));
    seuilU = 5*min(abs(diff(unique(U))));
    m = which_mode(t,I,U,step,seuilI,seuilU);
    %ajouter aux variables de xml
    mode = makeXMLVariable('mode','', '%f','mode', m);
    xml.table{end}.mode = mode;
    %met les variables dans l'ordre
    xml.table{end} = sort_cycler_variables(xml.table{end});

    if verbose
        fprintf('file ready.\n');
    end

    %delete temp files:
    delete (file_out_data);
    delete (file_out_step);
    delete (file_out_cycle);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  LOCAL FUNCTIONS
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% function Step = analyse_data_step(line_step,data_step,tabs)
% 
% % get variable list
% variables = regexp(line_step,',','split');
% % first column always empty
% variables = variables(2:end);
% data_step = data_step(:,2:end);
% 
% %get units from variable list
% units = regexp(variables,'\(.*\)','match','once');
% %celsius degres:
% units = regexprep(units,'\(.C\)','(degC)');
% 
% %clean units in variable list
% variables = regexprep(variables,'\(.*\)','');
% %clean leading spaces
% variables = regexprep(variables,'^\s','');
% %clean trailing spaces
% variables = regexprep(variables,'\s$','');
% %replace midlle spaces with underscores
% variables = regexprep(variables,'\s','_');
% %replace dashes with underscores
% variables = regexprep(variables,'-','_');
% 
% %find column for Step ID:
% [~,~,Is] = regexpFiltre(variables,'^Step_ID$');
% Steps = data_step(:,Is);
% %find column for Step time:
% [~,~,Is] = regexpFiltre(variables,'Step_Time');
% Step_times = data_step(:,Is);
% %convert step times to seconds:
% Step_times = cellfun(@to_seconds,Step_times);
% 
% Step = zeros(size(tabs));
% 
% end
% 
