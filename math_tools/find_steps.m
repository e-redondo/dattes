function Step = find_steps(t,I,U, p_cut,options)
% find_steps build a vector with Step number based on current, power or
% voltage changes.
%
% This function computes derivative of current (or voltage or power) versus
% time, then consider greater values of derivative (fast changes) as Step change.
%
% Usage
% Step = find_steps(t,I,U, p_cut,options)
% Inputs:
% - t (nx1 double): time vector (seconds)
% - I (nx1 double): current vector (A)
% - U (nx1 double): voltage vector (V)
% - p_cut (1x1 double): quantile for cut (0<p_cut<1), e.g. 0.01 takes 
% 1% top greater changes, 0.001 takes 0.1% top greater changes.
% - options (string): containing the following characters
%   - 'v': verbose, tells what it does (default: no verbose)
%   - 'g': graphics, tells what it does (default: no graphics)
%   - 'I': cut by current changes (default)
%   - 'U': cut by voltage changes
%   - 'P': cut by power changes
%
% Outputs:
% - xml (struct): structure with XML format 4 VEHLIB
%
% See also import_bitrode
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab:
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

if nargin<4
    error('find_steps: not enough input parameters');
end

if ~isnumeric(t) ||~isnumeric(I) ||~isnumeric(U) ||~isnumeric(p_cut)
    error('find_steps: t,I,U,p_cut must be numeric');
end

if ~isvector(t) || ~isequal(size(t),size(I)) || ~isequal(size(t),size(U))
    error('find_steps: t,I,U must be vector of same length');
end
if ~isscalar(p_cut)
    error('find_steps: p_cut must be scalar');
end

if p_cut<=0 || p_cut >=1
    error('find_steps: p_cut must be positive and lower than 1');
end

if ~exist('options','var')
    options = '';%default: cut by current changes
end

if ~ischar(options)
    error('find_steps: options must be char');
end


if ~ismember('I',options) && ~ismember('U',options) && ~ismember('P',options)
    options = [options 'I'];%default: cut by current changes
end
verbose = ismember('v',options);
graphics = ismember('g',options);

if ismember('I',options)
    %cut by current changes
    x_cuts = find_cuts(t,I,p_cut);
elseif ismember('U',options)
    %cut by voltage changes
    x_cuts = find_cuts(t,U,p_cut);
elseif ismember('P',options)
    %cut by power changes
    x_cuts = find_cuts(t,I.*U,p_cut);
else
    fprintf('find_steps:No cut mode found (I, U or P)\n');
    Step = [];
    return
end

Step = cumsum(x_cuts);

if verbose
    fprintf('Found %d Steps\n',max(Step));
end

if graphics
    show_result(t,I,U,x_cuts);
end

end

function x_cuts = find_cuts(t,x,p_cut)

dxdt = [0; diff(x)./diff(t)];
dxdts = sort(abs(dxdt),'descend');

dxdt_lim = dxdts(round(length(dxdt)*p_cut));

x_cuts = abs(dxdt)>dxdt_lim;
end

function show_result(t,I,U,x_cuts)

P = I.*U;

dIdt = [0; diff(I)./diff(t)];
dUdt = [0; diff(U)./diff(t)];
dPdt = [0; diff(P)./diff(t)];


figure;
subplot(321), plot(t,I),hold on
subplot(323), plot(t,U),hold on
subplot(325), plot(t,P),hold on

subplot(322), plot(t,dIdt),hold on
subplot(324), plot(t,dUdt),hold on
subplot(326), plot(t,dPdt),hold on


subplot(321), plot(t(x_cuts),I(x_cuts),'go')
subplot(323), plot(t(x_cuts),U(x_cuts),'go')
subplot(325), plot(t(x_cuts),P(x_cuts),'go')

subplot(322), plot(t(x_cuts),dIdt(x_cuts),'go')
subplot(324), plot(t(x_cuts),dUdt(x_cuts),'go')
subplot(326), plot(t(x_cuts),dPdt(x_cuts),'go')


ha = findobj(gcf,'type','axes');
linkaxes(ha,'x')
end