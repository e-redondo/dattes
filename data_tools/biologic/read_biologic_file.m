function [head, body, empty_mpt] = read_biologic_file(fid,just_head)
% read_biologic_file Read a *.mpt file (Biologic)
%
% Usage:
% [head, body, empty_mpt] = read_biologic_file(fid,just_head)
%
% Inputs
% - fid : valid file handler
% - just_head (opional, boolean): if true, just read file header (metadata)
% Outputs
% - head (px1 cell string): file header (metadata)
% - body (mxn double): du fichier (data)
% - empty_mpt (boolean): true if file contains no data (test stopped
% before)
%
% See also import_biologic
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.


if ~exist('just_head','var')
    just_head = false;
end
%Initialise outputs
head = '';
body = '';
empty_mpt = false;
% Reading header
[cycler, line1, line2] = which_cycler(fid);
if ~strcmp(cycler,'bio')
    return% Error if not an ECLAB file
end

line2_split = regexp(line2,'\s','split');
indices = cellfun(@(x) ~isempty(x),line2_split);
line2_split = line2_split(indices);
nb_lignes = sscanf(line2_split{end},'%i');

head = cell(nb_lignes,1);
head{1} = line1;
head{2} = line2;
for ind = 3:nb_lignes
    head{ind} = fgetl(fid);
end

%Reading body
line1 = fgetl(fid);
if line1 == -1
    body=[]; %No body, test stopped before this step 
    just_head = true;
    empty_mpt = true;
end
if ~just_head
    if ~isempty(strfind(line1,'XXX'))%v10.40
        %il faut remplacer les 'XXX' par 'NaN'
        As1 = strrep(line1,'XXX','NaN');
        As = fread(fid,inf, 'uint8=>char')';
        As = strrep(As,'XXX','NaN');
        A1 = sscanf(As1,'%f\t');
        A = sscanf(As,'%f\t');
        A = [A1(:); A(:)];
    else%Classic reading
        A1 = sscanf(line1,'%f\t');
        A = fscanf(fid,'%f\t');
        A = [A1(:); A(:)];
    end
    body = reshape(A,length(A1),[])';
end
end
