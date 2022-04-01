function Date = read_bitrode_log(srcdir,CSVfile)
%read_bitrode_log fonction provisoire pour avoir 'tabs' dans les fichiers
%Bitrode. Lorsque la lecture Bitrode se fera avec les fichiers mdb cette
%fonction deviendra inutile
%
%read_bitrode_log(srcdir) fait une liste des fichiers CSV, avec leur
%date de modification (date d'export dans l'oridnateur Bitrode)
%
%L'utilisateur devra venir modifier ces dates avec la VRAIE DATE du test.
%
% See also write_bitrode_log, btr2xml

fid = fopen(fullfile(srcdir,'bitrode.log'),'r');
if fid<0
    Date = [];
    fprintf('read_bitrode_log: bitrode.log not found\n');
    return;
end
lignes = cell(0);
while ~feof(fid)
lignes{end+1} = fgetl(fid);
end
lignes = lignes';
CSV = strtrim(regexp(lignes,'.*\t','match','once'));
Dates = strtrim(regexp(lignes,'\t.*$','match','once'));

%windows compatibility issue: always write with / separator
CSV = regexprep(CSV,'/|\','/');
[~,~,Is] = regexpFiltre(CSV,CSVfile);
Date = Dates(Is);
end