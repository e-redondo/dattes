function xml = import_digatron(file_in, options)
% import_digatron_xls digatron *.CSV to VEHLIB XMLstruct converter 
%
% Usage
%   xml = import_digatron_xls(file_in) 
% Read filename (*.csv file) and converts to xml (VEHLIB XMLstruct)
% Inputs:
% - file_in (string): filename or full pathname
% - options (string): containing the following characters
%   - 'v': verbose, tells what it does
%
% Outputs:
% - xml (struct): structure with XML format 4 VEHLIB
% 
%   See also csv2profiles, import_digatron_res, import_digatron_xls, digatron_res2xml,
% digatron_xls2xml, digatron_csv2xml
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

%TODO: in recent versions of MITSPro, a column named CC2CV exists,
% this may indicate change of CC to CV.
verveh=2.0;

%0.-Errors:
%0.1.- Check file existance
[D F E] = fileparts(file_in);
filename = [F E];

if ~exist(file_in,'file')
    fprintf('import_digatron_csv: file does not exist: %s\n',file_in);
    xml = [];
    return;
end
% chrono=tic;
% fid = fopen(file_in);
fid = fopen (file_in,'r','n','ISO-8859-11');
[cycler,line1] = which_cycler(fid);
fclose(fid);

if ~strncmp(cycler,'digatron_csv',9)
    %Probably an error reading xls file:
    fprintf('ERROR: not an digatron csv file: %s\n',file_in);
    xml = [];
    return;
end

%1.- reading file
params = struct;  % see csv2profiles if some params are needed
% params.U_thres = 5*min(diff(unique(U)));
% params.I_thres = 5*min(diff(unique(I)));
% params.testtime_fmt = 'HH:MM:SS';
params.date_fmt = '';

col_names = {'Time Stamp','Prog Time','Voltage','Current','Step','Capacity','',''};

[profiles, other_cols] = csv2profiles(file_in,col_names,params);
profiles_units = {'s','V','A','','Ah','s'};

%3.- creer XML
%3.1.- introduire entete:
[XMLHead, err] = makeXMLHead('digatron',date,'',sprintf('digatron_csv2xml version:%.2f',verveh));
%3.2.- metatable
[XMLMetatable, err] = makeXMLMetatable(filename,date,filename,'');


%3.3.- profiles variables
variables = fieldnames(profiles);
%change some variable names: (see doc/structure specification)
variables_names = variables;variables_names = variables;
variables_names(ismember(variables,{'datetime'})) = {'tabs'};
variables_names(ismember(variables,{'m'})) = {'mode'};

XMLVars = cell(size(variables));
for ind = 1:length(variables)
    [XMLVars{ind}, errorcode] = ...
        makeXMLVariable((variables_names{ind}), (profiles_units{ind}), '%f', (variables_names{ind}), profiles.(variables{ind}));
end

%3.4 other_cols
variables = fieldnames(other_cols);

%separate unis
[units,variables] = regexpFiltre(variables(2:end),'_units$');

%TODO: standard variable names:
new_variables = regexprep(variables,'Step_Time', 'tp');
%     'Step_Index' , 'Step'
new_variables = regexprep(new_variables,'Step_Index' , 'Step');
%     'Cycle_Index' , 'Cycle'
new_variables = regexprep(new_variables,'Cycle_Index' , 'Cycle');
%     'Current' , 'I'
new_variables = regexprep(new_variables,'Current' , 'I');
%     'Voltage' , 'U'
% new_variables = regexprep(new_variables,'Voltage' , 'U');
%
new_variables = regexprep(new_variables,'Aux_Voltage_' , 'U');
%
new_variables = regexprep(new_variables,'Aux_Temperature_' , 'T');


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
