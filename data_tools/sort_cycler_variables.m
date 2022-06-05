function XMLtable = sort_cycler_variables(XMLtable)
%sort_cycler_variables put bench variable in a standard order
%
% XMLtable = sort_cycler_variables(XMLtable)
% Usage
% Inputs
% - XMLtable: [1x1 struct] table with variable of the result file as fields
% in the cycler order
%
% Outputs 
% -XMLtable: [1x1 struct] table with variable of the result file as fields
% in a standard order
%
% See also: biologic_mpt2xml_files, biologic_mpt2xml_folders, which_cycler
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

fieldList = fieldnames(XMLtable);

fieldList = [fieldList(strcmp(fieldList,'Step')); fieldList(~strcmp(fieldList,'Step'))];
fieldList = [fieldList(strcmp(fieldList,'Cycle')); fieldList(~strcmp(fieldList,'Cycle'))];
fieldList = [fieldList(strcmp(fieldList,'Qp')); fieldList(~strcmp(fieldList,'Qp'))];
fieldList = [fieldList(strcmp(fieldList,'Qc')); fieldList(~strcmp(fieldList,'Qc'))];
fieldList = [fieldList(strcmp(fieldList,'mode')); fieldList(~strcmp(fieldList,'mode'))];
fieldList = [fieldList(strcmp(fieldList,'I')); fieldList(~strcmp(fieldList,'I'))];
fieldList = [fieldList(strcmp(fieldList,'U')); fieldList(~strcmp(fieldList,'U'))];
fieldList = [fieldList(strcmp(fieldList,'tp')); fieldList(~strcmp(fieldList,'tp'))];
fieldList = [fieldList(strcmp(fieldList,'tc')); fieldList(~strcmp(fieldList,'tc'))];
fieldList = [fieldList(strcmp(fieldList,'tabs')); fieldList(~strcmp(fieldList,'tabs'))];
fieldList = [fieldList(strcmp(fieldList,'metatable')); fieldList(~strcmp(fieldList,'metatable'))];
fieldList = [fieldList(strcmp(fieldList,'id')); fieldList(~strcmp(fieldList,'id'))];

XMLtable = orderfields(XMLtable,fieldList);

end