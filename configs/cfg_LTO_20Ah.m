function config = cfg_LTO_20Ah

%values for this cell:
config.test.max_voltage = 2.8;
config.test.min_voltage = 1.5;
config.test.capacity = 20;

%charger les valeurs par defaut:
config = cfg_default(config);
%modification de valeurs:
config.Uname = 'U1';
end