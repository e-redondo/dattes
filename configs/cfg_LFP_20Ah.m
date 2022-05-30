function config = cfg_LFP_20Ah

%values for this cell:
config.test.max_voltage = 3.6;
config.test.min_voltage = 2.0;
config.test.capacity = 20;

%charger les valeurs par defaut:
config = cfg_default(config);
%modification de valeurs:
config.Uname = 'U1';
config.tminWr = 10;%duree min repos avant

end