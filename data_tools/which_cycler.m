function [cycler, line1, line2, header_lines] = which_cycler(fid)
% which_cycler detect from wich cycler the file is.
%
% Usage:
% [cycler, ligne1, ligne2, header_lines] = which_cycler(fid)
% [cycler, ligne1, ligne2, header_lines] = which_cycler(filename)
%
% Inputs:
% - fid (file handler)
% - filename (char): path to the file
%
% Outputs:
% - cycler [(1xp) string]: string defining the cycler type
%   - 'bio': Biologic EC-Lab or BT-Lab file
%   - 'pricsv': Princeton Zmeter file in csv format
%   - 'biocsv': Biologic file in csv format
%   - 'pribrut': Princeton Zmeter file in original format (xml?)
%   - 'bitrode_csv': Bitrode csv file
%   - 'bitrode_csv_v2': Bitrode csv file new version
%   - 'bitrode_csv_with_header': Bitrode csv file with header
%   - 'arbin_csv_v1': Arbin csv file first version
%   - 'arbin_csv_v2': Arbin csv file second version
%   - 'neware_csv': Neware csv file
%   - 'digatron_csv': Digatron csv file
%   - if unknowkn cycler, first line is returned
% - line1 [string]: file's first line (if file is text type)
% - line2 [string]: file's second line (if file is text type), if bitrode
% file, last file's line is returned
% - header_lines [nx1 cell]: header lines
%
% See also: dattes_import
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab:
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

if ischar(fid)
    fid = fopen_safe(fid);
end
cycler = '';
line1 = '';
line2 = '';

header_lines = read_csv_header(fid);


%read first line
frewind(fid);
line1 = header_lines{1};
if length(header_lines)<2
  return;%empty file or only line1
end
line2 = header_lines{2};
if length(line2)<2 && length(header_lines)>2
    %if second line is too short, take third one
    line2 = header_lines{3};
end

if ~isempty(regexp(line1,'EC-Lab ASCII FILE','match'))
    cycler = 'bio';%Biologic File
    return
end
if ~isempty(regexp(line1,'BT-Lab ASCII FILE','match'))
    cycler = 'bio';%Biologic File
    return
end

if strncmp(line1,'TimeStamp,Segment',17)
    cycler = 'pricsv';%Princeton File
    return
end
if strncmp(line1,'TimeStamp,mode,ox_red',21)
    cycler = 'biocsv';
    return
end
if strcmp(line1,'<Application>')
    if strcmp(line2,'Name=VersaStudio')
        cycler = 'pribrut';
        return
    end
end
if strncmp(line1,'Total Time,Cycle,Loop Counter #1',32)
    cycler = 'bitrode_csv';
    %find last line:
    fseek(fid,-100,1);
    s=fread(fid,inf, 'uint8=>char')';
    s = regexp(s,'\n','split');
    %put last line in 'line2'
    line2 = s{end};
    %rewind the file
    fseek(fid,0,-1);
    return
elseif ~isempty(regexp(line1,'^"Total Time, S"','match'))
    cycler = 'bitrode_csv_v2';
    %find last line:
    fseek(fid,-100,1);
    s=fread(fid,inf, 'uint8=>char')';
    s = regexp(s,'\n','split');
    %put last line in 'line2'
    line2 = s{end};
    %rewind the file
    fseek(fid,0,-1);
    return
elseif ~isempty(regexp(line1,'^Test Name','match'))
    cycler = 'bitrode_csv_with_header';
    %find last line:
    fseek(fid,-100,1);
    s=fread(fid,inf, 'uint8=>char')';
    s = regexp(s,'\n','split');
    %put last line in 'line2'
    line2 = s{end};
    %rewind the file
    fseek(fid,0,-1);
    return
end
if ~isempty(regexp(line1,'Data_Point,Test_Time\(s\),Date_Time','match'))
    cycler = 'arbin_csv_v1';
    frewind(fid);
    return
end
if ~isempty(regexp(line1,'Data_Point,Date_Time,Test_Time\(s\)','match'))
    cycler = 'arbin_csv_v1';
    frewind(fid);
    return
end
if ~isempty(regexp(line1,'Date_Time,Test_Time\(s\)','match'))
    cycler = 'arbin_csv_v3';%(no data_point column)
    frewind(fid);
    return
end
if ~isempty(regexp(line1,'Data Point,Date Time,Test Time','match'))
    cycler = 'arbin_csv_v2';
    frewind(fid);
    return
end
if ~isempty(regexp(line1,'^Cycle ID','match')) && ~isempty(regexp(line2,'^,\s*Step ID','match'))
    cycler = 'neware_csv';
    return
end
if length(header_lines)>2
    if ~isempty(regexp(header_lines{end-2},'^Time Stamp,Step,Status'))
        cycler = 'digatron_csv';
        return
    end
end
if ~isempty(regexp(line1,'^,ChargeKey,LogDateStamp,version,productnum'))
    cycler = 'hyperion_csv';
    return
end
%unknown type: return first line
cycler = line1;
frewind(fid);
return
end

