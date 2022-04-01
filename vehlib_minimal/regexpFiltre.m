function [S, Sn, Is, Ins] = regexpFiltre(C, expression,options)
% regexpFiltre Filtre un cell string par une expression reguliere.
%     S = regexpFiltre(C, expression) avec 'C' cell string et 'expression'
%     une chaine de texte qui contient une expression reguliere retourne 'S',
%     un cell string qui ne contient que les elements de C en accord avec
%     l'expression reguliere.
% 
%     [S, Sn] = regexpFiltre(C, expression) retourne en plus Sn, les elements
%     en desaccord avec l'expression reguliere (union(S,Sn) = C).
% 
%     [S, Sn, Is, Ins] = regexpFiltre(C, expression) retourne Is et Ins,
%     matrices logiques telle que  S = C(Is) et Sn = C(Ins)
% 
%     Parametres d'entree:
%     C ([nx1] cell string): cellule qui contient des chaines de texte 
%     expression (string): expression reguliere
%     options (string, optional):
%     - 'i': ignoreCase
%     Valeurs de sortie:
%     S ([px1] cell string): cellule qui contient les chaines de texte en
%     accord avec l'expression reguliere donnee
%     Sn ([n-px1] cell string): cellule qui contient les chaines de texte en
%     desaccord avec l'expression reguliere donnee
%
%     Exemple:
%     fileList = lsFiles(srcdir,'*');% liste tous les fichiers dans srcdir
%     [XML notXML] = regexpFiltre(fileList, '.xml$');
%     %XML contient les fichiers avec extension '.xml', notXML contient tous
%     les autres fichiers.
%
%     Exemple (2): (ignore case option)
%     >> wordList = {'Hello Friend','hello friend','Hola Francis'};
%     >> [S] = regexpFiltre(wordList, 'H.l.*Fr')
% 
% S =
% 
%   1×2 cell array
% 
%     {'Hello Friend'}    {'Hola Francis'}
%
%     >> [Si] = regexpFiltre(wordList, 'H.l.*Fr','i')
%
% 
% Si =
% 
%   1×3 cell array
% 
%     {'Hello Friend'}    {'hello friend'}    {'Hola Francis'}
%
%   See also regexp, regexpi, lsFiles

if ~exist('options')
    options = '';
end
if ismember('i',options)
    re_fcn = @regexpi;
else
    re_fcn = @regexp;
end
% Ins = cellfun(@isempty,regexp(C,expression,'start','once'));
Ins = cellfun(@isempty,re_fcn(C,expression,'start','once'));
Is = ~Ins;

Sn = C(Ins);
S = C(Is);

end