function export_selected_phases_csv(dattes_struct,options,dst_folder,phase_start,phase_end,file_out)
% export_selected_phases_csv export selected phases from DATTES struct to csv file
%
% This function performs as extract_profiles_csv, but the user can export
% just between two phases providing the starting and the ending phase.
% 
% Usage:
% export_selected_phases_csv(dattes_struct,options,dst_folder,phase_start,phase_end,file_out)
%
% Input:
% - dattes_struct [1x1 struct] DATTES result structure
% - options [1xp string]: (optional)
%   - 'm': include metadata in header in json format commented lines (starting with '#')
% - dst_folder [1xp string]: (optional) 
% - phase_start[double] (optional) Number of the first phase to export
% - phase_end[double] (optional) Number of the last phase to export
% (default = export all phases)
% - file_out [1xp string]: (optional) 
%
%
% See also dattes_export, export_profiles_csv, export_eis_csv
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

%0. check inputs
if ~exist('file_out','var')
    file_out = '';%empty string = default = generate file_out
end
if ~exist('dst_folder','var')
    dst_folder = '';%empty string = default = keep src_folder
end
%check dattes_struct
if ~isfield(dattes_struct,'profiles')
     fprintf('ERROR export_profiles_csv:No profiles found in DATTES struct\n');
     return
end
%check dattes_struct
if ~isfield(dattes_struct,'phases')
     fprintf('ERROR export_profiles_csv:No phases found in DATTES struct\n');
     return
end

% check if t,U,I,m,soc and dod fields exist in dattes_struct
if ~isfield(dattes_struct.profiles,'t') || ~isfield(dattes_struct.profiles,'U') ||...
        ~isfield(dattes_struct.profiles,'I') || ~isfield(dattes_struct.profiles,'m') ||...
        ~isfield(dattes_struct.profiles,'soc') ||  ~isfield(dattes_struct.profiles,'dod_ah')
         fprintf('ERROR export_phases_csv: dattes structure is incomplete please redo [result]=dattes(XML_file,cSpvs,cfg_file)\n');
end

%check options
if ~exist('options','var')
    options = '';%default: no metadata
end
if ~exist('phase_start','var')
    phase_start = 1;
end
if ~exist('phase_end','var')
    phase_end = length(dattes_struct.phases);
end


%check phases number
if ~isnumeric(phase_start) || ~isnumeric(phase_end)
     fprintf('ERROR export_phases_csv: Phases number should be numeric\n');
end

%check fileout name
if isempty(file_out)
    file_suffix = 'phases';
    file_ext = '.csv';
    file_out = result_filename(dattes_struct.test.file_out, dst_folder,file_suffix, file_ext);
end


%1. export phases
datetime = dattes_struct.profiles.datetime;
t = dattes_struct.profiles.t;
U = dattes_struct.profiles.U;
I = dattes_struct.profiles.I;
soc = dattes_struct.profiles.soc;
dod_ah = dattes_struct.profiles.dod_ah;
m = dattes_struct.profiles.mode;

[datetime2,t2,U2,I2,soc2,dod_ah2,m2] = ...
    extract_phase2(dattes_struct.phases([phase_start phase_end]),[0 0],datetime, t, U, I, soc, dod_ah, m);


dattes_struct.profiles.datetime = datetime2;
dattes_struct.profiles.t = t2;
dattes_struct.profiles.U = U2;
dattes_struct.profiles.I = I2;
dattes_struct.profiles.soc = soc2;
dattes_struct.profiles.dod_ah = dod_ah2;
dattes_struct.profiles.mode = m2;


export_profiles_csv(dattes_struct, options, dst_folder, file_out);

end