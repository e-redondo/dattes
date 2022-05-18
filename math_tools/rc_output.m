 function U = rc_output(t,I,R,C)
%rc_output simule la reponse d'un RC a un profil de courant quelconque
%comme s'il s'agissait d'une superposition de pulses de courant constant.
%
% U = reponseRC(t,I,R,C)
% t,I [nx1 double]:vecteurs temps et courant
% R, C [1x1 double]: parametres du RC (resistance, capacité)
%
% Utilise l'expression:
%
% u(t) = R*I*(exp(-t/(R*C))-1)
%
% calcule par mes soins a partir de:
% https://fr.wikipedia.org/wiki/équation_différentielle_linéaire_d'ordre_un
%
% See also  reponseCPE

if ~isnumeric(R) ||  ~isnumeric(C) ||  ~isnumeric(t) ||  ~isnumeric(I) 
    U = [];
    fprintf('reponseRC:ERREUR, toutes les entrees doivent etre numeriques\n');
    return
end
if numel(R) ~= 1 || numel(C) ~= 1 
    U = [];
    fprintf('reponseRC:ERREUR, Q et alpha doivent etre scalaires (1x1)\n');
    return
end
if ~isequal(size(t),size(I)) || size(t,1)~=length(t)
    U = [];
    fprintf('reponseRC:ERREUR; t et I doivent etre vecteurs de la meme taille (nx1)\n');
    return
end
%R [1x1]
R = R(1);
%C [1x1]
C = C(1);


dI = [I(1); diff(I)];
indices = find(dI);

U = zeros(size(t));
for ind = 1:length(indices)
    xe = echelon(t,dI(indices(ind)),t(indices(ind)));
    xtd =(t-t(indices(ind)));xtd(xtd<0)=0;
%     U = U + (1/Q)*xe.*xtd/gamma(alpha+1);
%     U = R*xe.*(exp(xtd/(R*C))-1);
    U = U+R*xe.*(1-exp(-(xtd)/(R*C)));
    if isnan(U(1))
        fprintf('ICI\n');
    end
end
end

function x = echelon(t,I,td)
    x = zeros(size(t));
    x(t>=td)=I;
end


