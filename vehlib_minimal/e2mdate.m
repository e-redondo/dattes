function Amat = e2mdate(Aedu)
% Eduardo serial date number to MATLAB serial date number
Amat = Aedu/86400 + datenum('Jan 1, 2000');
end