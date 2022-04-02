function fileOut = result_filename(XMLfile)
%separate folder (D), file (F) and extension (E)
[D F E] = fileparts(XMLfile);
%print suffix: filename_result.mat
fileOut = sprintf('%s_result.mat',F);
%build the full pathname (folder + filename)
fileOut = fullfile(D, fileOut);
end