function [head, body, empty_mpt] = read_biologic_file(fid,just_head)
% read_biologic_file Read a *.mpt file (Biologic)
%
%[tete, corps] = read_biologic_file(fid,just_head)
%
% INPUTS
% - fid : valid file handler
% - just_head (opional, boolean): if true, just read file header (metadata)
% OUTPUTS
% - head (px1 cell string): file header (metadata)
% - body (mxn double): du fichier (data)
% - empty_mpt (boolean): true if file contains no data (test stopped
% before)
%
% See also import_biologic

if ~exist('onlyTete','var')
    just_head = false;
end
%initialisation des sorties
head = '';
body = '';
empty_mpt = false;
%lecture de l'entete
[banc, ligne1, ligne2] = which_bench(fid);
if ~strcmp(banc,'bio')
    return%on force l'erreur si pas ECLAB file
end

ligne2Decomposee = regexp(ligne2,'\s','split');
indices = cellfun(@(x) ~isempty(x),ligne2Decomposee);
ligne2Decomposee = ligne2Decomposee(indices);
nb_lignes = sscanf(ligne2Decomposee{end},'%i');

head = cell(nb_lignes,1);
head{1} = ligne1;
head{2} = ligne2;
for ind = 3:nb_lignes
    head{ind} = fgetl(fid);
end
%lecture du corps
ligne1 = fgetl(fid);
if ligne1 == -1
    body=[];%pas de corps la manip a ete arretee avant cette etape
    just_head = true;
    empty_mpt = true;
end
if ~just_head
    if ~isempty(strfind(ligne1,'XXX'))%v10.40
        %il faut remplacer les 'XXX' par 'NaN'
        As1 = strrep(ligne1,'XXX','NaN');
        As = fread(fid,inf, 'uint8=>char')';
        As = strrep(As,'XXX','NaN');
        A1 = sscanf(As1,'%f\t');
        A = sscanf(As,'%f\t');
        A = [A1(:); A(:)];
    else%lecture classique
        A1 = sscanf(ligne1,'%f\t');
        A = fscanf(fid,'%f\t');
        A = [A1(:); A(:)];
    end
    body = reshape(A,length(A1),[])';
end
end
