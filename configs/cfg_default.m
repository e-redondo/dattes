function config = cfg_default(config)
% function config = cfg_default(config)
%
% Create default configuration for RPT.
%
% See also configurator

%ident_R
config.tminR = 9;%duree min d'un pulse pour resistance
config.tminRr = 9;%duree min repos avant

%ident_CPE2
config.tminW = 299;%duree min d'un pulse pour diffusion
config.tminWr = 299;%duree min repos avant
config.CPEafixe = 0.5;%ident CPE2: valeur d'alpha du CPE (si = zero, alpha non fixe).
config.ident_z = @ident_cpe;%fcn handler for impedance identification

%ident_OCVr
config.tminOCVr = 35;%duree min repos pour prise de point OCV
config.dodmaxOCVr = 0.3;%delta soc max prise de point OCV en p.u. (0.5 = 50% soc)
config.dodminOCVr = 0.01;%delta soc min prise de point OCV en p.u. (0.01 = 1% soc)

%ICA
config.dQ = config.Capa/100;%dQ pour essaiICA
config.dU = (config.Umax-config.Umin)/100;%dU pour essaiICA
config.regimeICAmax = 0.25;%regime max pour ICA
config.n_filter=3;%filter order
config.wn_filter=0.1;%filter cut frequency
config.filter_type='G';%filter type ('G' = gaussian)

%pseudoOCV
config.regimeOCVmax = 0.21;%regime max pour pseudoOCV (C/5)
config.regimeOCVmin = 0.19;%regime max pour pseudoOCV (C/5)
config.dQOCV = config.Capa/100;%dQ pour pseudoOCV

%bancs monovoies:
config.Uname = 'U';% par defaut
%bancs multivoies:
% config.Uname = 'U1';
% config.Uname = 'U2';
% config.Uname = 'U3';
%etc.
%capteurs temperature:
config.Tname = '';%par defaut (pas de capteur)
%bancs multivoies:
% config.Tname = 'T1';
% config.Tname = 'T2';
% config.Tname = 'T3';
% etc.

%Graphics:
config.GdDureeMin=300;%duree min pour afficher la phase dans RPT(XML,'','Gd')
config.GdmaxPhases=100;%nombre de phases à partir duquel on doit appliquer GdDureeMin
end
