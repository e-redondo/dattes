function t_num = time_str_to_number(t_str)
%time_str_to_number - convert time string to number under three possible formats:
% E.g.: 25:01:01 = 1 day, 1hour, 1 minute, 1second
% E.g.: 1 1:01:01 = 1 day, 1hour, 1 minute, 1second
% E.g.: 1d 1:01:01 = 1 day, 1hour, 1 minute, 1second
%
% This is beceause MATLAB's datenum/datevec give an error by adding automatically
% current year to the result.
% E.g.: datestr(datevec('25:01:01')) = 2 January of current year
%
% Usage: t_num = time_str_to_number(t_str)
%
% Inputs:
% - t_str [char] or [cell] with time in format (dd HH:MM:SS)
%
% Outputs:
% - t_num [nx1 double]: seconds in t_str
%
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

if ischar(t_str)
    t_str = {t_str};
end

%get says
dd = regexp(t_str,'^[0-9]d? ','match','once');

%clean days from t_str to keep just HH:MM:SS:
t_str = regexprep(t_str,'^.* ','');

%search for empty values of days
Ie = cellfun(@isempty,dd);

if all(Ie)
    %format is HH:MM:SS, do not care of days
    dd = zeros(size(t_str));
else
    %take care of days
    %clean trailing spaces and 'd'
    dd = regexprep(dd,'d? ','');
    %put zeros in empty values
    dd(Ie) = deal({'0'});
    %convert to numbers
    dd = str2double(dd);
end

hhmmss = regexp(t_str,':','split');

if any(cellfun(@length,hhmmss)~=3)
    error('time_str_to_number: not compatible string format')
end

hhmmss = str2double(vertcat(hhmmss{:}));

hh = hhmmss(:,1);
mm = hhmmss(:,2);
ss = hhmmss(:,3);

t_num = dd*86400+hh*3600+mm*60+ss;
end