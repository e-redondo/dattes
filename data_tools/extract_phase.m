function [tp,varargout] = extract_phase(phase,t,varargin)
% extract_phase extract vectors for given phase
%
% Usage:
% [tp,varargout] = extract_phase(phase,t,varargin)
%
% Inputs:
% - phase (1x1 struct): phase struct from split_phases
% - t (nx1 double): time vector from extract_profiles
% - varargin
%
% Outputs:
% - tp (px1 double): subvector corresponding to time at the specific phase
% - varargout
%
% See also extract_phase2, split_phases, extract_profiles 
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

%% 0.- check inputs:
%0.1.- initialisation des sorties
tp = [];
varargout = cell(1,nargout);
%0.2.- entrees: nargin min 2, nargin doit etre egal a nargout+1
if nargin<2
    fprintf('extract_phase: ERREUR, nargin min=2\n');
    return;
end
if nargin~=nargout+1
    fprintf('extract_phase: ERREUR, nargin doit etre nargout + 1\n');
    return;
end
%0.3.- phase doit etre struct de taille 1
if ~isstruct(phase) || length(phase)~=1
    fprintf('extract_phase: ERREUR, phase doit etre struct de taille 1\n');
    return;
end
%0.4.- phase doit avoir les champs 't_ini' et 't_fin'
if ~isfield(phase,'t_ini') || ~isfield(phase,'t_fin')
    fprintf('extract_phase: ERREUR, phase doit avoir des champs t_ini et t_fin\n');
    return;
end
%0.5.- t doit etre vecteur double
if ~isa(t,'double')
    fprintf('extract_phase: ERREUR, le vecteur temps doit etre un double\n');
    return;
end
%0.6.-varargin doivent etre des vecteurs de la meme taille que 't'
for ind = 1:length(varargin)
    if ~isequal(size(varargin{ind}),size(t))
        fprintf('extract_phase: ERREUR, dans les entrees tous les vecteurs n''ont pas a meme taille\n');
        return;
    end
end

indices = t>=phase.t_ini & t<=phase.t_fin;
tp = t(indices);
varargout = cellfun(@(x) x(indices),varargin,'uniformoutput',false);

end