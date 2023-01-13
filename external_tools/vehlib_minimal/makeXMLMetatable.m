function [XMLMetatable err] = makeXMLMetatable(name,date,sourcefile,comments)
% [XMLMetatable err] = makeXMLMetatable(name,date,sourcefile,comments)
% Famille: XML functions
% Cree une tete de table XML (metatable)
%Parametres d'entree:
% name [string]: nom de la table
% date [string] (optional): date des donnees (du test, de la simulation ...)
% sourcefile [string] (optional): fichier brut (p.ex.: csv)
% comments [string] (optional): commentaires
XMLMetatable= struct;
err = 0;
if ~exist('date','var')
    date = '';
end
if ~exist('sourcefile','var')
    sourcefile = '';
end
if ~exist('comments','var')
    comments = '';
end

if (~ischar(name) || ~ischar(date) || ~ischar(sourcefile) ||...
        ~ischar(comments))
    disp('makeXMLMetatable: erreur de type dans les parametres')
    err = -1;
    return
end
XMLMetatable.name = name;
XMLMetatable.date = date;
XMLMetatable.sourcefile = sourcefile;
XMLMetatable.comments = comments;
end