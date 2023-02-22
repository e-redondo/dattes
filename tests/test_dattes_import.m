% Modify srcdir to a folder containing cycler files
srcdir = 'raw_data';
% Modify dstdir to destination folder to put xml files
dstdir = 'xml_data';
%Uncomment concerned lines depending on cycler:
% modify options if necessary:
% 'v': verbose
% 'f': force
% 'm': merge files (applies only to arbin_csv and biologic)
dattes_import(srcdir,'arbin_csv','vmf',dstdir)
dattes_import(srcdir,'arbin_res','vf',dstdir);
dattes_import(srcdir,'arbin_xls','vf',dstdir);
dattes_import(srcdir,'biologic','vmf',dstdir);
dattes_import(srcdir,'bitrode','vf',dstdir);
dattes_import(srcdir,'digatron','vf',dstdir);
dattes_import(srcdir,'neware','vf',dstdir);
