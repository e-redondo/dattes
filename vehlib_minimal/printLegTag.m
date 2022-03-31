function [hleg myLineTags] = printLegTag(ha,location,int)
if ~exist('ha','var')
    ha = gca;
end
if ~exist('location','var')
    location = 'best';
end
if ~exist('int','var')
    int = 'latex';
end

if strcmpi(get(ha,'type'),'figure')
    ha = findobj(ha,'Type','axes','tag','');
end
myLineTags = cell(0);
for ind = 1:length(ha)
    myLines = findobj(ha(ind),'Type','line');%get all lines in the given axes
    myLineTags{ind} = get(sort(myLines),'tag');%get each tag of each line (sorted)
    hleg(ind) = legend(ha(ind),myLineTags{ind},'interpreter',int);%make legend
end
% set(hleg,'Interpreter','none');
set(hleg,'location',location);

end