function [XMLVar errorcode] = makeXMLVariable(name, unit, precision, longname, vector)
% [XMLVar errorcode] = makeXMLVariable(name, unit, precision, longname, vector)
% Famille: XML functions
% Cree une variable XML
%Parametres d'entree:
% name (string): nom de la variable (doit etre un nom valide pour MATLAB)
% unit (string): unite de mesure (peut etre vide)
% precision (string): precision (%i, %f, %.3f ...)
% longname (string): nom complet de la variable (titres d'axe des plots)
% vector (double): les donnees numeriques
XMLVar= struct;
errorcode = 0;
if (~ischar(name) || ~ischar(unit) || ~ischar(precision) ||...
        ~ischar(longname) || ~isnumeric(vector))
    disp('makeXMLVariable: erreur de type dans les parametres')
    errorcode = -1;
    return
end
XMLVar.name = name;
XMLVar.unit = unit;
XMLVar.precision = precision;
XMLVar.type = '';
XMLVar.longname = longname;
XMLVar.vector = vector(:);
end