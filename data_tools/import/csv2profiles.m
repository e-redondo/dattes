function [profiles, other_cols] = csv2profiles(file_in,col_names,params)
% csv2profiles Read CSV file and get profiles
%
% Usage:
% [profiles, other_cols] = csv2profiles(file_in,col_names,params)
%
% Inputs:
% - file_in [1xp string]: pathname to .csv file
% - col_names [1x12 cell string]:
%  {'datetime','t','U','I','mode','T','dod_ah','soc','Step', 'Ah', 'Ah_dis', 'Ah_cha'}
%    - e.g. for Arbin:     col_names = {'Date_Time','Test_Time(s)','Voltage(V)','Current(A)',...
%         '','','','','Step_Index','',...
%         'Discharge_Capacity(Ah)','Charge_Capacity(Ah)'};
% - params [(optional) 1x1 struct], with (optional fields:
%    - I_thres [1x1 double]: Current (A) threshold for which_mode
%    - U_thres [1x1 double]: Voltage (V) threshold for which_mode
%    - date_fmt: 'dd/mm/yyyy HH:MM:SS.SSS', 'mm/dd/yyyy HH:MM:SS.SSS', 'yyyy/mm/dd HH:MM:SS.SSS'
%    - colsep: ','
%
% Outputs:
% - profiles [1x1 struct] with fields:
%   - datetime [nx1 double]
%   - t [nx1 double]
%   - U [nx1 double]
%   - I [nx1 double]
%   - mode [nx1 double]
%   - T [nx1 double]
%   - dod_ah [nx1 double]
%   - soc [nx1 double]
%   - step [nx1 double]
%   - ah [nx1 double]
%   - ah_dis [nx1 double]
%   - ah_cha [nx1 double]
% - other_cols:
%
% See also which_mode
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab:
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

%profiling:
% 100 lines: 0.4 sec.
% 1000 lines: 1.15 sec.
% 10000 lines: 9 sec.
% 50000 lines: 50 sec.
%
%changing str2num by sscanf
% 10000 lines: 7.3 sec. (-20%)
%doing datenum only in first 1000 points
% 10000 lines: 3.7 sec. (-50%)
%bufering (1000 lines, datenum on 100 lines on each 1000)
% 10000 lines: 2.9 sec. (-20%, total -70%)
% 50000 lines: 14 sec. (total -70%)
% 346477 lines: 104 sec. (same ratio, but using swap memory 8GB RAM full)

%TODO: current sign convention (assumed I<0 = discharge)
%TODO: number of header lines to skip
%TODO: units in second line?

default_params.I_thres = 0;% 0 = calculate before which_mode
default_params.U_thres = 0;% 0 = calculate before which_mode
default_params.date_fmt = '';%empty = let MATLAB detect date format
default_params.colsep = ',';
default_params.buf_size = 1000;% buffer size (number of lines)
default_params.date_fmt = 'mm/dd/yyyy HH:MM:SS.FFF'; % e.g. mm/dd/yyyy HH:MM:SS.FFF
default_params.date_fmt = 'mm/dd/yyyy HH:MM:SS AM'; % e.g. mm/dd/yyyy HH:MM:SS.FFF
% default_params.testtime_fmt = ''; %default test time format seconds
% default_params.testtime_fmt = 'HH:MM:SS.FFF';% alternative format (seen in digatron)
default_params.variable_list = '';% empty list = keep names as found
default_params.units_list = '';% empty list = try to find units
default_params.header_lines = 0;% unknown number of header lines >> try to find a number

if ~exist('params','var')
    params = struct;
end
if ~exist('col_names','var')
    col_names = {'datetime','t','U','I','mode','T','dod_ah','soc','', '', '', ''};
end
if ~isfield(params,'I_thres')
    params.I_thres = default_params.I_thres;
end
if ~isfield(params,'U_thres')
    params.U_thres = default_params.U_thres;
end
if ~isfield(params,'colsep')
    params.colsep = default_params.colsep;
end
if ~isfield(params,'date_fmt')
    params.date_fmt = default_params.date_fmt;
end
if ~isfield(params,'variable_list')
    params.variable_list = default_params.variable_list;
end
if ~isfield(params,'units_list')
    params.units_list = default_params.units_list;
end
if ~isfield(params,'header_lines')
    params.header_lines = default_params.header_lines;
end
% if ~isfield(params,'testtime_fmt')
%     params.testtime_fmt = default_params.testtime_fmt;
% end

profiles = [];
other_cols = [];


[header_lines, data_columns,tail_lines] = parse_mixed_data_csv(file_in,params);
if length(tail_lines)>length(data_columns{1})
    if isempty(which('readtable'))
        %Octave: no readtable function >>> Error
        error('csv2profiles: Inconsistent file %s\n',file_in);
    else
        %probably a non consistent CSV (e.g. btsuite files)
        %try readtable:
        fprintf('csv2profiles: Inconsistent file. Trying with readtable\n');
        A = readtable(file_in);
        var_list = A.Properties.VariableNames;

        data_columns = cell(size(A,2),1);
        for ind = 1:length(data_columns)
            data_columns{ind} = A.(var_list{ind});
        end
    end
end

if isempty(header_lines)
    error('csv2profiles: no header in csv file')
end
if length(header_lines)<2
    variables_line = header_lines{1};
    units_line = header_lines{1};
else
    %probably last two lines of header are for variable names and units:
    variables_line = header_lines{end-1};
    units_line = header_lines{end};
end

variables = regexp(variables_line,params.colsep,'split');
%ignore empty matchs
ind_empty = cellfun(@isempty,variables);
variables = variables(~ind_empty);
units = regexp(units_line,params.colsep,'split');
ind_empty = cellfun(@isempty,units);
units = units(~ind_empty);

if length(units)<=1
    fprintf('csv2profiles, ERROR: a problem maybe with column separator "%s"\n',params.colsep);
    fprintf('before-last line of header: "%s"\n',variables_line);
    fprintf('last line of header: "%s"\n',units_line);
    return;
end
if length(variables)<length(units)
    %probably the same last line of header is for variable names and units
    variables = units;
end

if isempty(params.variable_list)
    %keep variables as found in file
    new_variables = variables;
else
    %rename variables as in params
    new_variables = params.variable_list;
end

if isempty(params.units_list)
    %find units from header_line
    units = find_units(units);
else
    %convert to char each element of the cell to avoid 0x0 doubles in empties
    units = cellfun(@char,params.units_list,'UniformOutput',false);
end


%remove empty columns (empty variable name)
ind_empty_col = cellfun(@isempty,variables);
variables = variables(~ind_empty_col);
new_variables = new_variables(~ind_empty_col);
units = units(~ind_empty_col);
data_columns = data_columns(~ind_empty_col);

%PUT in temporal order (sometimes csv files are not in order):
ind_col_t = find_col_index(new_variables,col_names{2});
t = data_columns{ind_col_t};
if ~isempty(t)
    if iscell(t)
        if all(cellfun(@ischar,t))
            t = time_str_to_number(t);
        elseif all(cellfun(@isnumeric,t))
            t = vertcat(t{:});
        else
            %mised types in time = ERROR
            error('csv2profiles: bad time column (mixed strings and numbers)')
        end
    end

    %[t_sorted,index_sorted] = sort(t);
    %using unique innstead sort prevents errors in data processing (e.g.
    %which_mode)
    [t_sorted,index_sorted] = unique(t);
    if ~isequal(t_sorted,t)
        %order columns if necessary (t_sorted different than t)
        data_columns = cellfun(@(x) x(index_sorted),data_columns,'UniformOutput',false);
        t = t_sorted;
    end
end

%% find column index of interesting variables:
%datetime: 'datetime'
ind_col_dt = find_col_index(new_variables,col_names{1});
%U: 'cell_voltage'
ind_col_U = find_col_index(new_variables,col_names{3});
%I: 'current'
ind_col_I = find_col_index(new_variables,col_names{4});
%'mode'
ind_col_mode = find_col_index(new_variables,col_names{5});
%'T'
ind_col_T = find_col_index(new_variables,col_names{6});
%'dod_ah'
ind_col_dod_ah = find_col_index(new_variables,col_names{7});
%'soc'
ind_col_soc = find_col_index(new_variables,col_names{8});
%Step: 'Step index'
ind_col_step = find_col_index(new_variables,col_names{9});
%'Ah'
ind_col_ah = find_col_index(new_variables,col_names{10});
%'Ah_dis'
ind_col_ahdis = find_col_index(new_variables,col_names{11});
%'Ah_cha'
ind_col_ahcha = find_col_index(new_variables,col_names{12});


%fill emptys with nans:
ind_nan = cellfun(@isempty,data_columns);
data_columns(ind_nan) = {'nan'};

%% structure data
U = data_columns(ind_col_U);
I = data_columns(ind_col_I);
Step = data_columns(ind_col_step);
%
Ah = data_columns(ind_col_ah);
Ah_dis = data_columns(ind_col_ahdis);
Ah_cha = data_columns(ind_col_ahcha);

mode = data_columns(ind_col_mode);
T = data_columns(ind_col_T);
dod_ah = data_columns(ind_col_dod_ah);
soc = data_columns(ind_col_soc);

%% convert cells to numbers
U = vertcat(U{:});
I = vertcat(I{:});
Step = vertcat(Step{:});
Ah = vertcat(Ah{:});
Ah_dis = vertcat(Ah_dis{:});
Ah_cha = vertcat(Ah_cha{:});
mode = vertcat(mode{:});
T = vertcat(T{:});
dod_ah = vertcat(dod_ah{:});
soc = vertcat(soc{:});


[ah, ah_dis, ah_cha] = format_amphour(Ah_dis, Ah_cha);

if isempty(Ah)
    if max(abs(Ah_dis))>0
        Ah = Ah_cha-Ah_dis;
    else
        Ah = Ah_cha+Ah_dis;
    end
else
    ah = Ah;%keep Ah calculated by cycler if given
end



%pack data:
%     profiles.datetime = m2edate(datetime);
profiles.datetime = []; % prealloc first field 'datetime' 
profiles.t = t;
profiles.U = U;
profiles.I = I;
profiles.mode = mode;
profiles.T = T;
profiles.dod_ah = dod_ah;
profiles.soc = soc;
profiles.step = Step;
profiles.ah = ah;
profiles.ah_dis = ah_dis;
profiles.ah_cha = ah_cha;


%other_cols:
ind_other_cols = find(~ismember(new_variables,col_names));
if isempty(ind_other_cols)
    other_cols = struct;
else
%     other_cols.t = t;
%     if ~isempty(Step)
%         other_cols.Step = Step;
%         other_cols.Step_units = '';
%     end
%     other_cols.Ah = Ah;
%     other_cols.Ah_units = 'Ah';
    
    for ind_col = 1:length(ind_other_cols)
        data_this_col = data_columns(ind_other_cols(ind_col));
        if all(cellfun(@isnumeric,data_this_col))
            %convert to numeric array
            this_col = vertcat(data_this_col{:});
        else
            %keep as cell, but resize
            this_col = data_this_col{:};
        end
        %TODO:put this part in function (clean_col_name).
        this_col_name = regexprep(new_variables{ind_other_cols(ind_col)},'^[^a-zA-Z]','');
        % remove units from variable names:
        this_col_name = regexprep(this_col_name,'\(.+\)','');
        this_col_name = regexprep(this_col_name,'\s','_');
        this_col_name = regexprep(this_col_name,'/','');
        this_col_name = regexprep(this_col_name,'\\','');
        this_col_name = regexprep(this_col_name,'\(','');
        this_col_name = regexprep(this_col_name,'\)','');
        this_col_name = regexprep(this_col_name,'\[','');
        this_col_name = regexprep(this_col_name,'\]','');
        this_col_name = regexprep(this_col_name,'\{','');
        this_col_name = regexprep(this_col_name,'\}','');
        %remove 'units' at end of variable names
        this_col_name = regexprep(this_col_name,'_s$','');%s
        this_col_name = regexprep(this_col_name,'_A$','');%A
        this_col_name = regexprep(this_col_name,'_V$','');%V
        this_col_name = regexprep(this_col_name,'_Ah$','');%Ah
        this_col_name = regexprep(this_col_name,'_W$','');%W
        this_col_name = regexprep(this_col_name,'_Wh$','');% Wh
        this_col_name = regexprep(this_col_name,'_Ohm$','');% Ohm
        this_col_name = regexprep(this_col_name,'_AhV$','');% Ah/V
        this_col_name = regexprep(this_col_name,'_VAh$','');% V/Ah
        this_col_name = regexprep(this_col_name,'_Vs$','');% V/s
        this_col_name = regexprep(this_col_name,'_Cs$',''); %deg Celsius/s
        this_col_name = regexprep(this_col_name,'_C$',''); %deg Celsius

        %DEBUG
        %     fprintf('%s\n',this_col_name);
        %     fprintf('%s\n',genvarname(this_col_name));

        other_cols.(this_col_name) = this_col;
        other_cols.([this_col_name '_units']) = units{ind_other_cols(ind_col)};

    end
end

if isempty(mode)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %calculate mode
    %set thresholds if they are set to zero:
    if params.I_thres==0
        %here, threshold is maximum between:
        % - min difference (resolution)
        % - max abs value divided by 2^12 (12bits)
        params.I_thres = max(4*min(diff(unique(profiles.I))),max(abs(profiles.I))/2^12);

        if isempty(params.I_thres)
            % constant value in all I
            params.I_thres = 1;
        end
    end
    if params.U_thres==0
        params.U_thres = max(4*min(diff(unique(profiles.U))),max(abs(profiles.U))/2^12);
        if isempty(params.U_thres)
            % constant value in all U
            params.U_thres = 1;
        end
    end

    %TODO: Step should go in profiles variables, not in other_cols
    if ~isempty(t) && isfield(profiles,'step')
        if isempty(profiles.step)
            %TODO: 0.01 = top 1% changes in current mean new step.
            % maybe not robust
            profiles.step = find_steps(profiles.t,profiles.I,profiles.U,0.01);
        end
        %m: 'mode'(CC,CV,rest,EIS,profile)
        mode = which_mode(profiles.t,profiles.I,profiles.U,profiles.step,params.I_thres,params.U_thres);
    else
        mode = [];
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    profiles.mode = mode;
end


%datetime
%FIX: get datetime just at each ind_start, then convert to seconds
% and finally calculate datetime from first value + t
if isempty(ind_col_dt)
    % in this case date_time not found, put test time instead
    % need to fix afterwards with initial time date of test.
    date_time = t; 
else
    date_time = data_columns{ind_col_dt};

if isempty(params.date_fmt)
    date_time = datenum_guess(date_time(1));
else
    date_time = datenum_guess(date_time(1),params.date_fmt);
end
if isempty(date_time) || ~isnumeric(date_time)
    %no column datetime found: put test time instead datetime
    profiles.datetime = profiles.t;
else
    date_time = m2edate(date_time);
    profiles.datetime = date_time(1)+profiles.t-profiles.t(1);
end
end
end

function ind_col = find_col_index(header_line,col_name)

if isempty(col_name)
    ind_col = [];
    return
end
ind_col = cellfun(@(x) strncmp(x,col_name,length(col_name)),header_line);

if length(find(ind_col))>1
    %get candidates for this column
    candidates = header_line(ind_col);
    %select shortest one (e.g.: Step vs. Step Time, choose Step):
    [~,ind_short_candidate] = min(cellfun(@length,candidates));

    ind_col = cellfun(@(x) strcmp(x,candidates(ind_short_candidate)),header_line);

    if length(find(ind_col))>1
        fprintf('ERROR: several columns for %s\n',col_name);
    end
elseif isempty(find(ind_col))
    fprintf('ERROR: no column found for %s\n',col_name);
end
end


function units = find_units(unit_line_words)

%2.1.- measurement units:
%anything enclosed into brackets [] or parentheses () or {}:
unit_line_words = regexprep(unit_line_words,'\[','(');
unit_line_words = regexprep(unit_line_words,'\{','(');
unit_line_words = regexprep(unit_line_words,'\]',')');
unit_line_words = regexprep(unit_line_words,'\}',')');
units = regexp(unit_line_words,'\(.+\)','match','once');
units = regexprep(units,'\(','');
units = regexprep(units,'\)','');
%other units
I = ~cellfun(@isempty,strfind(unit_line_words,'Voltage')) & cellfun(@isempty,units);
[units{I}] = deal('V');
I = ~cellfun(@isempty,strfind(unit_line_words,'Time')) & cellfun(@isempty,units);
[units{I}] = deal('s');
I = ~cellfun(@isempty,strfind(unit_line_words,'Current')) & cellfun(@isempty,units);
[units{I}] = deal('A');
I = ~cellfun(@isempty,strfind(unit_line_words,'Capacity')) & cellfun(@isempty,units);
[units{I}] = deal('Ah');
I = ~cellfun(@isempty,strfind(unit_line_words,'Energy')) & cellfun(@isempty,units);
[units{I}] = deal('Wh');
I = ~cellfun(@isempty,strfind(unit_line_words,'Power')) & cellfun(@isempty,units);
[units{I}] = deal('W');
I = ~cellfun(@isempty,strfind(unit_line_words,'dV/dt')) & cellfun(@isempty,units);
[units{I}] = deal('V/s');
%TODO: often, temperatures come with special caracters (errors in unicode
%for degres), force always to celsius?
I = ~cellfun(@isempty,strfind(unit_line_words,'Temperature'));
[units{I}] = deal('C');
%change fractions to underscores:
% units = regexprep(units,'/','_');

end
