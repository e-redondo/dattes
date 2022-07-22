function err = export_result(filename,result,options)
% export_result Export DATTES result to JSON, XML, HDF, etc.
%
% Usage: err = export_result(filename,result,options)
%
% Inputs:
% - filename [string]: valid filename
% - result [1x1 struct]: DATTES struct
% - options [string]: with execution options
%     - 'j': JSON
%     - 'x': XML
%     - 'h': HDF
%
% See also dattes, export_config
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.


if ~exist('options','var')
    options = '';
end

verbose = ismember('v',options);
% output format:
out_fmt = '';

if ismember('j',options)
    out_fmt = 'json';
elseif ismember('x',options)
    out_fmt = 'xml';
elseif ismember('h',options)
    out_fmt = 'hdf';
elseif ismember('c',options)
    out_fmt = 'csv';
else
    %deduct out_fmt from extension:
    if verbose
        fprintf('export_result: output format not given in options, deduct from file extension\n');
    end
    [~,~,E] = fileparts(filename);
    if isequal(E,'.json')
    out_fmt = 'json';
    elseif isequal(E,'.xml')
    out_fmt = 'xml';
    elseif isequal(E,'.hdf5') || isequal(E,'.h5') || isequal(E,'.hdf')
    out_fmt = 'hdf';
    elseif isequal(E,'.csv')
    out_fmt = 'csv';
    end
end

if isempty(out_fmt)
    err=-1;
    fprintf('export_result: please specify output format\n');
end

switch out_fmt
    case 'json'
        err = export_result_json(filename,result);
    case 'xml'
        err = export_result_xml(filename,result);
    case 'hdf'
        err = export_result_hdf(filename,result);
    case 'csv'
        err = export_result_csv(filename,result);
        
end
end

function err = export_result_json(filename,result)

%convert function hanldles into strings
result = func2str_struct(result);

jsontxt = jsonencode(result,'PrettyPrint',true);

fid = fopen(filename,'w+');
if fid<0
   fprintf('export_result: invalid filename of insufficient permissions\n');
   err = -2;
   return
end
fprintf(fid,'%s',jsontxt);
fclose(fid);

err = 0;
end

function err = export_result_xml(filename,result)

fprintf('export_result: XML support coming soon\n')
err = 0;

end

function err = export_result_csv(filename,result)
%export metadata and profiles to csv
%
fid = fopen(filename,'w+');
if fid<0
   fprintf('export_result: invalid filename of insufficient permissions\n');
   err = -2;
   return
end

%1. write metadata jsontxt as commented text before
jsontxt = jsonencode(result.metadata,'PrettyPrint',true);
jsonlines = regexp(jsontxt,'\n','split');
jsonlines{1} = sprintf('"metadata" = %s',jsonlines{1});
for ind = 1:length(jsonlines)
    fprintf(fid,'#%s\n',jsonlines{ind});
end
fclose(fid);

params.append = true;
[err] = profiles2csv(filename,result.profiles,[],params);

end

function err = export_result_hdf(filename,result)

A = ver;

if strcmpi(A(1).Name,'octave')
  save(filename,'-hdf5','result');
else
  fprintf('export_result: HDF not supported in MATLAB, consider changing to Octave\n')
end

err = 0;

end


function struct_out = func2str_struct(struct_in)
%convert function handles to strings
fieldlist = fieldnames(struct_in);

for ind = 1:length(struct_in)
    for ind_f = 1:length(fieldlist)
        field = struct_in(ind).(fieldlist{ind_f});
        if isstruct(field)
            field = func2str_struct(field);
        elseif isa(field,'function_handle')
            field = func2str(field);
        end
        struct_out(ind).(fieldlist{ind_f}) = field;
    end
end
end