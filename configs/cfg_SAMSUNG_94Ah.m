function config = cfg_SAMSUNG_94Ah


%values for this cell:
config.test.max_voltage = 4.15;
config.test.min_voltage = 2.7;
config.test.capacity = 94;

%charger les valeurs par defaut:
config = cfg_default(config);

config.test.Uname = 'U1';%nom pour la variable tension (Bitrode AuxVoltage1 = U1)
config.test.Tname = 'T1';%nom pour la variable temperature

 
% %ident_R
config.resistance.delta_time=[0 4 9 29 59]; %Instant du pulse auquel on mesure R (par défaut 0 secondes)
config.resistance.pulse_min_duration = 9;%duree min d'un pulse pour resistance
config.resistance.rest_min_duration =9;%duree min repos avant

% ident_RC
% config.maximal_duration_pulse_measurement_R = 40; % Durée maximale pour l'identification d'un RC
config.impedance.initial_params = [1e-3, 150, 1e-2, 400];% ident_rrc R1ini, C1ini, R2ini, C2ini
config.impedance.ident_fcn = @ident_rrc;% use ident_rrc

config.Rmin=1e-4;
config.Cmin=50;
config.Rmax=5e-2;
config.Cmax=800000;



% %ident_CPE2
% config.tminW = 59;%duree min d'un pulse pour diffusion
% config.tminWr = 59;%duree min repos avant
% config.CPEafixe = 0.5;%ident CPE2: valeur d'alpha du CPE (si = zero, alpha non fixe).
% 
% %ident_OCVr
% config.tminOCVr = 10;%duree min repos pour prise de point OCV
% config.dodmaxOCVr = 0.99;%delta soc max prise de point OCV en p.u. (0.5 = 50% soc)
% config.dodminOCVr = 0.01;%delta soc min prise de point OCV en p.u. (0.01 = 1% soc)
% 
% %pseudoOCV
config.pseudo_ocv.max_crate = 0.08;%regime max pour pseudoOCV (C/20) 
config.pseudo_ocv.min_crate = 0.03;%regime max pour pseudoOCV (C/20)
config.pseudo_ocv.capacity_resolution = config.test.capacity/100;%dQ pour pseudoOCV


%%Graphiques
config.langue_plot="EN";
config.langue_plot="FR";
config.DoD_or_SoC="DoD";
config.over100_or_over1_or_Ah="over100";
config.time_scale="h";
config.reference_capacity="nominal";

end
