function hf = plot_capacity(cc_capacity, cc_crate)
% plot_capacity plot capacity graphs
%
% plot_capacity(cc_capacity, cc_crate)
% Use cc_capacity and cc_crate to plot CC capacity graphs
%
% Usage:
% hf = plot_capacity(cc_capacity, cc_crate)
% Inputs:
%  - cc_capacity: [nx1] Capacity during CC phase in Ah
%  - cc_crate: [nx1] C-rate during CC phase in Ah
% Output:
% - hf [1x1 figure handler]: handler for created figure
%
% See also dattes, dattes_plot, configurator, extract_profiles
%
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.


hf = figure('name','ident capacity');hold on
plot(cc_crate,cc_capacity,'o')
xlabel('Current Rate (C)','interpreter','tex')
ylabel('Capacity (Ah)','interpreter','tex')


%Look for all axis handles and ignore legends
ha = findobj(hf,'type','axes','tag','');
prettyAxes(ha);
changeLine(ha,2,15);

end
