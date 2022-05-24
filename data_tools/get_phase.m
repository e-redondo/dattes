function [tp,varargout] = get_phase(phase,t,varargin)
%get_phase extrait le vecteurs de la phase donnee
% [tp,Up,Ip,mp...] = get_phase(phase,t,U,I,m...) avec 'phases' issu de
% decoupePhases et les vecteurs du type t,U,I,m,... ,  tp,Up,Ip,mp... sont
% les morceaux des vecteurs entre debut et fin de la phase.
%
% See also decoupeBanc, modeBanc, extractBanc

%0.- gestion d'erreurs:
%0.1.- initialisation des sorties
tp = [];
varargout = cell(1,nargout);
%0.2.- entrees: nargin min 2, nargin doit etre egal a nargout+1
if nargin<2
    fprintf('get_phase: ERREUR, nargin min=2\n');
    return;
end
if nargin~=nargout+1
    fprintf('get_phase: ERREUR, nargin doit etre nargout + 1\n');
    return;
end
%0.3.- phase doit etre struct de taille 1
if ~isstruct(phase) || length(phase)~=1
    fprintf('get_phase: ERREUR, phase doit etre struct de taille 1\n');
    return;
end
%0.4.- phase doit avoir les champs 't_ini' et 't_fin'
if ~isfield(phase,'t_ini') || ~isfield(phase,'t_fin')
    fprintf('get_phase: ERREUR, phase doit avoir des champs t_ini et t_fin\n');
    return;
end
%0.5.- t doit etre vecteur double
if ~isa(t,'double')
    fprintf('get_phase: ERREUR, le vecteur temps doit etre un double\n');
    return;
end
%0.6.-varargin doivent etre des vecteurs de la meme taille que 't'
for ind = 1:length(varargin)
    if ~isequal(size(varargin{ind}),size(t))
        fprintf('get_phase: ERREUR, dans les entrees tous les vecteurs n''ont pas a meme taille\n');
        return;
    end
end

indices = t>=phase.t_ini & t<=phase.t_fin;
tp = t(indices);
varargout = cellfun(@(x) x(indices),varargin,'uniformoutput',false);

end