function Aedu = m2edate(Amat)
% MATLAB serial date number to Eduardo serial date number
Aedu = (Amat - datenum('01/01/2000','dd/mm/yyyy'))*86400;
end