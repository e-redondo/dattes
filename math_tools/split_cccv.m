function [ind_cccv] = split_cccv(t,I,U,options)
%split_cccv Find the limit between CC and CV phases
%
% Usage: 
%  [ind_cccv] = split_cccv(t,I) % normal operation
%  [ind_cccv] = split_cccv(t,I, U,'g') % plot results
%
% Inputs:
% - t [nx1 double]: time
% - I [nx1 double]: current
% - U [nx1 double]: voltage
%
% Output:
% - ind_cccv [1x1 int]: index for point of end of CC
%
% See also which_mode
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

if ~exist('options','var')
    options = '';
end
dt = 1;%delta t for vector sampling
T = 1;% delta t for moving derivative

%constant sampling of one second
ti = (t(1):dt:t(end))';
Ii = interp1(t,I,ti);
didt = moving_derivative(ti,Ii,T);

%to avoid initial slope of current
if mean(I)>0
    %if charge we are searching for negative values
    %put zeros in all positives
    didt(didt>0)=0;
else
    %if discharge we are searching for negative values
    %put zero in all negatives
    didt(didt<0)=0;
end
[~,is] = max(abs(didt));
%t cccv is where the maximum of didt minus T (delay of moving_derivative)
t_cccv = ti(is)-T;

[~,ind_cccv] = min(abs(t-t_cccv));

if ismember('g',options)
    figure;
    subplot(211),plot(t,I),hold on
    plot(t(ind_cccv),I(ind_cccv),'ro')
    subplot(212),plot(t,U),hold on
    plot(t(ind_cccv),U(ind_cccv),'ro')
end
end