function t = datenum_guess(date_str,date_fmt)


if exist('date_fmt','var')
    t = datenum_safe(date_str,date_fmt);
end

ind = 1;
date_formats{ind} = "dd-mm-yyyy HH:MM:SS";ind = ind+1;
date_formats{ind} = "dd-mm-yyyy HH:MM:SS.FFF";ind = ind+1;
date_formats{ind} = "mm-dd-yyyy HH:MM:SS";ind = ind+1;
date_formats{ind} = "mm-dd-yyyy HH:MM:SS.FFF";ind = ind+1;
date_formats{ind} = "dd/mm/yyyy HH:MM:SS";ind = ind+1;
date_formats{ind} = "dd/mm/yyyy HH:MM:SS.FFF";ind = ind+1;
date_formats{ind} = "mm/dd/yyyy HH:MM:SS";ind = ind+1;
date_formats{ind} = "mm/dd/yyyy HH:MM:SS.FFF";ind = ind+1;
    

for ind = 1:length(date_formats)
    t = datenum_safe(date_str,date_formats{ind});
    if ~isequal(t,date_str)
        return
    end
end
end

function t = datenum_safe(date_str,date_fmt)

try
    t = datenum(date_str,date_fmt);
catch
    t = date_str;
end

end