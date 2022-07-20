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

if ~exist('params','var')
    params = struct;
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
if ~isfield(params,'buf_size')
    params.buf_size = default_params.buf_size;
end

profiles = [];
other_cols = [];

%open file
fid = fopen(file_in);

%TODO: n_header_lines
%read header line
header_line = fgetl(fid);
header_line = regexp(header_line,params.col_sep,'split');
header_line = header_line';

%find units from header_line
units = find_units(header_line);

if length(header_line)<=1
    fprintf('ERROR: a problem maybe with column separator "%s"\n',params.col_sep);
    return;
end
%read data
data_lines = cell(0);
while ~feof(fid) % && length(data_lines)<1000 %DEBUG (limit number of lines)
    data_lines{end+1} = fgetl(fid);
end

%transpose to get size nx1:
data_lines = data_lines';

%each line should be 1xm, with m= length(header_line)
data_lines = regexp(data_lines,params.col_sep,'split');

% check if all rows same length:
if any(cellfun(@length,data_lines)~=length(header_line))
    fprintf('ERROR: not all lines with same number of columns %s\n',file_in);
    return;
end

% convert to nxm cell:
data_lines_all = vertcat(data_lines{:});

%% find column index of interesting variables:
%datetime: 'datetime'
ind_col_dt = find_col_index(header_line,col_names{1});
%t: 'test_time'
ind_col_t = find_col_index(header_line,col_names{2});
%U: 'cell_voltage'
ind_col_U = find_col_index(header_line,col_names{3});
%I: 'current'
ind_col_I = find_col_index(header_line,col_names{4});
%Step: 'Step index'
ind_col_step = find_col_index(header_line,col_names{5});
% %T: 'Temperature'
% ind_col_temp = find_col_index(header_line,col_names{6});
%'Ah'
ind_col_ah = find_col_index(header_line,col_names{6});
%'Ah_dis'
ind_col_ahdis = find_col_index(header_line,col_names{7});
%'Ah_cha'
ind_col_ahcha = find_col_index(header_line,col_names{8});
    
%buffering: process 'buf_size' lines each time'
ind_start = 1:params.buf_size:size(data_lines,1);
ind_end = [ind_start(2:end)-1 size(data_lines,1)];

for ind = 1:length(ind_start)
    data_lines = data_lines_all(ind_start(ind):ind_end(ind),:);
    %fill emptys with nans:
    ind_nan = cellfun(@isempty,data_lines);
    data_lines(ind_nan) = {'nan'};
    
    %% structure data
    t = cellfun(@(x) sscanf(x,'%f'),data_lines(:,ind_col_t));
    U = cellfun(@(x) sscanf(x,'%f'),data_lines(:,ind_col_U));
    I = cellfun(@(x) sscanf(x,'%f'),data_lines(:,ind_col_I));
    Step = cellfun(@(x) sscanf(x,'%f'),data_lines(:,ind_col_step));
%     T = cellfun(@(x) sscanf(x,'%f'),data_lines(:,ind_col_temp));
    Ah = cellfun(@(x) sscanf(x,'%f'),data_lines(:,ind_col_ah));
    Ah_dis = cellfun(@(x) sscanf(x,'%f'),data_lines(:,ind_col_ahdis));
    Ah_cha = cellfun(@(x) sscanf(x,'%f'),data_lines(:,ind_col_ahcha));
    
%     %FIX: get datetime from some points (first 1000), then convert to seconds
%     % and finally calculate datetime from first value + t
%     % In fact, doing datenum and all point can crash MATLAB in big files
%     end_dt = min(100,size(data_lines,1));
%     if isempty(params.date_fmt)
%         datetime = cellfun(@datenum,data_lines(1:end_dt,ind_col_dt));
%     else
%         datetime = cellfun(@(x) datenum(x,params.date_fmt),data_lines(1:end_dt,ind_col_dt));
%     end
%     datetime = m2edate(datetime);
%     datetime = datetime(1)+t;
    
    
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
    
    %set thresholds if they are set to zero:
    if params.I_thres==0
        %here, threshold is maximum between:
        % - min difference (resolution)
        % - max abs value divided by 2^12 (12bits)
        params.I_thres = max(2*min(diff(unique(I))),max(abs(I))/2^12);
        
        if isempty(params.I_thres)
            % constant value in all I
            params.I_thres = 1;
        end
    end
    if params.U_thres==0
        params.U_thres = max(2*min(diff(unique(U))),max(abs(U))/2^12);
        if isempty(params.U_thres)
            % constant value in all U
            params.U_thres = 1;
        end
    end
    
    
    
    %m: 'mode'(CC,CV,rest,EIS,profile)
    m = which_mode(t,I,U,Step,params.I_thres,params.U_thres);
    
    %pack data:
%     profiles(ind).datetime = m2edate(datetime);
    profiles(ind).t = t;
    profiles(ind).U = U;
    profiles(ind).I = I;
    profiles(ind).m = m;
%     profiles(ind).T = T;
    profiles(ind).Ah = Ah;
    
    %other_cols:
    ind_other_cols = find(~ismember(header_line,col_names));
    other_cols(ind).t = t;
    for ind_col = 1:length(ind_other_cols)
        try % try to conver to number
            % TODO: replace empty strings by nans and try to convert to number
            data_this_col = data_lines(:,ind_other_cols(ind_col));
            data_spaces = num2cell(char(' '*ones(size(data_this_col))));
            %     data_this_col = reshape([data_this_col';data_spaces'],[],1);
            
            data_this_col = strcat(data_this_col,data_spaces);
            this_col_string = [data_this_col{:}];
            this_col =  sscanf(this_col_string,'%f ');
            %     this_col = cellfun(@(x) sscanf(x,'%f'),data_lines(:,ind_other_cols(ind_col)));
        catch% if not possible keep as cell str
            this_col = data_lines(:,ind_other_cols(ind_col));
        end
        %TODO:put this part in function (clean_col_name).
        this_col_name = regexprep(header_line{ind_other_cols(ind_col)},'^[^a-zA-Z]','');
        this_col_name = regexprep(this_col_name,'\s','_');
        this_col_name = regexprep(this_col_name,'/','');
        this_col_name = regexprep(this_col_name,'\\','');
        this_col_name = regexprep(this_col_name,'\(','');
        this_col_name = regexprep(this_col_name,'\)','');
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
        
        other_cols(ind).(this_col_name) = this_col;
        other_cols(ind).([this_col_name '_units']) = units{ind_other_cols(ind_col)};
        
    end
end

%merging buffer:
fieldlist = fieldnames(profiles);
for ind = 1:length(fieldlist)
    profiles_all.(fieldlist{ind}) = vertcat(profiles(:).(fieldlist{ind}));
end


fieldlist = fieldnames(other_cols);
[units, variables] = regexpFiltre(fieldlist,'_units$');
for ind = 1:length(variables)
    other_cols_all.(variables{ind}) = vertcat(other_cols(:).(variables{ind}));
end
for ind = 1:length(units)
    other_cols_all.(units{ind}) = other_cols(1).(units{ind});
end

profiles = profiles_all;
other_cols = other_cols_all;

%datetime
%FIX: get datetime just at each ind_start, then convert to seconds
% and finally calculate datetime from first value + t
if isempty(params.date_fmt)
    datetime = cellfun(@datenum,data_lines_all(ind_start,ind_col_dt));
else
    datetime = cellfun(@(x) datenum(x,params.date_fmt),data_lines_all(ind_start,ind_col_dt));
end
datetime = m2edate(datetime);
profiles.datetime = datetime(1) + profiles.t;

% TODO mode: on all data, not in buffer, last buffer can give identification
% problems if too short

end

function ind_col = find_col_index(header_line,col_name)

if isempty(col_name)
    ind_col = [];
    return
end
ind_col = cellfun(@(x) strncmp(x,col_name,length(col_name)),header_line);

if length(find(ind_col))~=1
    fprintf('ERROR: several columns for %s\n',col_name);
    return;
end
end

function units = find_units(header)

%2.1.- unites de mesure
units = regexp(header,'\(.+)','match','once');
units = regexprep(units,'\(','');
units = regexprep(units,')','');
%other units
I = ~cellfun(@isempty,strfind(header,'Voltage'));
[units{I}] = deal('V');
I = ~cellfun(@isempty,strfind(header,'Time'));
[units{I}] = deal('s');
I = ~cellfun(@isempty,strfind(header,'Current'));
[units{I}] = deal('A');
I = ~cellfun(@isempty,strfind(header,'Capacity'));
[units{I}] = deal('Ah');
I = ~cellfun(@isempty,strfind(header,'Energy'));
[units{I}] = deal('Wh');
I = ~cellfun(@isempty,strfind(header,'Power'));
[units{I}] = deal('W');
I = ~cellfun(@isempty,strfind(header,'dV/dt'));
[units{I}] = deal('V/s');
I = ~cellfun(@isempty,strfind(header,'Temperature'));%TODO search in Aux_Global_Table
[units{I}] = deal('C');
%change fractions to underscores:
% units = regexprep(units,'/','_');

end
