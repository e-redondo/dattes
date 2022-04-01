function Aedu = m2edate(Amat)
% MATLAB serial date number to Eduardo serial date number
Aedu = (Amat - datenum('Jan 1, 2000'))*86400;
end