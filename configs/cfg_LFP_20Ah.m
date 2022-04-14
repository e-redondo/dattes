function config = cfg_LFP_20Ah
%valeurs propres a cette cellule:
config.Umax = 3.6;%umax cellule
config.Umin = 2;%umin cellule
config.Capa = 20;%capa nominale

%charger les valeurs par defaut:
config = cfg_default(config);
%modification de valeurs:
config.Uname = 'U1';
end