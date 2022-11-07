clear all;
%struct 1 is like profiles but without dod nor soc
% err = 0
struct1 = struct;
struct1.t = ones(10,1);
struct1.U = ones(10,1);
struct1.I = ones(10,1);
struct1.m = ones(10,1);

% struct2 is like struct1 with soc and dod_ah
% err = 0
struct2 =  (struct1);
struct2.soc = ones(10,1);
struct2.dod_ah = ones(10,1);
% struct3 is like struct2 with some wrong types
% err = -2
struct3 = struct(struct2);
struct3.soc = struct;
struct3.dod_ah = 'hello';
%struct4 has some not allowed fields:
% err = -3
struct4 = struct2;
struct4.capacity = 5;
struct4.datetime_ini = 70000000;
%struct5 is like struct2 with some missing fields
% err=-1 (NOTE: err=-1 priority over err=-3)
struct5 = rmfield(struct4,'U');
struct5 = rmfield(struct5,'I');

% checkstruct:
allowed_fields = {'t','U','I','m','soc','dod_ah'};
mandatory_fields = {'t','U','I','m'};
field_types = {'double','double','double','double','double','double'};

%check struct1
[info1, err1] = check_struct(struct1, allowed_fields, field_types, mandatory_fields);
%check struct2
[info2, err2] = check_struct(struct2, allowed_fields, field_types, mandatory_fields);
%check struct3
[info3, err3] = check_struct(struct3, allowed_fields, field_types, mandatory_fields);
%check struct4
[info4, err4] = check_struct(struct4, allowed_fields, field_types, mandatory_fields);
%check struct5
[info5, err5] = check_struct(struct5, allowed_fields, field_types, mandatory_fields);
