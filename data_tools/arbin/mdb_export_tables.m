function mdb_export_tables(resFile)

if iscell(resFile)
    cellfun(@mdb_export_tables,resFile);
    return;
end
if isdir(resFile)
    RES = lsFiles(resFile,'.res');
    mdb_export_tables(RES);
    return;
end
if ~exist(resFile,'file')
    fprintf('File not found: %s\n',resFile);
    return;
end
[A, B] = dos(sprintf('mdb-tables "%s"',resFile));
tablelist = B;
tablelist = regexp(tablelist,'\s','split');
Ie = cellfun(@isempty,tablelist);
tablelist = tablelist(~Ie);

[D, F, E] = fileparts(resFile);
dirOut = fullfile(D,F);
mkdir(dirOut);
for ind = 1:length(tablelist)
    fileOut = fullfile(dirOut,sprintf('%s.csv',tablelist{ind}));
    cmd = sprintf('mdb-export -d " " "%s" %s > "%s"',resFile,tablelist{ind},fileOut);
    [A, B] = dos(cmd);
end
%TODO: gestion d'erreurs
end

