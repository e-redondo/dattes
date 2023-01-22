function [date_time_p,varargout] = extract_phase(phase,date_time,varargin)
% extract_phase extract vectors for given phase
%
% Usage:
% [date_time_p,varargout] = extract_phase(phase,date_time,varargin)
%
% Inputs:
% - phase (1x1 struct): phase struct from split_phases
% - date_time (nx1 double): datetime vector from extract_profiles
% - varargin (nx1 doubles): other vectors (U, I, m, ...)
%
% Outputs:
% - date_time_p (px1 double): subvector corresponding to datetime at the specific phase
% - varargout (px1 doubles): other subvectors (Up, Ip, mp, ...)
%
% See also extract_phase2, split_phases, extract_profiles 
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

%% 0.- check inputs:
%0.1.- initialisation des sorties
date_time_p = [];
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
%0.4.- phase doit avoir les champs 'datetime_ini' et 'datetime_fin'
if ~isfield(phase,'datetime_ini') || ~isfield(phase,'datetime_fin')
    fprintf('extract_phase: ERREUR, phase doit avoir des champs datetime_ini et datetime_fin\n');
    return;
end
%0.5.- t doit etre vecteur double
if ~isa(date_time,'double')
    fprintf('extract_phase: ERREUR, le vecteur temps doit etre un double\n');
    return;
end
%0.6.-varargin doivent etre des vecteurs de la meme taille que 't'
for ind = 1:length(varargin)
    if ~isequal(size(varargin{ind}),size(date_time))
        fprintf('extract_phase: ERREUR, dans les entrees tous les vecteurs n''ont pas a meme taille\n');
        return;
    end
end

indices = date_time>=phase.datetime_ini & date_time<=phase.datetime_fin;
date_time_p = date_time(indices);
varargout = cellfun(@(x) x(indices),varargin,'uniformoutput',false);

end
