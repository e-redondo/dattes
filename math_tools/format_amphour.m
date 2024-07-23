function [ah, ah_dis, ah_cha] = format_amphour(Ah_dis, Ah_cha)
%format_amphour - set amphour counter following DATTES conventions
%
% Charged and discharged amp-hours are cumulative, some cyclers set them to
% zero at each step. Discharged amp-hours are negavtive by convention in
% DATTES. amp-hours
%
% Usage :
% [ah, ah_dis, ah_cha] = format_amphour(Ah_dis, Ah_cha)
% Inputs: 
% Ah_dis ([nx1] double): discharged amp-hours
% Ah_cha ([nx1] double): charged Amp hours
% Output:
% ah ([nx1] double): cumulative amp-hours, difference between charged and
% discharged amp-hours
% ah_dis ([nx1] double): cumulative discharged amp-hours
% ah_cha ([nx1] double): cumulative charged amp-hours
%
% See also calcul_soc
%
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.


%detect Ah_dis and Ah_cha sign, change everyone to positive
[~,ind_max] = max(abs(Ah_dis));
if Ah_dis(ind_max)<0
    Ah_dis = -Ah_dis; 
end

[~,ind_max] = max(abs(Ah_cha));
if Ah_cha(ind_max)<0
    Ah_cha = -Ah_cha;
end

%detect if Ah_dis and Ah_cha are reseted at step changes
% in DATTES we need allways incresing vectors
I_dis = diff(Ah_dis);
I_dis(I_dis<0)=0;
ah_dis = -cumsum(I_dis); %negative by convention in DATTES

I_cha = diff(Ah_cha);
I_cha(I_cha<0)=0;
ah_cha = cumsum(I_cha);

ah = ah_cha + ah_dis;
end