function [XMLHead err] = makeXMLHead(type,date,project,comments)
% [XMLHead err] = makeXMLHead(type,date,project,comments)
% Famille: XML functions
% Cree une tete de fichier XML
%Parametres d'entree:
% type [string]: type de fichier (peut etre vide)
% date [string]: date du fichier (du test, de la simulation ...)
% project [string] (optional): projet
% comments [string] (optional): commentaires
XMLHead= struct;
err = 0;
if ~exist('project','var')
    project = '';
end
if ~exist('comments','var')
    comments = '';
end
if (~ischar(type) || ~ischar(date) || ~ischar(project) ||...
        ~ischar(comments))
    disp('makeXMLHead: erreur de type dans les parametres')
    err = -1;
    return
end
XMLHead.version = '';
XMLHead.type = type;
XMLHead.date = date;
XMLHead.project = project;
XMLHead.comments = comments;
end