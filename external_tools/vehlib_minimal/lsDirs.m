function dirList = lsDirs(srcdir, toponly)
% lsDirs Recusively list of folders.
%   dirList = lsDirs(srcdir,toponly) will return the subfolder list of
%   srcdir, if toponly == true only first level will be done.
%   dirList = lsDirs(srcdir) will return the subfolder list of srcdir
%   (toponly == false by default)
%   
%   See also: lsDirs, lsEmptyFolders, lsDirsWithFiles
%
%   IFSTTAR/LTE  - E. REDONDO
%   $Revision: 0.1 $  $Created: 2015/08/12, Modified: 2015/08/12$
if nargin==0
    print_usage;
end
if ~exist('toponly','var')
    toponly = false;
end
dirList = lsFiles(srcdir,'',toponly);
I = cellfun(@isdir,dirList);
dirList = dirList(I);
end