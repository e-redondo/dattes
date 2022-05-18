function U = rrc_output(t,I,Rs,R,C)

U = I.*Rs;
for ind = 1:length(R)
Urc = reponseRC(t,I,R(ind),C(ind));
U = U+Urc;
end
end