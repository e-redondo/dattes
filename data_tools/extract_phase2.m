function [date_time_p,varargout] = extract_phase2(phases,t_be_af,date_time,varargin)
% extract_phase2 extract vectors for given phases with additional
% parameters
%
% Usage:
% [date_time_p,Up,Ip,mp...] = extract_phase2(phases,t_be_af,date_time,U,I,m...)
%
% Inputs:
% - phases (mx1 struct): phase struct array from split_phases
% - t_be_af (1x2 double): time before and after
%     - t_be_af(1): seconds before phases(1).datetime_ini to add to outputs
%     - t_be_af(2): seconds after phases(end).datetime_ini to add to outputs
% - date_time, U, I, m ... (nx1 double): vectors from extract_profiles
%
% Outputs:
% - date_time_p, Up, Ip, mp ... (px1 double): subvectors corresponding to phase
%
% Example: [tp,Up,Ip] = extract_phase2(phases(3:5),[30 45],t,U,I)
% takes 30 seconds before beginning of phase(3) and 45 seconds after the
% end of phase(5).
%
% See also extract_phase, split_phases, extract_profiles
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

%0.- gestion d'erreurs:
%0.1.- initialisation des sorties
date_time_p = [];
varargout = cell(1,nargout);
%0.2.- entrees: nargin min 2, nargin doit etre egal a nargout+1
if nargin<3
    fprintf('extract_phase2: ERREUR, nargin min=2\n');
    return;
end
if nargin~=nargout+2
    fprintf('extract_phase2: ERREUR, nargin doit etre nargout + 2\n');
    return;
end
%0.3.- phase doit etre struct 
if ~isstruct(phases)
    fprintf('extract_phase2: ERREUR, phase doit etre struct\n');
    return;
end
%0.4.-t_be_af doit être double de taille 1x2
if ~isa(t_be_af,'double') && length(t_be_af)~=2
    fprintf('extract_phase2: ERREUR, t_be_af doit être double de taille deux\n');
    return;
end
%0.5.- phase doit avoir les champs 'datetime_ini' et 'datetime_fin'
if ~isfield(phases,'datetime_ini') || ~isfield(phases,'datetime_fin')
    fprintf('extract_phase2: ERREUR, phases doit avoir des champs datetime_ini et datetime_fin\n');
    return;
end
%0.6.- t doit etre vecteur double
if ~isa(date_time,'double')
    fprintf('extract_phase2: ERREUR, le vecteur temps doit etre un double\n');
    return;
end
%0.7.-varargin doivent etre des vecteurs de la meme taille que 't'
for ind = 1:length(varargin)
    if ~isequal(size(varargin{ind}),size(date_time))
        fprintf('extract_phase2: ERREUR, dans les entrees tous les vecteurs n''ont pas a meme taille\n');
        return;
    end
end

indices = date_time>=phases(1).datetime_ini-t_be_af(1) & date_time<=phases(end).datetime_fin+t_be_af(2);
date_time_p = date_time(indices);
varargout = cellfun(@(x) x(indices),varargin,'uniformoutput',false);

end