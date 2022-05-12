function config = cfg_LTO_20Ah
%valeurs propres a cette cellule:
config.Umax = 2.8;%umax cellule
config.Umin = 1.5;%umin cellule
config.Capa = 20;%capa nominale

%charger les valeurs par defaut:
config = cfg_default(config);
%modification de valeurs:
config.Uname = 'U1';
end