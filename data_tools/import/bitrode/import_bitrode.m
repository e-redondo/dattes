function xml = import_bitrode(file_in,options)
% import_bitrode Bitrode *.csv to VEHLIB XMLstruct converter
%
% Usage
% xml = import_bitrode(filename,pathname)
% Inputs:
% - file_in (string): csv file to convert
% - options (string): containing the following characters
%   - 'v': verbose, tells what it does
%
% Outputs:
% - xml (struct): structure with XML format 4 VEHLIB
%
% See also bitrode_csv2xml, which_cycler
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab:
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

if ~exist('options','var')
    options='';
end
verbose = ismember('v',options);

verveh = 2.0;
%TODO: get date_time from test (>>> .mdb file) >>> tabs

%0. check if file exists
[D, F, E] = fileparts(file_in);
file_out = fullfile(D,sprintf('%s.veh2',F));
if ~exist(file_in,'file')
    fprintf('import_bitrode: file does not exist: %s\n',file_in);
    xml = [];
    return;
end


if verbose
    fprintf('%s >>> %s\n',file_in,file_out);
end
    fid_in = fopen_safe(file_in);
%0.1 check if file is a bitrode file
[cycler, line1, line2, header_lines] = which_cycler(fid_in);

if ~strncmp(cycler,'bitrode_csv',11)
    fprintf('ERROR: file does not seem a bitrode *.csv file: %s\n',file_in);
    xml = [];
    return;
end
    fid_out = fopen (file_out,'w+','n','ISO-8859-1');

    chrono=tic;
    %2.1: mixed number/char csv: replace some char string by numbers
    % char strings to replace
    strold={',LDCH,';',LCHR,';',DCHG,';',REST,';',CHRG,';',LRDCH,';',LRCHR,';...%Mode
        ',S,';', ,';',Q,';',H,';',Z,';',A,';',a,';...%DataAcqFlag
        ',L,';',R,';',C,';',D,';','};%Mode
    % numbers to put instead
    strnew={',-1,';',1,';',-10,';',0,';',10,';',-2,';',2,';...%Mode
        ',99,';',0,';',100,';',101,';',102,';',103,';',103,';...%DataAcqFlag
        ',1,';',0,';',10,';',-10,';sprintf('\t')};%Mode
    
    %write intermediary file 'file_in.veh2':
    nb_lignes=find_replace(fid_in,fid_out,strold,strnew,0);
    fclose(fid_in);
    fclose(fid_out);

    %read intermediary file 'file_in.veh2':

    fid_out = fopen_safe(file_out);
    %read header lines until 'Total Time'
    thisLine = fgetl(fid_out);
    header = cell(0);
    testName = '';
    testDate = '';
%     while ~strncmp(thisLine,'Total Time',10)
    while isempty(regexp(thisLine, 'Total Time'))
        header{end+1} = thisLine;

        if strncmp(thisLine,'TestName',8)
            testName = regexp(thisLine,'\t','split');
            testName = testName{2};
        end
        if strncmp(thisLine,'Test Date',9)
            testDate = regexp(thisLine,'\t','split');
            testDate = testDate{2};
        end
        thisLine = fgetl(fid_out);
    end
    if isempty(testName)%if not found, test name is the filename
        testName = file_in;
    end

    if thisLine(1)=='"'
        % new format: "Total Time, S","Cycle","Loop Counter #1",...
        thisLine = regexprep(thisLine,'\t ','_');
    end
    %variables
    variables = thisLine;
%     variables = regexprep(variables,' ','');%erase spaces
    strold = {'#';' ';'-';'"'};
    strnew = {'Nr';'';'';''};
    variables = regexprep(variables,strold,strnew);

    variables = regexp(variables,'\t','split');
    indices = cellfun(@(x) ~isempty(x),variables);
    variables = variables(indices);

    %new format 'TotalTime,S', cut ',S':
    [v, u] = regexp(variables,',','split');
    variables = cellfun(@(x) x{1},v,'UniformOutput',false);
    %variables et unites
    unites=unitesBitrode(variables);
    variables=variablesBitrode(variables);%standardiser les noms de variables

    %corps
    A = fscanf(fid_out,'%f');
    fclose(fid_out);
    A = reshape(A,length(variables),[])';

    %introduire entete:
    [XMLHead, err] = makeXMLHead('bitrode',date,'',sprintf('Bitrode2VEH version:%.2f',verveh));
    %metatable
    [XMLMetatable, err] = makeXMLMetatable(testName,testDate,file_in,'');

    XMLVars = cell(size(variables));
    for ind = 1:length(variables)
        [XMLVars{ind}, errorcode] = ...
            makeXMLVariable((variables{ind}), (unites{ind}), '%f', (variables{ind}), A(:,ind));
    end

    [xml, errorcode] = makeXMLStruct(XMLHead, XMLMetatable, XMLVars);
    %get cycler mode
    t = xml.table{end}.tc.vector;
    U = xml.table{end}.U.vector;
    I = xml.table{end}.I.vector;
    if isfield(xml.table{end},'step')
        step = xml.table{end}.step.vector;
    else
        step = find_steps(t,I,U, 0.001,'v');
        %ajouter aux variables de xml
        step = makeXMLVariable('mode','', '%f','mode', step);
        xml.table{end}.step = step;
    end

    seuilI = 5*min(abs(diff(unique(I))));
    if isempty(seuilI)
        %if is empty, that means all values of I are equal (cst vector)
        % random value to avoid error in which_mode: 10mA
        seuilI = 0.01;
    end
    seuilU = 5*min(abs(diff(unique(U))));
    if isempty(seuilU)
        %if is empty, that means all values of U are equal (cst vector)
        % random value to avoid error in which_mode: 1mV
        seuilU = 0.001;
    end
    m = which_mode(t,I,U,step,seuilI,seuilU);
    %ajouter aux variables de xml
    mode = makeXMLVariable('mode','', '%f','mode', m);
    xml.table{end}.mode = mode;

    % Add 'tabs' (absolute time)
    Datem = datenum_guess(testDate);% date format 'Matlab'
    if isnumeric(Datem)
        Datee = m2edate(Datem);%date format 'Eduardo'
        tabs = xml.table{end}.tc.vector + Datee;
    else
        tabs = xml.table{end}.tc.vector;
    end
    tabs = makeXMLVariable('tabs', 's', '%f', 'temps absolu', tabs);
    xml.table{end}.tabs = tabs;

    %met les variables dans l'ordre
    xml.table{end} = sort_cycler_variables(xml.table{end});
    %on elimine le fichier 'copy'
    pause(0.1),  delete(file_out);
    tecoule = toc(chrono);
    if verbose
        fprintf('file %s ready in %0.2f seconds (%d lines).\n',file_out,tecoule,nb_lignes);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  FONCTIONS LOCALES
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%fonction pour faire FIND & REPLACE
% function nb_lignes=find_replace(fidIn,fidOut,strold,strnew)
function nb_lignes=find_replace(fidIn,fidOut,strold,strnew,skiplines)
%strold et strnew sont des cellules, pour plusieurs remplacements au meme
%temps
%accepte strings du type '\n...'; il cherchera '...' au debut de ligne.
if exist('skiplines','var')
    for ind = 1:skiplines
        fprintf(fidOut,'%s\n',fgetl(fidIn));
    end
end

A=fread(fidIn,inf, 'uint8=>char')';
% A = regexprep(A,strold,strnew);%CA MARCHE PAS TROP LENT!!!!!
for i=1:1:size(strold,1)
    sold=strold{i};
    snew=strnew{i};
        A=strrep(A, sold, snew);
end
fwrite(fidOut,A);
nb_lignes=length(find(A==sprintf('\n')));
% fprintf('%d lines\n',nb_lignes);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%fonction pour etablir les unites
% function unites=unitesBitrode(variables)
function unites=unitesBitrode(variables)

unites = cell(size(variables));
unites(:) = {''};
indices = cellfun(@(x) ~isempty(x),regexpi(variables,'time'));
unites(indices) = {'s'};
indices = cellfun(@(x) ~isempty(x),regexpi(variables,'voltage|volts'));
unites(indices) = {'V'};
indices = cellfun(@(x) ~isempty(x),regexpi(variables,'current|amps'));
unites(indices) = {'A'};
indices = cellfun(@(x) ~isempty(x),regexpi(variables,'power|watts'));
unites(indices) = {'W'};
indices = cellfun(@(x) ~isempty(x),regexpi(variables,'temperature'));
unites(indices) = {'degC'};
indices = cellfun(@(x) ~isempty(x),regexpi(variables,'amph'));
unites(indices) = {'Ah'};
indices = cellfun(@(x) ~isempty(x),regexpi(variables,'watth'));
unites(indices) = {'Wh'};
indices = cellfun(@(x) ~isempty(x),regexpi(variables,'digital'));
unites(indices) = {'IO'};
indices = cellfun(@(x) ~isempty(x),regexpi(variables,'counter|cycle|step$'));
unites(indices) = {'n'};

end
function variables=variablesBitrode(variables)

%6.2.- standardiser les noms des variables:
%     'TotalTime', 'tc'
variables = regexprep(variables,'TotalTime', 'tc');
%     'Date_Time', 'tabs':

%     'Step', 'step'
variables = regexprep(variables,'^Step$', 'step');

%     'Steptime', 'tp'
variables = regexprep(variables,'Steptime', 'tp');

%     'InstantaneousAmps' , 'I'
variables = regexprep(variables,'InstantaneousAmps' , 'I');
%     'InstantaneousVolts' , 'U'
variables = regexprep(variables,'InstantaneousVolts' , 'U');
%     'CellVoltageA1'
%     'CellVoltageA2'
%     'CellVoltageA3'
variables = regexprep(variables,'CellVoltageA' , 'U');
%     'TemperatureA1'
%     'TemperatureA2'
%     'TemperatureA3'
variables = regexprep(variables,'TemperatureA' , 'T');

%AUTRES VARIABLES BITRODE
%     'Cycle'
%     'LoopCounterNr1'
%     'LoopCounterNr2'
%     'LoopCounterNr3'
%     'Step'
%     'Current'
%     'Voltage'
%     'Power'
%     'InstantaneousWatts'
%     'AmpHours'
%     'WattHours'
%     'AmpHoursCharge'
%     'AmpHoursDischarge'
%     'WattHoursCharge'
%     'WattHoursDischarge'
%     'UnassignedA1..22'
%     'Mode'
%     'DataAcquisitionFlag'


%nettoyer '_unit' à la fin:
variables = regexprep(variables,'_.*$' , '');


%     'AmpHoursDischarge'
variables = regexprep(variables,'AmpHoursDischarge' , 'ah_dis');
%     'AmpHoursCharge'
variables = regexprep(variables,'AmpHoursCharge' , 'ah_cha');
%     'AmpHours'
variables = regexprep(variables,'AmpHours' , 'ah');

end
