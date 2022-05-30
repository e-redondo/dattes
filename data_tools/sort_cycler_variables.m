function XMLtable = sort_cycler_variables(XMLtable)
%sort_cycler_variables put bench variable in a standard order

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