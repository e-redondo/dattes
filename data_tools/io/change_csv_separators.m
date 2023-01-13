function change_csv_separators(file_in,from,to,file_out)
% change_csv_separators change regional format of csv file (decimal and
% column separators)
% 
% Usage 
% change_csv_separators(file_in,from,to,file_out)
% Inputs:
% - file_in (string): input pathname
% - from (string): input format
%    - 'fr': decimal sep = ",", column sep = ";"
%    - 'en': decimal sep = ".", column sep = ","
% - to (string): output format
%    - 'fr': decimal sep = ",", column sep = ";"
%    - 'en': decimal sep = ".", column sep = ","
% - file_out (string): output pathname
%                      (if not given 'file_in_fromto.extension')
%
% Example(1): change from French format (comma decimal separator, colon
% column separator to English format (dot and comma separators)
%  change_csv_separators('french.csv', 'fr', 'en', 'english.csv')
% Example(2): change from English format French format
%  change_csv_separators('english.csv','en','fr','french.csv')
% Example(3): change from English format French format (no given file_out)
%  change_csv_separators('measurements.csv','en','fr','measurements_enfr.csv')
%
% 
% See also regexrep_in_file
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.


fromto = [from, to];

if ~exist('file_out','var')
    [D,file_out,E]  = fileparts(file_in);

    file_out = fullfile(D,sprintf('%s_%s%s',file_out,fromto,E));
end

switch fromto
    case 'fren'
        %French to English
        replace_in_file(file_in,{'(,)(?=[0-9])',';'},{'.',','},file_out);
    case 'enfr'
        %English to French
        replace_in_file(file_in,{',','(\.)(?=[0-9])'},{';',','},file_out);
    otherwise
        fprintf('change_csv_separators: Bad from/to paramaters. Currently available parameters are "fr" and "en"\n');
        return
end