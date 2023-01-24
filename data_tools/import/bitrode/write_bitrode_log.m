function write_bitrode_log(srcdir,options)
%write_bitrode_log fonction provisoire pour avoir 'tabs' dans les fichiers
%Bitrode. Lorsque la lecture Bitrode se fera avec les ficheirs mdb cette
%fonction deviendra inutile
%
%write_bitrode_log(srcdir) fait une liste des fichiers CSV, avec leur
%date de modification (date d'export dans l'oridnateur Bitrode)
%
%L'utilisateur devra venir modifier ces dates avec la VRAIE DATE du test.
%
% See also read_bitrode_log, bitrode_csv2xml
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.



if ~exist('options','var')
    options = 'n';
end

csv_list = lsFiles(srcdir,'.csv');
D = cellfun(@dir,csv_list);

if ismember('m',options)
    Dates = cellfun(@(x) datestr(x,'yyyy/mm/dd HH:MM:SS'),{D.datenum},'uniformoutput',false);
    Dates = Dates';
end
if ismember('n',options)
    Dates = regexp(csv_list,'[0-9]{8}_[0-9]{4}','match','once');
    Ie = cellfun(@isempty,Dates);
    % apply just when Dates found in csv_list (not empty)
    Dates = cellfun(@(x) datestr(datenum(x,'yyyymmdd_HHMM'),'yyyy/mm/dd HH:MM'),Dates(~Ie),'uniformoutput',false);
    csv_list = csv_list(~Ie);
end
[Dates, Is] = sort(Dates);
csv_list = csv_list(Is);
%windows compatibility issue: always write with / separator
csv_list = regexprep(csv_list,'/|\\','/');
fid = fopen(fullfile(srcdir,'bitrode.log'),'w+');
for ind = 1:length(csv_list)
    fprintf(fid,'%s\t%s\n',csv_list{ind},Dates{ind});
end
fclose(fid);

end
