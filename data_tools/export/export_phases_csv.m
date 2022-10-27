function export_phases_csv(dattes_struct,phase_start,phase_end,options,file_out)

% export_phases_csv export phases from DATTES struct to csv file
%
% 
% Usage:
% export_phases_csv(dattes_struct, options, file_out)
%
% Input:
% - dattes_struct [1x1 struct] DATTES result structure
% - phase_start[double] Number of the first phase to export
% - phase_end[double] Number of the last phase to export
% - options [1xp string]: (optional)
%   - 'm': include metadata in header in json format commented lines (starting with '#')
% - file_out [1xp string]: (optional) 
%
%
% See also dattes_export, export_eis_csv
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

%0. check inputs
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
if ~isfield(dattes_struct.profiles,'t') |~isfield(dattes_struct.profiles,'U') |...
        ~isfield(dattes_struct.profiles,'I') |~isfield(dattes_struct.profiles,'m') |...
        ~isfield(dattes_struct.profiles,'soc') |  ~isfield(dattes_struct.profiles,'dod_ah')
         fprintf('ERROR export_phases_csv: dattes structure is incomplete please redo [result]=dattes(XML_file,cSpvs,cfg_file)\n');
end

%check options
if ~exist('options','var')
    options = '';%default: no metadata
end
%check phases number
if ~isnumeric(phase_start) | ~isnumeric(phase_end)
     fprintf('ERROR export_phases_csv: Phases number should be numeric\n');
end

%check file out extension
file_extension=regexprep(file_out,'\.[a-zA-Z0-9]+','match');

if ~strcmp(file_extension,'.csv')
    file_suffix = '_dattes.csv';
    file_out = regexprep(file_out,'.[a-zA-Z0-9]*$',file_suffix);
end




%1. export phases

[profiles.t,profiles.U,profiles.I,profiles.SoC,profiles.DoDAh,profiles.m]=extract_phase2(dattes_struct.phases([phase_start phase_end]),[0 10],dattes_struct.profiles.t,dattes_struct.profiles.U,dattes_struct.profiles.I,dattes_struct.profiles.soc,dattes_struct.profiles.dod_ah,dattes_struct.profiles.m);

dattes_struct.profiles=profiles;

export_profiles_csv(dattes_struct,options,file_out);

end