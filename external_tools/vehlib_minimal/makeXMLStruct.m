function [maStruct err errS] = makeXMLStruct(XMLHead, XMLMetatable, XMLVars)
% [maStruct err errS] = makeXMLStruct(XMLHead, XMLMetatable, XMLVars)
% Famille: XML functions
% Cree une structure XML d'une seule table
% Parametres d'entree:
% XMLHead (struct): tete (c.f. makeXMLHead)
% XMLMetatable (struct) (optional): metatable (c.f. makeXMLMetatable)
% XMLVars (cell) (optional): variables dela table
% Si les parametres 
%creer la structure XMLMetatable et XMLVars ne sont pas fournis, il cree
%une structure vierge (seulement avec Head)
maStruct= struct;
maStruct.head = XMLHead;
maStruct.table = cell(0);

if exist('XMLMetatable','var') && exist('XMLVars','var')
    %ajouter une table
    maStruct = addXMLTable(maStruct, XMLMetatable, XMLVars);
    [maStruct err errS] = verifFomatXML4Vehlib(maStruct);
    return;
end
err = 0;

end
