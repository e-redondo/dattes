function xml = import_landt_xls(file_in, options)

xml = [];
% check inputs
if ~exist('file_in','var')
    fprintf('import_landt_xls:error, not enough inputs\n');
    return
end
if ~exist(file_in,'file')
    fprintf('import_landt_xls:error, file_in not found: %s\n',file_in);
    return
end

%
[ori_dir,F,E] = fileparts(file_in);
% if not dst_dir; dst_dir = ori_dir
% if ~exist('dst_dir','var')
%     dst_dir = ori_dir;
% end
% 
% if ~exist(dst_dir,'dir')
%     [s,w] = mkdir(dst_dir);
%     if ~s
%         fprintf('import_landt_xls:error, unable to create dst_dir: %s\n',dst_dir);
%         return
%     end
% end

%convert to csv
[csv_folder, err] = xls2csv(file_in);

csv_list = lsFiles(csv_folder,'.csv');

[test_info_file, otherfiles] = regexpFiltre(csv_list,'Test information.csv$');

if length(test_info_file)~=1
    % if not Test information.csv; not a landt file exit
    fprintf('import_landt_xls:error, Test information sheet not found in %s\n', file_in);
    fprintf('Check csv folder %s\n', csv_folder);
    return
end

%TODO read and digest Test information.csv to obtain metadata
% sourcefile (ccs file)
% test start datetime and end datetime


if length(otherfiles)~=1
    % normally only one data file, if not exit
    fprintf('import_landt_xls:error, no data sheet or more than one found in %s\n', file_in);
    fprintf('Check csv folder %s\n', csv_folder);
    return
end



% patch other csv file:
temp_file = fullfile(ori_dir,sprintf('%s.csv',F));
patch_landt_csv_file(otherfiles{1},temp_file);

% now we can delete csv_folder and its content
cellfun(@delete,csv_list);
rmdir(csv_folder);


%custom csv2profiles for landt cyclers:
% try
    [profiles, other_cols] = csv2profiles(temp_file);
% catch
%     fprintf('import_landt_xls:error, check temp file %s\n', temp_file);
%     return
% end
delete(temp_file);

%build xml struct
xml = profiles2xml(profiles,other_cols,[F E]);

%write xml file
% xml_file = fullfile(dst_dir,sprintf('%s.xml',F));
% ecritureXMLFile4Vehlib(xml,xml_file);

end


function patch_landt_csv_file(file_in,file_out)
%reading all file, cutting lines (cell string) and writing back to file_out

% fid_in / fid_out
fid_in = fopen(file_in,'r');
lines = cell(0);
while ~feof (fid_in)
lines{end+1} = fgetl(fid_in);
end
fclose(fid_in);

%remove not interesting lines:
[~,~,step_header_lines] = regexpFiltre(lines,'^Step');% step statistics line
[~,~,cycle_header_lines] = regexpFiltre(lines,'^Cycle,CapC');
[~,~,record_header_lines] = regexpFiltre(lines,'^Cycle,Step,Record');

%step data statics are first line after each step_header_line
step_data_lines = circshift(step_header_lines,1);
%cycle data statics are first line after each cycle_header_line
cycle_data_lines = circshift(cycle_header_lines,1);
%record data are all other lines:not headers nor step stats nor cycle stats
record_data_lines = ~(step_header_lines | cycle_header_lines |...
    record_header_lines | step_data_lines | cycle_data_lines);

%take the line before first record (it is a record_header_line)
ind_first_record = find(record_data_lines,1);

copy_lines = record_data_lines;
copy_lines(ind_first_record-1) = true;

lines = lines(copy_lines);
fid_out = fopen(file_out,'w+');

% for ind = 1 :length(lines)
%     fprintf(fid_out,'%s\n',lines{ind});
% end
cellfun(@(x) fprintf(fid_out,'%s\n',x),lines);
fclose(fid_out);


end


function [profiles, other_cols] = csv2profiles(file_in)

%custom csv2profiles function to work with landt

%read fid_out
%TODO readtable not in octave
T = readtable(file_in);

%get important (DATTES) variables:
%datetime = T.SysTime in format yyyy-mm-dd HH:MM:SS.FFF
% datenum: convert to matlab serial date number
% m2edate: convert from matlab serial date number to dattes date number
profiles.datetime = m2edate(datenum(T.SysTime));

%t = T.TestTime in format HH:MM:SS.FFF
% datenum: convert to matlab serial date number (0 to end test)
% 86400 convert from days to seconds
profiles.t = datenum(T.TestTime)*86400;

%U
profiles.U = T.Voltage_V;
%I
profiles.I = T.Current_A;

%mode
m_text = T.WorkMode;
m = zeros(size(m_text));
[~,~,ind_rests] = regexpFiltre(m_text,'REST');
[~,~,ind_cc] = regexpFiltre(m_text,'[CD]_CC');
[~,~,ind_cv] = regexpFiltre(m_text,'[CD]_CV');
%TODO EIS = 4?
%TODO other modes? constant power? constant R?
[~,~,ind_cp] = regexpFiltre(m_text,'[CD]_CP');% TO TEST
[~,~,ind_cr] = regexpFiltre(m_text,'[CD]_CR');% TO TEST
[~,~,ind_dcir] = regexpFiltre(m_text,'DCIR');% TO TEST
%1 = CC, 2 = CV, 3 = REST, 4 = EIS, 5 = PROFILE, 6 = CP, 7 = CR, 8 = DCIR
m(ind_cc) = 1;
m(ind_cv) = 2;
m(ind_rests) = 3;
m(ind_cp) = 6;
m(ind_cr) = 7;
m(ind_dcir) = 8;

if any(m==0)
    fprintf('some pointS with unknown mode\n');
end
profiles.m = m;

%temperature
profiles.T = T.Temperature__;

%  dod_ah,soc (not in file_in, empty vars)
profiles.dod_ah = [];
profiles.soc = [];

% step number
profiles.step = T.Step;

% ah, ah_dis, ah_cha
%ah: in landt AmpHour counting is always positive (charge or discharge)
%and reseted at each step change.
[profiles.ah, profiles.ah_dis, profiles.ah_cha] = format_ah_counters(T.Capacity_Ah, profiles.I);



% get varnames and unit names:
varnames = T.Properties.VariableNames;
newvarnames = regexp(varnames,'_','split','once');
units = cellfun(@(x) x(2:end),newvarnames,'UniformOutput',false);
newvarnames = cellfun(@(x) x{1},newvarnames,'UniformOutput',false);

%clean units cell:
for ind = 1:length(units)
if isempty(units{ind})
units{ind} = '';
else
    units{ind} = units{ind}{1};
end
end
units = regexprep(units,'^_$', '');



%get all other variables into other_cols but ignoring non numeric ones:
for ind = 1:length(varnames)
    x = T.(varnames{ind});
    if isnumeric(x)
        other_cols.(newvarnames{ind}) = x;
        other_cols.([newvarnames{ind} '_units']) = units{ind};
    else
        %for debug purpose only
        other_other_cols.(varnames{ind}) = x;
        other_other_cols.([newvarnames{ind} '_units']) = units{ind};
    end
end

end

function [ah, ah_dis, ah_cha] = format_ah_counters(ah,I)

%ah_dis: take ah when current is negative
ah_dis = ah; ah_dis(I>=0) = 0;
%ah_cha: take ah when current is positive
ah_cha = ah; ah_cha(I<=0) = 0;

% make both conunter always increasing:
% derivate
dah_dis = [0; diff(ah_dis)];
dah_cha = [0; diff(ah_cha)];
% ignore negative derivatives
dah_dis(dah_dis<0) = 0;
dah_cha(dah_cha<0) = 0;
% integrate
ah_dis = cumsum(dah_dis);
ah_cha = cumsum(dah_cha);

%make ah_dis negative
ah_dis = -ah_dis;

%recalculate ah as the sum of ah_dis and ah_cha
ah = ah_dis + ah_cha;

end


function xml = profiles2xml(profiles,other_cols, filename)
%Version number
verveh = 0.1;

profiles_units = {'s','s','V','A','','degC','Ah','','','Ah','Ah','Ah'};

%build xml variables
%3.- creer XML
%3.1.- introduire entete:
[XMLHead, err] = makeXMLHead('ladnt',date,'',sprintf('ladnt2xml version:%.2f',verveh));
%3.2.- metatable
[XMLMetatable, err] = makeXMLMetatable(filename,date,filename,'');


%3.3.- profiles variables
variables = fieldnames(profiles);
%change some variable names: (see doc/structure specification)
variables_names = variables;
variables_names(ismember(variables,{'datetime'})) = {'tabs'};
variables_names(ismember(variables,{'t'})) = {'tc'};
variables_names(ismember(variables,{'m'})) = {'mode'};

XMLVars = cell(size(variables));
for ind = 1:length(variables)
    if ~isempty(profiles.(variables{ind}))
        %do not put empty vectors in XML
        [XMLVars{ind}, errorcode] = ...
            makeXMLVariable((variables_names{ind}), (profiles_units{ind}), '%f', (variables_names{ind}), profiles.(variables{ind}));
    end
end
% remove 'empty' vars:
Ie = cellfun(@isempty,XMLVars);
XMLVars = XMLVars(~Ie);

%3.4 other_cols
variables = fieldnames(other_cols);

%separate unis
[units,variables] = regexpFiltre(variables,'_units$');

%TODO: standard variable names:
new_variables = regexprep(variables,'__', '_');% remove duplicates in spaces + underscores

new_variables = regexprep(new_variables,'AuxT' , 'T');

%maybe redundant with profiles.T?
new_variables = regexprep(new_variables,'Temperature' , 'T');

XMLVars_other = cell(size(variables));
for ind = 1:length(variables)
    if isnumeric(other_cols.(variables{ind}))
        %TODO convert cells to double, see csv2profile (try-catch)
        [XMLVars_other{ind}, errorcode] = ...
        makeXMLVariable((new_variables{ind}), other_cols.(units{ind}), '%f', (new_variables{ind}), other_cols.(variables{ind}));
    end
end
% remove 'empty' vars:
Ie = cellfun(@isempty,XMLVars_other);
XMLVars_other = XMLVars_other(~Ie);

%merge all XMLVars:
XMLVars = [XMLVars(:); XMLVars_other(:)];

[xml, errorcode] = makeXMLStruct(XMLHead, XMLMetatable, XMLVars);
end