# DATTES structure specification (current version)

This document describe data structure for current version of DATTES:
- **result structure**: data structuration of DATTES output
- **XML structure**: data structuration for XML files

## result structure
- result [1x1 struct] with fields:
    - profiles [1x1 struct]:
        - created by extract_profiles
        - modified by calcul_soc and calcul_soc_patch
        - contains (mx1) vectors with main cell variables (t,U,I,m,soc,dod_ah)
    - eis [1x1 struct]:
        - created by extract_profiles
        - contains (px1) cells with EIS measurements, each 'p' contains (nx1) vectors (t,U,I,m,ReZ,ImZ,f)
    - metadata: [1×1 struct]:
        - created by metadata_collector (extract_profiles) if any '.meta' file found
    - test [1x1 struct]:
        - created by dattes
        - modified by calcul_soc and calcul_soc_patch
        - contains filename
        - contains general values of the test initial/final values
    - phases [1xq struct]:
        - created by split_phases
        - each phase contains general values like initial/final/average values (time, voltage, current...)
    - configuration [1x1 struct]:
        - created by config scripts
        - modified by cfg_default, configurator
    - capacity [1x1 struct]:
        - created by ident_capacity
        - contains (1xk) vectors for CC capacity measurements
        - contains (1xi) vectors for CV phases
        - contains (1xj) vectors for CCCV capacity measurements
    - pseudo_ocv [1xr struct]:
        - created by ident_pseudo_ocv (empty struct if error)
        - each pseudo_ocv contains (sx1) vectors for each pseudo_ocv measurement (charge/discharge half cycles)
        - each pseudo_ocv contains (1x1) values (crate and time of measurement)
    - ocv_points [1x1 struct]:
        - created by ident_ocv_by_points (empty struct if error)
        - contains (tx1) vectors for each ocv points
    - resistance [1x1 struct]:
        - created by ident_r (empty struct if error)
        - contains (1xv) vectors for resistance measurements
    - impedance [1x1 struct]:
        - created by ident_cpe, ident_rrc (empty struct if error)
        - contains (1xg) string with chosen topology (R+CPE or R+RC+RC)
        - contains (1xw) vectors for impedance identifications (circuit parameters)
    - ica [1xy struct]:
        - created by ident_ica (empty struct if error)
        - each ica contains (zx1) vectors for each ICA measurement
### profiles substructure
- profiles [1x1 struct] with fields:
    - t [mx1 double]: absolute time in seconds (seconds from 1/1/2000 00:00)
    - U [mx1 double]: cell voltage (V)
    - I [mx1 double]: current (A)
    - m [mx1 double]: cycler mode (n.u.), 1=CC, 2=CV, 3=rest, 4=EIS, 5=profile
    - T [mx1 double]: cell temperature (empty if no probe found)
    - dod_ah [mx1 double]:  Depth of Discharge in Ah (empty if no SoC calculation)
    - soc [mx1 double]:  State of Charge in % (empty if no SoC calculation)
### eis substructure
- eis [1x1 struct] with fields:
    - t [px1 cell of [nx1 double]]: absolute time in seconds (seconds from 1/1/2000 00:00)
    - U [px1 cell of [nx1 double]]: cell voltage (V)
    - I [px1 cell of [nx1 double]]: current (A)
    - m [px1 cell of [nx1 double]]: cycler mode (n.u.), 1=CC, 2=CV, 3=rest, 4=EIS, 5=profile
    - ReZ [px1 cell of [nx1 double]]:  Real part of impedance (Ohm)
    - ImZ [px1 cell of [nx1 double]]:  Imaginary part of impedance (Ohm)
    - f [px1 cell of [nx1 double]]: frecuency (Hz)
### metadata substructure
- metadata [1x1 struct] with fields:
    - test: [1×1 struct] with fields:
        - institution [string]: name of institution (e.g. university)
        - laboratory [string]: name of laboratory / department
        - experimenter [string]: person who made this test
        - datetime [string]: date and time of the test
        - temperature [1x1 double]: ambient (chamber) temperature
        - purpose [string]: brief desccription of the test
    - cell: [1×1 struct] with fields:
        - id [string]: cell unique identifier
        - brand [string]: cell manufacturer
        - model [string]: cell model
        - max_voltage [1x1 double]: cell max voltage (V)
        - min_voltage [1x1 double]: cell min voltage (V)
        - nom_voltage [1x1 double]: cell nominal voltage (V)
        - nom_capacity [1x1 double]: cell nominal capacity (Ah)
        - max_dis_current_cont [1x1 double]: max continuous discharge current (A)
        - max_cha_current_cont [1x1 double]: max continuous charge current (A)
        - min_temperature [1x1 double]: min temperature (degC)
        - max_temperature [1x1 double]: max temperature (degC)
        - geometry [string]: shape (e.g. 'cylindrical', 'prismatic')
        - dimensions [1x2 or 1x3 double]: diameter x length or l x w x h in mm
        - weight [1x1 double]: weight in g
        - cathode [string]: e.g. 'NMC'
        - anode [string]: e.g. 'graphite'
    - cycler: [1×1 struct] with fields:
        - brand [string]: e.g 'Bitrode'
        - model [string]: e.g 'FTV60-250'
        - voltage_resolution: voltage resolution in V
        - current_resolution: currant resolution in A
        - cell_voltage_name [string]: variable name for cell voltage measurement (e.g. 'U1')
        - cell_temperature_name [string]: variable name for cell temperature measurement (e.g. 'U1')
    - chamber: [1×1 struct] with fields:
        - brand [string]: e.g 'Friocell'
        - model [string]: e.g 'Friocell 707'
    - regional: [1×1 struct] with fields:
        - date_format [string]: e.g 'yyyy/mm/dd'
        - time_format [string]: e.g 'HH:MM:SS.SSS'
### test substructure
- test [1x1 struct] with fields:
    - file_in [1xf char]: pathname of XML input file
    - t_ini [1x1 double]: test start time in seconds from 1/1/2000 00:00
    - t_fin [1x1 double]: test end time in seconds from 1/1/2000 00:00
    - dod_ah_ini [1x1 double]: initial DoD in Ah
    - soc_ini [1x1 double]: initial SoC in %
    - dod_ah_fin [1x1 double]: final DoD in Ah
    - soc_fin [1x1 double]: final SoC in %
### phases substructure
- phases [1xq struct] with fields:
    - t_ini [1x1 double]:phase start time in seconds from 1/1/2000 00:00
    - t_fin [1x1 double]:phase end time in seconds from 1/1/2000 00:00
    - duration [1x1 double]: phase duration
    - Uini [1x1 double]: initial cell voltage
    - Ufin [1x1 double]: final cell voltage
    - Iini [1x1 double]: initial current
    - Ifin [1x1 double]: final current
    - Uavg [1x1 double]: average cell voltage
    - Iavg [1x1 double]: average current
    - capacity [1x1 double]: phase capacity (Ah)
    - mode [1x1 double]: cycler mode
### configuration substructure
- configuration [1x1 struct] with fields:
    - test [1×1 struct]: general configuration
        - max_voltage (1x1 double): max cell voltage
        - min_voltage (1x1 double): min cell voltage
        - capacity (1x1 double): cell nominal capacity (base for SoC %)
        - cfg_file (string): config script name
        - Uname (string): name of voltage variable (default = 'U')
        - Tname (string): name of temperature variable (default = '', no probe)
    - soc [1×1 struct]: configuration for soc calculation
        - crate_cv_end (1x1 double): C-rate limit in CV phase (default = 1/20)
        - soc100_time (nx1 double): time where SoC is set to 100 (crate_cv_end)
        - soc0_time (nx1 double): time where SoC is set to 0 (crate_cv_end), unused
        - dod_ah_ini (1x1 double): initial dod (Ah) if set by calcul_soc_patch
        - dod_ah_fin (1x1 double): final dod (Ah) if set by calcul_soc_patch
    - capacity [1×1 struct]: configuration for capacity calculation
        - pCapaD (1xq logical): true for discharging capacity CC phases
        - pCapaC (1xq logical): true for charging capacity CC phases
        - pCapaDV (1xq logical): true for discharging capacity CV phases
        - pCapaCV (1xq logical): true for charging capacity CV phases
    - resistance [1×1 struct]: configuration for resistance calculation
        - delta_time (1xb double): delta time  in seconds for resistance calculation
        - pulse_min_duration (1x1 double): minimum pulse duration in seconds (default = 9)
        - pulse_max_duration (1x1 double): maximum pulse duration in seconds (default = 599)
        - rest_min_duration (1x1 double): minimum rest duration before pulse in seconds (default = 9)
        - pR (1xq logical): true for resistance phases
        - instant_end_rest (nx1 double): start times for resistance pulses (to be removed in future)
    - impedance [1×1 struct]: configuration for impedance calculation
        - ident_fcn (fcn_handle): function used for impedance identificaiton (default = ident_cpe)
        - pulse_min_duration (1x1 double): minimum pulse duration in seconds (default = 299)
        - pulse_max_duration (1x1 double): maximum pulse duration in seconds (default = 599)
        - rest_min_duration (1x1 double): minimum rest duration before pulse in seconds (default = 9)
        - fixed_params (1x1 bool): if true, fix some parameters in identification (default = false)
        - initial_params (1xc double): initial parameter values
        - pZ (1xq logical): true for impedance phases
        - instant_end_rest (nx1 double): start times for resistance pulses (to be removed in future)
    - ocv_points [1×1 struct]: configuration for ocv_points calculation
        - rest_min_duration (1x1 double): minimum rest duration (s) after ocv pulse (default = 35)
        - max_delta_dod_ah (1x1 double): maximum delta DoD (Ah) for ocv pulse (default = 0.3), unused
        - min_delta_dod_ah (1x1 double): minimum delta DoD (Ah) for ocv pulse (default = 0.01), unused
        - pOCVr (1xq logical): true for ocv_points phases
    - ica [1×1 struct]: configuration for ica calculation
        - capacity_resolution (1x1 double): delta dod in ica calculation (Ah) (default = capacity/100)
        - voltage_resolution (1x1 double): delta dod in ica calculation (Ah) (default = (voltage cell range)/100)
        - max_crate (1x1 double): maximum allowed C-rate to consider a phase for ICA (default = 0.25)
        - filter_type (1x1 char): filter type (default 'G' = gaussian)
        - filter_order (1x1 double): filter order (default 30)
        - filter_cut (1x1 double): filter cut frequency (default 5)
        - pICA (1xq logical): true for ica phases
    - pseudo_ocv [1×1 struct]: configuration for pseudo_ocv calculation
        - max_crate (1x1 double): maximum allowed C-rate to consider a phase for pseudo_ocv (default = 1)
        - min_crate (1x1 double): minimum allowed C-rate to consider a phase for pseudo_ocv (default = 0)
        - capacity_resolution (1x1 double): delta dod in pseud_ocv calculation (Ah) (default = capacity/100)
        - pOCVpC (1xq logical): true for pseudo_ocv charging half cycles
        - pOCVpD (1xq logical): true for pseudo_ocv discharging half cycles
    - visualization [1×1 struct]: configuration for plots (unused)
        - GdDureeMin: minimum phase duration (s) for plot_phases (default = 300)
        - GdmaxPhases: minimum phase number to apply GdDureeMin in plot_phases (default = 100)
### capacity substructure
- capacity [1x1 struct] with fields:
    - cc_capacity [1xk double]: CC capacity measurement
    - cc_crate [1xk double]: C-Rate of CC capacity measurement
    - cc_time [1xk double]: time of CC capacity measurement
    - cc_duration [1xk double]:duration CC capacity measurement
    - cv_capacity [1xi double]: CV capacity measurement
    - cv_voltage [1xi double]: voltage of CV capacity measurement
    - cv_time [1xi double]: time of CV capacity measurement
    - cv_duration [1xi double]: duration of CV capacity measurement
    - cc_cv_time [1xj double]: time of CCCV capacity measurement
    - cc_cv_capacity [1xj double]: CCCV capacity measurement
    - cc_cv_duration [1xj double]: duration of CV capacity measurement
    - cc_cv_crate [1xj double]:C-Rate of CC part of CCCV capacity measurement
    - ratio_ah [2xj double]: Ah of CC part (1st row) and Ah of CV part (2nd row) of CCCV capacity measurement
    - ratio_duration [2xj double]: duration of CC part (1st row) and duration of CV part (2nd row) of CV capacity measurement
### pseudo_ocv substructure
- pseudo_ocv [1xr struct]:
    - ocv [sx1 double]: OCV vector
    - dod [sx1 double]: DoD vector (Ah)
    - polarization [sx1 double]: polarization vector (u_charge - u_discharge)
    - efficiency [sx1 double]: efficiency (u_discharge / u_charge)
    - u_charge [sx1 double]: voltage during charging half cycle
    - u_discharge [sx1 double]: voltage during discharging half cycle
    - crate [1x1 double]: cycle C-rate
    - time [1x1 double]: instant of measuremament (cycle final time in seconds from 1/1/2000 00:00)
### ocv_points substructure
- ocv_by_points [1x1 struct]:
    - ocv [tx1 double]: OCV vector
    - dod [tx1 double]: DoD vector (Ah)
    - sign [tx1 double]: +1 if rest after partial charge, -1 if rest after partial discharge
    - time [tx1 double]: time of measuremament (rest final time in seconds from 1/1/2000 00:00)
### resistance substructure
- resistance [1x1 struct]:
    - R [1xv double]: resistance (Ohm)
    - dod [1xv double]: DoD (Ah)
    - crate [1xv double]: pulse C-Rate (p.u.)
    - time [1xv double]: time of measuremament (pulse initial time in seconds from 1/1/2000 00:00)
    - delta_time [1xv double]: delta time from initial pulse to calculate resistance
### impedance substructure
#### ident_cpe (R+CPE)
- impedance [1x1 struct]:
    - topology [1xg char]:  'R0 + CPE'
    - q [1xw double]: q parameter of CPE (Ohm^-1)
    - alpha [1xw double]: alpha paramter of CPE (n.u.)
    - r0 [1xw double]: resistance (Ohm)
    - dod [1xw double]: DoD (Ah)
    - crate [1xw double]: pulse C-Rate (p.u.)
    - time [1xw double]: time of measuremament (pulse initial time in seconds from 1/1/2000 00:00)
#### iden_rrc (R+RC+RC)
- impedance [1x1 struct]:
    - topology [1xg char]:  'R0 + R1C1 + R2C2'
    - r0 [1xw double]: series resistance (Ohm)
    - r1 [1xw double]: first loop resistance (Ohm)
    - c1 [1xw double]: first loop capacitance (F)
    - r2 [1xw double]: second loop resistance (Ohm)
    - c2 [1xw double]: second loop capacitance (F)
    - dod [1xw double]: DoD (Ah)
    - crate [1xw double]: pulse C-Rate (p.u.)
    - time [1xw double]: time of measuremament (pulse initial time in seconds from 1/1/2000 00:00)
### ica substructure
- ica [1xy struct]:
    - dqdu [zx1 double]: derivative of capacity over voltage (Ah/V)
    - dudq [zx1 double]: derivative of voltage over capacity (V/Ah)
    - q [zx1 double]: filtered cell capacity vector (Ah)
    - u [zx1 double]: filtered cell voltage (V)
    - crate [1x1 double]:half cycle C-Rate (p.u.)
    - time [1x1 double]: time of measuremament (final half cycle time in seconds from 1/1/2000 00:00)


## XML structure specification for DATTES
XML files must be VEHLIB compatible (pass verifFomatXML4Vehlib function).

Additionnaly, tables in this xml must contain the following variables:
- tabs: time in seconds from 1/1/200 00:00 or test time in seconds starting at 0.
- 'Uname' given in configuration: cell voltage measurement (V)
- I: current measurement (A)
- mode: cycler working mode (1=CC, 2=CV, 3=rest, 4=EIS, 5=profile)
- 'Tname' given in configuration: cell temperature measurement (degC)

Additionnaly for EIS measurments, the following variables must exist:
- freq: frequency (Hz)
- ReZ: real part of impedance (Ohm)
- ImZ: imaginary part of impedance (Ohm)
- freq: frequency (Hz)

