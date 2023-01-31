function [profiles, other_cols] = csv2profiles(file_in,col_names,params)
% csv2profiles Read CSV file and get profiles
%
% Usage:
% [profiles, other_cols] = csv2profiles(file_in,col_names,col_sep,dec_sep,date_fmt)
%
% Inputs:
% - file_in [1xp string]: pathname to .csv file
% - col_names [1x9 cell string]: {'datetime','t','U','I','Step', 'Ah', 'Ah_dis', 'Ah_cha'}
%    - e.g. for Arbin: col_names = {'Date Time','Test Time (s)','Voltage (V)',
%                               'Current (A)', 'Step Index','',
%                               'Discharge Capacity (Ah)','Charge Capacity (Ah)'};
% - params [(optional) 1x1 struct], with (optional fields:
%    - I_thres [1x1 double]: Current (A) threshold for which_mode
%    - U_thres [1x1 double]: Voltage (V) threshold for which_mode
%    - date_fmt: 'dd/mm/yyyy HH:MM:SS.SSS', 'mm/dd/yyyy HH:MM:SS.SSS', 'yyyy/mm/dd HH:MM:SS.SSS'
%    - col_sep: ','
%
% Outputs:
% - profiles:
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
default_params.col_sep = ',';
default_params.buf_size = 1000;% buffer size (number of lines)
default_params.date_fmt = 'mm/dd/yyyy HH:MM:SS.FFF'; % e.g. mm/dd/yyyy HH:MM:SS.FFF
default_params.date_fmt = 'mm/dd/yyyy HH:MM:SS AM'; % e.g. mm/dd/yyyy HH:MM:SS.FFF
default_params.testtime_fmt = ''; %default test time format seconds
% default_params.testtime_fmt = 'HH:MM:SS.FFF';% alternative format (seen in digatron)

if ~exist('params','var')
    params = struct;
end
if ~exist('col_names','var')
    col_names = {'datetime','t','U','I','m','T','dod_ah','soc'};
end
if ~isfield(params,'I_thres')
    params.I_thres = default_params.I_thres;
end
if ~isfield(params,'U_thres')
    params.U_thres = default_params.U_thres;
end
if ~isfield(params,'col_sep')
    params.col_sep = default_params.col_sep;
end
if ~isfield(params,'date_fmt')
    params.date_fmt = default_params.date_fmt;
end
if ~isfield(params,'testtime_fmt')
    params.testtime_fmt = default_params.testtime_fmt;
end

profiles = [];
other_cols = [];


%TODO: n_header_lines

[header_lines, data_columns] = parse_mixed_data_csv(file_in);
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

variables = regexp(variables_line,params.col_sep,'split');
units = regexp(units_line,params.col_sep,'split');

if length(units)<=1
    fprintf('csv2profiles, ERROR: a problem maybe with column separator "%s"\n',params.col_sep);
    fprintf('nefore last line of header: "%s"\n',variables_line);
    fprintf('last line of header: "%s"\n',units_line);
    return;
end
if length(variables)<length(units)
    %probably the same last line of header is for variable names and units
    variables = units;
end
%find units from header_line
units = find_units(units);


%PUT in temporal order (sometimes csv files are not in order):
ind_col_t = find_col_index(variables,col_names{2});
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
        %order columns if necessary (t_sorted different than t
        data_columns = cellfun(@(x) x(index_sorted),data_columns,'UniformOutput',false);
        t = t_sorted;
    end
end

%% find column index of interesting variables:
%datetime: 'datetime'
ind_col_dt = find_col_index(variables,col_names{1});
%U: 'cell_voltage'
ind_col_U = find_col_index(variables,col_names{3});
%I: 'current'
ind_col_I = find_col_index(variables,col_names{4});
%Step: 'Step index'
ind_col_step = find_col_index(variables,col_names{5});
% %T: 'Temperature'
% ind_col_temp = find_col_index(header_line,col_names{6});
%'Ah'
ind_col_ah = find_col_index(variables,col_names{6});
%'Ah_dis'
ind_col_ahdis = find_col_index(variables,col_names{7});
%'Ah_cha'
ind_col_ahcha = find_col_index(variables,col_names{8});


%fill emptys with nans:
ind_nan = cellfun(@isempty,data_columns);
data_columns(ind_nan) = {'nan'};

    %% structure data
    U = data_columns(ind_col_U);
    I = data_columns(ind_col_I);
    Step = data_columns(ind_col_step);
%     T = data_lines(ind_col_temp);
    Ah = data_columns(ind_col_ah);
    Ah_dis = data_columns(ind_col_ahdis);
    Ah_cha = data_columns(ind_col_ahcha);

    %% convert cells to numbers
    U = vertcat(U{:});
    I = vertcat(I{:});
    Step = vertcat(Step{:});
    Ah = vertcat(Ah{:});
    Ah_dis = vertcat(Ah_dis{:});
    Ah_cha = vertcat(Ah_cha{:});

    if isempty(Ah)
        if max(abs(Ah_dis))>0
            Ah = Ah_cha-Ah_dis;
        else
            Ah = Ah_cha+Ah_dis;
        end
    end
%     if isempty(T)
%         T = nan(size(t));
%     end

    %pack data:
%     profiles.datetime = m2edate(datetime);
    profiles.t = t;
    profiles.U = U;
    profiles.I = I;
%     profiles.mode = m;
%     profiles.T = T;
    profiles.Ah = Ah;

    %other_cols:
    ind_other_cols = find(~ismember(variables,col_names));
    if ~isempty(ind_other_cols)
        other_cols.t = t;
        other_cols.Step = Step;
        other_cols.Step_units = '';
        for ind_col = 1:length(ind_other_cols)
                data_this_col = data_columns(ind_other_cols(ind_col));
                if all(cellfun(@isnumeric,data_this_col))
                    %convert to numeric array
                    this_col = vertcat(data_this_col{:});
                else
                    %keep as cell
                    this_col = data_this_col;
                end
            %TODO:put this part in function (clean_col_name).
            this_col_name = regexprep(variables{ind_other_cols(ind_col)},'^[^a-zA-Z]','');
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


    if ~isempty(t)
        %m: 'mode'(CC,CV,rest,EIS,profile)
        m = which_mode(profiles.t,profiles.I,profiles.U,other_cols.Step,params.I_thres,params.U_thres);
    else
        m=[];
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
profiles.mode = m;



%datetime
%FIX: get datetime just at each ind_start, then convert to seconds
% and finally calculate datetime from first value + t
date_time = data_columns{ind_col_dt};
if isempty(params.date_fmt)
    date_time = datenum(date_time(1:10:end));
else
    date_time = datenum(date_time(1),params.date_fmt);
end
if isempty(date_time)
    %no column datetime found
    profiles.datetime = date_time;
else
    date_time = m2edate(date_time);
    profiles.datetime = date_time(1)+profiles.t-profiles.t(1);
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
I = ~cellfun(@isempty,strfind(unit_line_words,'Voltage'));
[units{I}] = deal('V');
I = ~cellfun(@isempty,strfind(unit_line_words,'Time'));
[units{I}] = deal('s');
I = ~cellfun(@isempty,strfind(unit_line_words,'Current'));
[units{I}] = deal('A');
I = ~cellfun(@isempty,strfind(unit_line_words,'Capacity'));
[units{I}] = deal('Ah');
I = ~cellfun(@isempty,strfind(unit_line_words,'Energy'));
[units{I}] = deal('Wh');
I = ~cellfun(@isempty,strfind(unit_line_words,'Power'));
[units{I}] = deal('W');
I = ~cellfun(@isempty,strfind(unit_line_words,'dV/dt'));
[units{I}] = deal('V/s');
I = ~cellfun(@isempty,strfind(unit_line_words,'Temperature'));%TODO search in Aux_Global_Table
[units{I}] = deal('C');
%change fractions to underscores:
% units = regexprep(units,'/','_');

end
