function err = export_config(filename, config)
% export_config write a MATLAB script with basic info in config
%
% Usage: err = export_config(filename, config)
%
% Inputs:
% - filename [string]: pathname of MATLAB script to write
% - config [1x1 struct]: configuration structure as in result.config
%
% Output:
% - err [1x1 double]: error code (0 = success)
%
% See also dattes, configurator, cfg_default
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

err = 0;

%mandatory fields:
% config.test.max_voltage
% config.test.min_voltage
% config.test.capacity
if ~isfield(config,'test')
    err_msg = sprintf(['export_config: missing minimal info in config\n'...
               'missing config.test.max_voltage, '...
               'config.test.min_voltage, config.test.capacity']);
elseif ~isfield(config.test,'max_voltage')
    err_msg = sprintf(['export_config: missing minimal info in config\n'...
               'missing config.test.max_voltage']);
elseif ~isfield(config.test,'min_voltage')
    err_msg = sprintf(['export_config: missing minimal info in config\n'...
               'missing config.test.min_voltage']);   
elseif ~isfield(config.test,'capacity')
    err_msg = sprintf(['export_config: missing minimal info in config\n'...
               'missing config.test.capacity']); 
else
    err_msg = '';
end

if ~isempty(err_msg)
    error(err_msg);
end

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
fprintf(fid,'%%Autogenerated script with export_config\n\n');

%mandatory fields before cfg_default
fprintf(fid,'\n%%values for this cell\n');
print_scalar(fid,'config.test.max_voltage', config.test.max_voltage);
print_scalar(fid,'config.test.min_voltage', config.test.min_voltage);
print_scalar(fid,'config.test.capacity', config.test.capacity);

%run cfg_default
fprintf(fid,'\n%%default values:\n');
fprintf(fid,'config = cfg_default(config);\n');

%overwrite defaults with values in config:

% all fieldnames in config.test except cfg_file
fprintf(fid,'\n\n');
fprintf(fid,'%%test\n');

fieldlist = fieldnames(config.test);
[~, fieldlist] = regexpFiltre(fieldlist,'cfg_file');
[~, fieldlist] = regexpFiltre(fieldlist,'max_voltage');%already done above
[~, fieldlist] = regexpFiltre(fieldlist,'min_voltage');%already done above
[~, fieldlist] = regexpFiltre(fieldlist,'capacity');%already done above

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
    elseif isa(value,'function_handle')
        print_func(fid,name,value);
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
    elseif isa(value,'function_handle')
        print_func(fid,name,value);
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
    elseif isa(value,'function_handle')
        print_func(fid,name,value);
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
    elseif isa(value,'function_handle')
        print_func(fid,name,value);
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
    elseif isa(value,'function_handle')
        print_func(fid,name,value);
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
            print_scalar(fid,name, value);
        elseif isvector(value)
            print_vector(fid,name,value);
        end
    elseif isa(value,'function_handle')
        print_func(fid,name,value);
    end
end

%end of function
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

function print_func(fid,name,value)
fprintf(fid,"%s = @%s;\n",name,func2str(value));
end