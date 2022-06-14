function [ocv_by_points] = ident_ocv_by_points(t,U,DoDAh,m,config,phases,options)
%ident_ocv_by_points OCV by points identification (rests after partial
%charges/discharges)
%
% [ocv_by_points] = ident_ocv_by_points(t,U,DoDAh,m,config,phases,options)
% Read the config and phases structure and performe several calculations
% regarding OCV by points .  Results are returned in the structure ocv_by_points
%
% Usage:
%[ocv_by_points] = ident_ocv_by_points(t,U,DoDAh,m,config,phases,options)
% Inputs:
% - t,U,DoDAh,m [(nx1) double]: vectors from extract_profiles
% - config [(1x1) struct]: config struct from configurator
% - phases [(mx1) struct] phases from split_phases
% - options: [string] execution options
%    - 'v' = verbose
%    - 'g' = graphics
% Outputs:
% - ocv_by_points [(1x1) struct] with fields:
%     - ocv [(px1) double]: ocv measurements
%     - dod [(px1) double]: depth of discharge
%     - sign [(px1) double]: current sign before rest
%     - time [(px1) double]: time of measurement
%
% See also dattes, ident_pseudo_ocv
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.%

if ~exist('options','var')
    options = '';
end
if ismember('v',options)
    fprintf('ident_ocv_by_points:...');
end

ocv_by_points = struct([]);

time =[];
ocv =[];
dod =[];

%% check inputs:
if nargin<6 || nargin>7
    fprintf('ident_ocv_by_points: wrong number of parameters, found %d\n',nargin);
    return;
end
if ~isstruct(phases) || ~isstruct(config) || ~ischar(options)...
        || ~isnumeric(t) || ~isnumeric(U)|| ~isnumeric(DoDAh) || ~isnumeric(m)
    fprintf('ident_ocv_by_points: wrong type of parameters\n');
    return;
end
if ~isfield(config,'ocv_points')
    fprintf('ident_ocv_by_points: incomplete structure config, redo configurator: dattes(''cs'')\n');
    return;
end
if ~isfield(config.ocv_points,'pOCVr')
    fprintf('ident_ocv_by_points: incomplete structure config, redo configurator: dattes(''cs'')\n');
    return;
end


phases_ocv = phases(config.ocv_points.pOCVr);
ip_avant = [config.ocv_points.pOCVr(2:end) false];
ip_avav = [config.ocv_points.pOCVr(3:end) false false];
phases_avant = phases(ip_avant);
phases_avav = phases(ip_avav);


if length(phases_avant)<length(phases_ocv)
    fprintf('ident_ocv_by_points:error\n');
end
for ind = 1:length(phases_ocv)
    [tp,Up,DoDAhp] = extract_phase(phases_ocv(ind),t,U,DoDAh);
    
    time(ind) = tp(end);
    ocv(ind) = Up(end);%TODO: extrapolation, calcul de la relaxation, etc.
    dod(ind) = DoDAhp(end);
    signe(ind) = sign(phases_avant(ind).Iavg);
end
%filter points with delta DOD > delta dod max:
%TODO: Either do it in configurator2, either let it possible as option here
%TODO: (bug) not working if phase(2) in phases_ocv, try filtering by DoDp? 
% ddod = ([phases_avant.capacity] + [phases_avav.capacity])/config.test.capacity;
% If = abs(ddod)<config.dodmaxOCVr & abs(ddod)>config.dodminOCVr;
If = true(size(time));

time = time(If);
ocv = ocv(If);
dod = dod(If);
signe = signe(If);

ocv_by_points(1).ocv = ocv;
ocv_by_points.dod = dod;
ocv_by_points.sign = signe;
ocv_by_points.time = time;

if ismember('v',options)
    fprintf('OK\n');
end
if ismember('g',options)
    plotOCVp(t,U,DoDAh, time, ocv, dod, signe);
end

end
