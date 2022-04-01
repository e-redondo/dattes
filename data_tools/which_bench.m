function [bench, line1, line2] = which_bench(fid)
% function [banc, ligne1, ligne2] = which_bench(fid)
% Detect from wich equipement the file is.
%
% INPUTS:
% fid (file handler or pathname)
%
% OUTPUTS:
% bench (string): string defining the bench type
%   - 'bio': Biologic EC-Lab or BT-Lab file
%   - 'pricsv': Princeton Zmeter file in csv format
%   - 'biocsv': Biologic file in csv format
%   - 'pribrut': Princeton Zmeter file in original format (xml?)
%   - 'bitrode_csv': Bitrode csv file
% line1 (string): file's first line (if file is text type)
% line2 (string): file's second line (if file is text type)
bench = '';
line1 = '';
line2 = '';
% TODO: Arbin files (xls, res)
% TODO: Bitrode csv file with header
% TODO: Bitrode mdb file

%read first line
line1 = fgetl(fid);
line2 = fgetl(fid);
if length(line2)<2
    line2 = fgetl(fid);
end
%rewind the file
fseek(fid,0,-1);

if strcmp(line1,'EC-Lab ASCII FILE')
    bench = 'bio';%Biologic File
    return
end
if strcmp(line1,'BT-Lab ASCII FILE')
    bench = 'bio';%Biologic File
    return
end

if strncmp(line1,'TimeStamp,Segment',17)
    bench = 'pricsv';%Princeton File
    return
end
if strncmp(line1,'TimeStamp,mode,ox_red',21)
    bench = 'biocsv';
    return
end
if strcmp(line1,'<Application>')
    if strcmp(line2,'Name=VersaStudio')
        bench = 'pribrut';
        return
    end
end
if strncmp(line1,'Total Time,Cycle,Loop Counter #1',32)
    bench = 'bitrode_csv';
    %find last line:
    fseek(fid,-100,1);
    s=fread(fid,inf, 'uint8=>char')';
    s = regexp(s,'\n','split');
    %put last last in 'line2'
    line2 = s{end};
    %rewind the file
    fseek(fid,0,-1);
    return
end
%unknown type: return first line
bench = line1;
return
end