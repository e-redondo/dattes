function err = export_config(filename, config)
% export_config write a MATLAB script with basic info in config

err = 0;

[D,F,E] = fileparts(filename);

%file extension must be '.m' (MATLAB code)
if ~isequal(E,'.m')
    fprintf('export_config: filename extension must be ".m"\n');
    return
end
%F must be a valid function name
if ~isvarname(F)
    fprintf('export_config: filename must be a valid variable name (see help isvarname)\n');
    return
end
fid = fopen(filename,'w+');

%TODO: ignore fields with same values than cfg_default

fprintf(fid,'function config = %s\n',F);

% all fieldnames in config.test except cfg_file
fprintf(fid,'\n\n');
fprintf(fid,'%%test\n');

fieldlist = fieldnames(config.test);
[~, fieldlist] = regexpFiltre(fieldlist,'cfg_file');

for ind = 1:length(fieldlist)
    name = sprintf('config.test.%s',fieldlist{ind});
    value = config.test.(fieldlist{ind});
    if ischar(value)
        print_string(fid,name,value);
    elseif isnumeric(value)
        if isscalar(value)
            print_scalar(fid,name, value)
        elseif isvector(value)
            print_vector(fid,name,value)
        end
        
    end
end

% all fieldnames in config.resistance except pR and instant_end_rest
fprintf(fid,'\n\n');
fprintf(fid,'%%resistance\n');

fieldlist = fieldnames(config.resistance);
[~, fieldlist] = regexpFiltre(fieldlist,'pR');
[~, fieldlist] = regexpFiltre(fieldlist,'instant_end_rest');

for ind = 1:length(fieldlist)
    name = sprintf('config.resistance.%s',fieldlist{ind});
    value = config.resistance.(fieldlist{ind});
    if ischar(value)
        print_string(fid,name,value);
    elseif isnumeric(value)
        if isscalar(value)
            print_scalar(fid,name, value)
        elseif isvector(value)
            print_vector(fid,name,value)
        end
        
    end
end
% all fieldnames in config.impedance except pZ and instant_end_rest
fprintf(fid,'\n\n');
fprintf(fid,'%%impedance\n');

fieldlist = fieldnames(config.impedance);
[~, fieldlist] = regexpFiltre(fieldlist,'pZ');
[~, fieldlist] = regexpFiltre(fieldlist,'instant_end_rest');

for ind = 1:length(fieldlist)
    name = sprintf('config.impedance.%s',fieldlist{ind});
    value = config.impedance.(fieldlist{ind});
    if ischar(value)
        print_string(fid,name,value);
    elseif isnumeric(value)
        if isscalar(value)
            print_scalar(fid,name, value)
        elseif isvector(value)
            print_vector(fid,name,value)
        end
        
    end
end
% all fieldnames in config.ocv_points except pOCVr
fprintf(fid,'\n\n');
fprintf(fid,'%%ocv_points\n');

fieldlist = fieldnames(config.ocv_points);
[~, fieldlist] = regexpFiltre(fieldlist,'pOCVr');

for ind = 1:length(fieldlist)
    name = sprintf('config.ocv_points.%s',fieldlist{ind});
    value = config.ocv_points.(fieldlist{ind});
    if ischar(value)
        print_string(fid,name,value);
    elseif isnumeric(value)
        if isscalar(value)
            print_scalar(fid,name, value)
        elseif isvector(value)
            print_vector(fid,name,value)
        end
        
    end
end
% all fieldnames in config.pseudo_ocv except pOCVpC and pOCVpD
fprintf(fid,'\n\n');
fprintf(fid,'%%pseudo_ocv\n');

fieldlist = fieldnames(config.pseudo_ocv);
[~, fieldlist] = regexpFiltre(fieldlist,'pOCVpC');
[~, fieldlist] = regexpFiltre(fieldlist,'pOCVpD');

for ind = 1:length(fieldlist)
    name = sprintf('config.pseudo_ocv.%s',fieldlist{ind});
    value = config.pseudo_ocv.(fieldlist{ind});
    if ischar(value)
        print_string(fid,name,value);
    elseif isnumeric(value)
        if isscalar(value)
            print_scalar(fid,name, value)
        elseif isvector(value)
            print_vector(fid,name,value)
        end
        
    end
end
% all fieldnames in config.ica except pICA
fprintf(fid,'\n\n');
fprintf(fid,'%%ica\n');

fieldlist = fieldnames(config.ica);
[~, fieldlist] = regexpFiltre(fieldlist,'pOCVpC');
[~, fieldlist] = regexpFiltre(fieldlist,'pOCVpD');

for ind = 1:length(fieldlist)
    name = sprintf('config.ica.%s',fieldlist{ind});
    value = config.ica.(fieldlist{ind});
    if ischar(value)
        print_string(fid,name,value);
    elseif isnumeric(value)
        if isscalar(value)
            print_scalar(fid,name, value)
        elseif isvector(value)
            print_vector(fid,name,value)
        end
        
    end
end

%end of funciton
fprintf(fid,'end\n');
fclose(fid);
end

function print_string(fid,name,value)
fprintf(fid,"%s = '%s';\n",name,value);
end

function print_scalar(fid,name, value)
fprintf(fid,"%s = %g;\n",name,value);
end

function print_vector(fid,name,value)
fprintf(fid,"%s = [",name);
for ind = 1 :length(value)-1
fprintf(fid,"%g, ",value(ind));
end
fprintf(fid,"%g];\n",value(end));
end
