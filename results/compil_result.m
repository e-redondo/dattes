function [rc, cc, pc] = compil_result(rc,cc,pc)
% compil_result results compilation (configs et phases)
% When processing a batch of files with dattes, cellfun is used so
% [r,c,p]=dattes(filelist,...), r,c and p are cell type.
% This function convert cell types to structure arrays.
%
%[r, c, p] = compil_result(rc,cc,pc)
% - rc [nx1 cell] each element is a structure type 'result'
% - cc [nx1 cell] each element is a structure type 'config'
% - pc [nx1 cell] each element is a structure type 'phases'
% - r [nx1 struct] nx1 structure array type 'resultt'
% - c [nx1 struct] nx1 structure array type 'config'
% - p [nx1 struct] nx1 structure array type 'phases'
% Non existing fields will be initialized as empty arrays ([]).
%
% See also dattes

%verifer les champs, ceux qui n'y sont pas les initialiser a vide
%resultat
fieldList = cellfun(@fieldnames,rc,'UniformOutput',false);
fieldU = unique(vertcat(fieldList{:}));
for ind = 1:length(rc)
    cetteListe = fieldList{ind};
    Im = ~ismember(fieldU,cetteListe);
    chamsManquants = fieldU(Im);
    for ind2 = 1:length(chamsManquants)
        %s'il manquent des champs, on les ajoute vides ([])
        rc{ind}.(chamsManquants{ind2})=[];
    end
end
%config
fieldList = cellfun(@fieldnames,cc,'UniformOutput',false);
fieldU = unique(vertcat(fieldList{:}));
for ind = 1:length(cc)
    cetteListe = fieldList{ind};
    Im = ~ismember(fieldU,cetteListe);
    chamsManquants = fieldU(Im);
    for ind2 = 1:length(chamsManquants)
        %s'il manquent des champs, on les ajoute vides ([])
        cc{ind}.(chamsManquants{ind2})=[];
    end
end

%decapsuler les cellules
rc = [rc{:}];
cc = [cc{:}];
pc = reshape(pc,size(rc));

end