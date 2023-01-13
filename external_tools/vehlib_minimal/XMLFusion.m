function [outStruct err errS] = XMLFusion(inStruct1,inStruct2)
%function [outStruct err] = XMLFusion(inStruct1,inStruct2)
% put into outStruct the contents of inStruct1 and inStruct2
% only inStruct1.head will be preserved
%parameters:
% inStruct1 [XMLStruct]
% inStruct2 [XMLStruct]
%return values:
% outStruct [XMLStruct]
% err [integer]

%TODO: gestion d'erreurs
if isempty(inStruct1)
    outStruct = inStruct2;
else
    fprintf('Fusion de structures ...');
    outStruct = inStruct1;
    outStruct.table = cell(1,length(inStruct1.table)+length(inStruct2.table));
    outStruct.table(1:length(inStruct1.table))=inStruct1.table(1:length(inStruct1.table));
    outStruct.table(length(inStruct1.table)+1:end)=inStruct2.table(1:length(inStruct2.table));
    fprintf('OK\n');
    fprintf('Mise à jour des index ...');
    for ind=1:1:length(outStruct.table)
        outStruct.table{ind}.id = sprintf('%d',ind);
    end
    fprintf('OK\n');
end
err = 0;
errS = '';
end
