function changeLine(ha,LineWidth,MarkerSize)
% function changeLine(LineWidth,MarkerSize)

h = findobj(ha,'type','line');
for ind = 1:length(h)
    set(h(ind),'LineWidth',LineWidth)
    set(h(ind),'MarkerSize',MarkerSize)
end
h = findobj(ha,'type','patch');%for scatter plots
for ind = 1:length(h)
    set(h(ind),'MarkerSize',MarkerSize)
end

end