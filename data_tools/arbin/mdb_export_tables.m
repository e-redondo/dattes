function mdb_export_tables(res_file)
%mdb_export_tables Convert .res file into .csv table
%
% mdb_export_tables(res_file)
% Read the Arbin *.res file and converts it into .csv table
%
% Usage:
% mdb_export_tables(res_file)
% Inputs : 
% - res_file: .res file from Arbin cycler
%
%   See also importArbinTxt, importArbinXls,  arbin_res2xml, import_arbin_res if iscell(res_file)
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

if ~exist(res_file,'file')
    fprintf('mdb_export_tables: File not found: %s\n',res_file);
    return;
end

cellfun(@mdb_export_tables,res_file);
  return;
end
if isdir(res_file)
    res = lsFiles(res_file,'.res');
    mdb_export_tables(res);
    return;
end

[A, B] = dos(sprintf('mdb-tables "%s"',res_file));
table_list = B;
table_list = regexp(table_list,'\s','split');
Ie = cellfun(@isempty,table_list);
table_list = table_list(~Ie);

[D, F, E] = fileparts(res_file);
dirOut = fullfile(D,F);
mkdir(dirOut);
for ind = 1:length(table_list)
    file_out = fullfile(dirOut,sprintf('%s.csv',table_list{ind}));
    cmd = sprintf('mdb-export -d " " "%s" %s > "%s"',res_file,table_list{ind},file_out);
    [A, B] = dos(cmd);
end
end

