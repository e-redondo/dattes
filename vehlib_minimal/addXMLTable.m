function [maStruct err] = addXMLTable(maStruct,XMLmetatable, XMLVars)
% [maStruct] = addXMLTable(maStruct, XMLmetatable, XMLVars)
% Famille: XML functions
% Ajoute une table a une structure XML existante
% Parametres d'entree:
% maStruct (struct): XML structure
% XMLmetatable (struct): metatable (c.f. makeXMLMetatable)
% XMLVars (cell): variables de la table (c.f. makeXMLVariable)

maStruct.table{end+1} = struct;
maStruct.table{end}.id = sprintf('%d',length(maStruct.table));
maStruct.table{end}.metatable = XMLmetatable;

%ajouter les variables
for ind = 1:length(XMLVars)
    maStruct.table{end}.(XMLVars{ind}.name)=XMLVars{ind};
end

err = 0;
% TODO: gestion d'erreurs
end
