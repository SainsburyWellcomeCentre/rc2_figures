function u = mi_vs_depth_plot(T2, idx_main, depths, boundaries, h_ax, print_layers)

VariableDefault('print_layers', false);

idx_blue = T2.p < 0.05 & T2.fr_x > T2.fr_y & idx_main;
idx_red = T2.p < 0.05 & T2.fr_x < T2.fr_y & idx_main;
idx_black = T2.p >= 0.05 & idx_main;

mi = (T2.fr_y - T2.fr_x) ./ (T2.fr_y + T2.fr_x);

for i = 1 : size(T2, 1)
    
    r = find(strcmp(T2.cluster_region{i}, boundaries.region));
    d(i) = boundaries.upper(r) - (boundaries.upper(r) - boundaries.lower(r))*depths(i);
end


scatter(mi(idx_blue), d(idx_blue), [], 'b', 'fill');
scatter(mi(idx_red), d(idx_red), [], 'r', 'fill');
scatter(mi(idx_black), d(idx_black), [], 'k', 'fill');

% plot the layer boundaries
for b_i = 1 : length(boundaries.region)
    
    if b_i > 1
        line([-1, 1], boundaries.upper(b_i)*[1, 1], 'color', 'k', 'linestyle', '--');
    end
    line([-1, 1], boundaries.lower(b_i)*[1, 1], 'color', 'k', 'linestyle', '--');
    
    if print_layers
        text(1, sum(boundaries.upper(b_i) + boundaries.lower(b_i))/2, boundaries.region{b_i}, ...
            'horizontalalignment', 'left', 'verticalalignment', 'middle')
    end
end

% index of lower boundary for VISp6b
l6b_i = strcmp('VISp6b', boundaries.region);

% set the y-limits of axis to include bottom of VISp6b
ylim([boundaries.lower(l6b_i), boundaries.upper(1)])

xlabel('MI');

u.ax = h_ax;


