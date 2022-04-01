function fileList = lsFiles(srcdir, extension, toponly, followlnk)
% lsFiles Recusively list of files.
% fileList = lsFiles(srcdir, extension, toponly)
% If extension is not given, only folders will be listeed
% If extension is '*' all files will be listed.
% If extension is ".jpg", only .jpg files will be listed.
% If toponly (optional) is True, only first level will be listed (recursivity OFF).
% TODO: accents in files compatibility
% TODO: empty extension returns folders and files without extension
% parametres:
% - srcdir: [string] nom du repertoire a copier (absolu ou relatif)
% - extension: [optionnel, string] extension des fichiers a copier
% - toponly: [optionnel, bool] si true, ne liste pas les sous repertoires
% valeurs retournees:
% - fileList: [cellstring] liste de fichiers (pathname absolu ou relatif)
% examples:
% (1) fileList = lsFiles('c:\Folder1', '.txt') : liste tous les fichiers txt
% de Folder1
% (2) fileList = lsFiles('c:\Folder1', '*') : liste tous les fichiers
% de Folder1
% (3) fileList = lsFiles('c:\Folder1', '') : liste toute l'arborescence 
% de Folder1 (seulement repertoires)
% (4) fileList = lsFiles('c:\Folder1', '') : Idem de (3)
% (5) fileList = lsFiles('c:\Folder1', '.txt') : liste tous les fichiers txt
% de Folder1 mais pas dans les sous repertoires
% 
%   See also lsDirs, lsFilesDos, lsEmptyFolders, lsDirsWithFiles, cpFiles.
%
%   IFSTTAR/LTE  - E. REDONDO
%   $Revision: 0.1 $  $Created: 2014/04/04, Modified: 2015/08/12$
if nargin==0
    print_usage;
end
if ~exist('extension','var')
    extension = '';
end
if ~exist('toponly','var')
    toponly = false;
end
if ~exist('followlnk','var')
    followlnk = false;
end

D = dir(srcdir);
fileList = cell(0);
for ind = 1:length(D)
    filename = D(ind).name;
    pathname = fullfile(srcdir,filename);
    
    [Folder File Ext] = fileparts(pathname);
    if ~D(ind).isdir
        if strcmpi(extension,Ext) || isequal(extension,'*')
            %             fprintf('%s\n',pathname);
            fileList = [fileList; {pathname}];
        end
        if ispc && followlnk && strcmpi(Ext,'.lnk') % linux naturaly follows symbolic links ...
            target = getTargetFromLink(pathname);
            fileList = [fileList; target];
        end
    else
        if isempty(extension) && filename(1)~='.'
            fileList = [fileList; {pathname}];
        end
        if ~toponly && ~(filename(1)=='.' && filename(end)=='.')
            oldList = lsFiles(pathname, extension);
            fileList = [fileList; oldList];
        end
    end
end
    
