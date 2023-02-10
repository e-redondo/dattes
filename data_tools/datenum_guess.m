function [t,date_fmt] = datenum_guess(date_str,date_fmt)


if exist('date_fmt','var')
    t = datenum_safe(date_str,date_fmt);
    return
else
    %first let matlab/octave guess format
    t = datenum_safe(date_str);
    if ~isequal(t,date_str)
        %if not equal, found, then exit function
        return
    end
end

%date format not found, try all formats
ind = 1;

if ischar(date_str)
    date_str = {date_str};
end


if all(~cellfun(@isempty,regexp(date_str,'^[0-9]{4,4}','once')))
    %dashes years first
    date_formats{ind} = "yyyy-mm-dd HH:MM:SS.FFF AM";ind = ind+1;
    date_formats{ind} = "yyyy-mm-dd HH:MM:SS.FFF";ind = ind+1;
    date_formats{ind} = "yyyy-mm-dd HH:MM:SS AM";ind = ind+1;
    date_formats{ind} = "yyyy-mm-dd HH:MM:SS";ind = ind+1;
    date_formats{ind} = "yyyy-mm-dd";ind = ind+1;

    %slashes years first
    date_formats{ind} = "yyyy/mm/dd HH:MM:SS.FFF AM";ind = ind+1;
    date_formats{ind} = "yyyy/mm/dd HH:MM:SS.FFF";ind = ind+1;
    date_formats{ind} = "yyyy/mm/dd HH:MM:SS AM";ind = ind+1;
    date_formats{ind} = "yyyy/mm/dd HH:MM:SS";ind = ind+1;
    date_formats{ind} = "yyyy/mm/dd";ind = ind+1;


else
    %dashes, months first
    date_formats{ind} = "mm-dd-yyyy HH:MM:SS.FFF AM";ind = ind+1;
    date_formats{ind} = "mm-dd-yyyy HH:MM:SS.FFF";ind = ind+1;
    date_formats{ind} = "mm-dd-yyyy HH:MM:SS AM";ind = ind+1;
    date_formats{ind} = "mm-dd-yyyy HH:MM:SS";ind = ind+1;
    date_formats{ind} = "mm-dd-yyyy";ind = ind+1;
    %dashes, days first
    date_formats{ind} = "dd-mm-yyyy HH:MM:SS.FFF AM";ind = ind+1;
    date_formats{ind} = "dd-mm-yyyy HH:MM:SS.FFF";ind = ind+1;
    date_formats{ind} = "dd-mm-yyyy HH:MM:SS AM";ind = ind+1;
    date_formats{ind} = "dd-mm-yyyy HH:MM:SS";ind = ind+1;
    date_formats{ind} = "dd-mm-yyyy";ind = ind+1;

    %slashes, months first
    date_formats{ind} = "mm/dd/yyyy HH:MM:SS.FFF AM";ind = ind+1;
    date_formats{ind} = "mm/dd/yyyy HH:MM:SS.FFF";ind = ind+1;
    date_formats{ind} = "mm/dd/yyyy HH:MM:SS AM";ind = ind+1;
    date_formats{ind} = "mm/dd/yyyy HH:MM:SS";ind = ind+1;
    date_formats{ind} = "mm/dd/yyyy";ind = ind+1;
    %slashes, days first
    date_formats{ind} = "dd/mm/yyyy HH:MM:SS.FFF AM";ind = ind+1;
    date_formats{ind} = "dd/mm/yyyy HH:MM:SS.FFF";ind = ind+1;
    date_formats{ind} = "dd/mm/yyyy HH:MM:SS AM";ind = ind+1;
    date_formats{ind} = "dd/mm/yyyy HH:MM:SS";ind = ind+1;
    date_formats{ind} = "dd/mm/yyyy";ind = ind+1;

end
for ind = 1:length(date_formats)
    date_fmt = date_formats{ind};
    t = datenum_safe(date_str,date_fmt);
    if ~isequal(t,date_str)
        return
    end
end
end

function t = datenum_safe(date_str,date_fmt)

try
    if exist('date_fmt','var')
        t = datenum(date_str,date_fmt);
    else
        t = datenum(date_str);
    end
catch
    t = date_str;
end

end
