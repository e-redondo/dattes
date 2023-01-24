function [profiles, eis, metadata, config, err] = extract_profiles_csv(csv_file,options)
%extract_profiles extract important variables from a battery test bench file.
% Also read metadata in '.meta' files
%
%[profiles, eis, metadata, config, err] = extract_profiles_csv(csv_file,options)
% 1.- Read a .csv file (dattes_export)
% 2.- Extract important vectors: t,U,I,m,DoDAh,SOC,T
% 3.- Save the important vectors in a dattes' results file (if 's' in
% options)
%
% Usage:
%[profiles, eis, metadata, config, err] = extract_profiles_csv(csv_file,options)
% Inputs : 
% - csv_file:
%     -   [1xn string]: pathame to the csv file
%     -   [nx1 cell string]: csv filelist
% - options:  [1xn string] string containing execution options:
%     -   'v' :  'verbose', tell what you do
%
% Outputs : 
% - profiles [1x1 struct] with fields:
%     - datetime [mx1 double]: time in seconds from 1/1/2000 00:00
%     - t [mx1 double]: test time in seconds (0 to test duration)
%     - U [mx1 double]: cell voltage in V
%     - I [mx1 double]: cell current in A
%     - m [mx1 double]: mode
%     - dod_ah [mx1 double]: depth of discharge in AmpHours
%     - soc [mx1 double]: state of charge in %
%     - T [mx1 double] Temperature in °C (empty if no probe)
% - eis [1x1 struct] with fields: (empty if no EIS found in test)
%     - t [nx1 cell of [px1 double]]: time in seconds from 1/1/2000 00:00
%     - U [nx1 cell of [px1 double]]: cell voltage in V
%     - I [nx1 cell of [px1 double]]: cell current in A
%     - m [nx1 cell of [px1 double]]: mode
%     - ReZ [nx1 cell of [px1 double]]: real part of impedance (Ohm)
%     - ImZ [nx1 cell of [px1 double]]: imaginary part of impedance (Ohm)
%     - f [nx1 cell of [px1 double]]: frequency (Hz)
% - metadata: [1x1 struct] with metadata from metadata_collector
% - config:  [1x1 struct] generated config from metadata
% -  err [1x1 double] error codes
%   - err = 0: OK
%   - err = -1: csv_file file does not exist
%   - err = -2: not valid csv file
%
%
% See also dattes_import, metadata_collector
%
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

if ~exist('options','var')
    options = '';
end

%TODO: error management
err = 0;
profiles = struct([]);
eis = struct([]);
metadata = struct([]);
config = struct([]);

% Some values initialization:
max_voltage = [];
min_voltage = [];
capacity = [];



if ismember('v',options)
    fprintf('extract_profiles_csv: %s ....\n',csv_file);
end

if ~exist(csv_file,'file')
    err = -1;
    fprintf('File not found: %s\n',csv_file);
    return;
end

% Read csv file
[profiles, metadata, err_csv] = read_csv_struct(csv_file);
check_profiles_struct(profiles);
[info, err_p] = check_profiles_struct(profiles);
if err_p
    err = -2;
    fprintf('Not valid csv file (%s), check_profiles_struct err code: %d\n',csv_file,err_p);
    return;
end

if isempty(metadata)
    % Read metadata files (if they exist)
    [metadata, meta_list,err_metadata] = metadata_collector(csv_file);
end

% Get values from metadata:
if isfield(metadata,'cell')
    % U_min, U_max, capacity for calcul_soc
    if isfield(metadata.cell,'max_voltage')
        max_voltage = metadata.cell.max_voltage;
    end
    if isfield(metadata.cell,'min_voltage')
        min_voltage = metadata.cell.min_voltage;
    end
    if isfield(metadata.cell,'nom_capacity')
        capacity = metadata.cell.nom_capacity;
    end
end

if ~isfield(profiles,'T')
if isfield(metadata,'test')
    if isfield(metadata.test,'temperature')
        %TODO metadata struct and data types validation (new function)
        T = metadata.test.temperature*ones(size(profiles.t));
    end
end  
end

%read EIS
eis_csv_file = result_filename(csv_file,'','eis','.csv');
if exist(eis_csv_file,'file')
    [eis, ~, err_eis] = read_csv_struct(eis_csv_file);
    eis = cut_eis_into_cell(eis);
end

%AUTO generate config
if isempty(max_voltage)%not found in metadata:
    max_voltage = max(profiles.U);
end
if isempty(min_voltage)%not found in metadata:
    min_voltage = min(profiles.U);
end
if isempty(capacity)%not found in metadata:
    amp_hours = calcul_amphour(profiles.t,profiles.I);
    capacity = max(amp_hours)-min(amp_hours);
end

% create config struct with minimal info (U_max, U_min, capacity):
config(1).test.max_voltage = max_voltage;
config.test.min_voltage = min_voltage;
config.test.capacity = capacity;
%Load defaults:
config = cfg_default(config);

%traceability:
config.test.cfg_file = 'autogenerated from extract_profiles_csv';

err=0;

if ismember('v',options)
    fprintf('extract_profiles_csv: %s ....OK\n',csv_file);
end
end

function eis_out = cut_eis_into_cell(eis_in)

f = eis_in.f;

% frequency sweep can be positive (low to high frequencies) >> Iend1
% or negative (low to high frequencies) Iend2
% Keep shortest vector (most probable situation)
Iend1 = [diff(f)>0; true];
Iend2 = [diff(f)<0; true];
if length(find(Iend1))< length(find(Iend2))
    Iend = Iend1;
else
    Iend = Iend2;
end

% Iend = [diff(f)>0; true];
Istart = [true; Iend(1:end-1)];

% Iend = [diff(f)>0; true];
% Istart = [true; Iend(1:end-1)];
Iend = find(Iend);
Istart = find(Istart);

fieldlist = fieldnames(eis_in);
for ind_f = 1:length(fieldlist)
    this_field_in =  eis_in.(fieldlist{ind_f});
    this_field_out = cell(size(Istart));
    for ind = 1:length(Istart)
        this_field_out{ind} = this_field_in(Istart(ind):Iend(ind));
    end
    eis_out.(fieldlist{ind_f}) = this_field_out;
end

end