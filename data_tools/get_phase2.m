function [tp,varargout] = get_phase2(phases,t_be_af,t,varargin)
%get_phase2 extract vectors for given phases
% [tp,Up,Ip,mp...] = get_phase2(phases,t_be_af,t,U,I,m...) with 'phases' 
% from decompose_bench and vectors of type t,U,I,m,... from extract_bench,
% tp,Up,Ip,mp... are the pieces of vectors corresponding to time during
% phase (from phase.t_ini to phase.t_fin). In a different manner from
% get_phase, get_phase2 takes t_be_af (1x2 double), t_be_af(1) is the time 
%before given phase and t_be_af(2) is the time after the phase.
%
% Exemple: [tp,Up,Ip] = get_phase2(phases(3:5),[30 45],t,U,I)
% takes 30 seconds before beginning of phase(3) and 45 seconds after the
% end of phase(5).
%
% See also get_phase, decompose_bench, extract_bench

%0.- gestion d'erreurs:
%0.1.- initialisation des sorties
tp = [];
varargout = cell(1,nargout);
%0.2.- entrees: nargin min 2, nargin doit etre egal a nargout+1
if nargin<3
    fprintf('get_phase2: ERREUR, nargin min=2\n');
    return;
end
if nargin~=nargout+2
    fprintf('get_phase2: ERREUR, nargin doit etre nargout + 2\n');
    return;
end
%0.3.- phase doit etre struct 
if ~isstruct(phases)
    fprintf('get_phase2: ERREUR, phase doit etre struct\n');
    return;
end
%0.4.-t_be_af doit être double de taille 1x2
if ~isa(t_be_af,'double') && length(t_be_af)~=2
    fprintf('get_phase2: ERREUR, t_be_af doit être double de taille deux\n');
    return;
end
%0.5.- phase doit avoir les champs 't_ini' et 't_fin'
if ~isfield(phases,'t_ini') || ~isfield(phases,'t_fin')
    fprintf('get_phase2: ERREUR, phases doit avoir des champs t_ini et t_fin\n');
    return;
end
%0.6.- t doit etre vecteur double
if ~isa(t,'double')
    fprintf('get_phase2: ERREUR, le vecteur temps doit etre un double\n');
    return;
end
%0.7.-varargin doivent etre des vecteurs de la meme taille que 't'
for ind = 1:length(varargin)
    if ~isequal(size(varargin{ind}),size(t))
        fprintf('get_phase2: ERREUR, dans les entrees tous les vecteurs n''ont pas a meme taille\n');
        return;
    end
end

indices = t>=phases(1).t_ini-t_be_af(1) & t<=phases(end).t_fin+t_be_af(2);
tp = t(indices);
varargout = cellfun(@(x) x(indices),varargin,'uniformoutput',false);

end