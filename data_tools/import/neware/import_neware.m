function xml = import_neware(file_in,options)
% import_bitrode Neware *.csv to VEHLIB XMLstruct converter
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
    fid_in = fopen(file_in,'r');
%0.1 check if file is a bitrode file
[cycler, line_cycle, line_step] = which_cycler(fid_in);
% bench ='oup';
if ~strncmp(cycler,'neware_csv',11)
    fprintf('ERROR: file does not seem a neware *.csv file: %s\n',file_in);
    xml = [];
    return;
end
chrono = tic;

line_variables = fgetl(fid_in);
fclose(fid_in);

if verbose
    fprintf('read data\n');
end
%read data in csv (treat as string because mixed strings and numbers)
data = readmatrix(file_in,'OutputType','string');
%fill missing strings with empty strings to avoid errors in next step
data = fillmissing(data,'constant',"");
%convert string to cell of char
% data = arrayfun(@(x) char(x),data,'UniformOutput',false);

%data contains numbers (in string format) + strings
%data_num contains just number, missing strings and other strings are NaNs
%using data_num is faster than using data
data_num = readmatrix(file_in,'TreatAsMissing','NA');

% Ie = cellfun(@isempty,data);
%faster than cellfun isempty:
Ie = isnan(data_num);

%split data into three:
%1. first element non empty: 'Cycle lines'
I_cycle_data = ~Ie(:,1);
data_cycle = data(I_cycle_data,:);
%2. second elemnt non empty: 'Step lines'
I_step_data = Ie(:,1) & ~Ie(:,2);
data_step = data(I_step_data,:);
%3. first and second elemens empty: 'Measurements'
I_measurement_data = Ie(:,1) & Ie(:,2);
data = data(I_measurement_data,:);

data_num = data_num(I_measurement_data,:);

%TODO: analyse line_cycle and data_cycle
%TODO: analyse line_step and data_step

%analyse measurements (line_variables and data):
variables = regexp(line_variables,',','split');
variables = variables(3:end);
data = data(:,3:end);
data_num = data_num(:,3:end);


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
%             this_column = regexp(data(:,ind),':','split');
%             t_hours = cellfun(@(x) sscanf(x{1},'%d'),this_column);
%             t_minutes = cellfun(@(x) sscanf(x{2},'%d'),this_column);
%             t_seconds = cellfun(@(x) sscanf(x{3},'%f'),this_column);
%             this_column = t_seconds + 60*(t_minutes+60*t_hours);
            this_column = cellfun(@to_seconds,data(:,ind));
        elseif strcmp(variables{ind},'tabs')
            %do not calculate datenum for every element just first one:
            % convert 'mm/dd/yyyy HH:MM:SS' to numbers
            tabs_0 = datenum(data(1,ind));
            
            %datetime columns convert 'mm/dd/yyyy HH:MM:SS' to numbers
%             this_column = datenum(data(:,ind));
            
            test_datetime = datestr(tabs_0,'yyyy-mm-dd HH:MM:SS');
            %convert to DATTES date code (seconds from 1/1/2000)
            tabs_0 = m2edate(tabs_0);
            continue
        else
%             %normal column (numbers) convert data strings to numbers.
%                         this_column = data(:,ind);
%                         Ie = cellfun(@isempty,this_column);
%                         if all(Ie)
%                             %skip columns with all empty
%                             continue
%                         end
%                         this_column(Ie) = {nan};
%                         this_column = cellfun(@(x) sscanf(x,'%f'),this_column);
            
            %normal column (numbers) > get directly numbers from data_num
            this_column = data_num(:,ind);
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
Step = [0;cumsum(dtp)];
[xml_step, errorcode] = makeXMLVariable('Step', '', '%d', 'Step', Step);
xml.table{end}.Step =  xml_step;
   
    %get cycler mode
    t = xml.table{end}.tc.vector;
    U = xml.table{end}.U.vector;
    I = xml.table{end}.I.vector;
    Step = xml.table{end}.Step.vector;
    
    seuilI = 5*min(abs(diff(unique(I))));
    seuilU = 5*min(abs(diff(unique(U))));
    m = which_mode(t,I,U,Step,seuilI,seuilU);
    %ajouter aux variables de xml
    mode = makeXMLVariable('mode','', '%f','mode', m);
    xml.table{end}.mode = mode;
    %met les variables dans l'ordre
    xml.table{end} = sort_cycler_variables(xml.table{end});

    tecoule = toc(chrono);
    if verbose
        fprintf('file ready in %0.2f seconds.\n',tecoule);
    end
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

function seconds = to_seconds(hh_mm_ss)
%convert a string like 'HH:MM:SS' to seconds rounded to ms:
% seconds = round((datenum(hh_mm_ss)-datenum('00:00:00'))*86400,3);
            hh_mm_ss = regexp(hh_mm_ss,':','split');
            t_hours = sscanf(hh_mm_ss{1},'%d');
            t_minutes = sscanf(hh_mm_ss{2},'%d');
            t_seconds = sscanf(hh_mm_ss{3},'%f');
            seconds = t_seconds + 60*(t_minutes+60*t_hours);
end