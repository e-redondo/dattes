function config = cfg_SAMSUNG_INR18650_20R_2Ah
config.Umax = 4.2;%umax cellule
% config.Umax = 4.2;%umax cellule
config.Umin = 2.5;%umin cellule
% config.Umin = 2.65;%umin cellule
config.Capa = 2;%capa nominale

%charger les valeurs par defaut:
config = cfg_default(config);