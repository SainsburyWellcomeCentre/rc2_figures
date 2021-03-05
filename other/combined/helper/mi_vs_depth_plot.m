function u = mi_vs_depth_plot(T2, idx_main, depths, boundaries, h_ax, print_layers, marker_type)
% inputs:
%       In the following N is the number of clusters.
%       T2 - structure with fields:
%               fr_x:  N x 1 vector of mean firing rates in condition 1
%               fr_y:  N x 1 vector of mean firing rates in condition 2
%               p:     N x 1 vector of p-values comapring responses between
%                       condition 1 and 2
%               cluster_region:  N x 1 cell array of regions
%       idx_main - N x 1 logical array of whether to plot the cell
%       depths - N x 1 vector of fractional deptsh (i.e. distance as a
%                   fraction between upper and lower cortical boundaries)
%                   NOTE: THIS NEEDS TO BE CHANGED
%       boundaries - structure with fields
%               region: B x 1 cell array of regions (B regions)
%               upper:  B x 1 vector of upper boundaries for each region
%               lower:  B x 1 vector of lower boundaries for each region
%       h_ax -      1 x 1, axis to plot on
%       print_layers - boolean - whether to print the layers on the figure

VariableDefault('print_layers', false);
VariableDefault('marker_type', 'o');

% which should be which colours
idx_blue = T2.p < 0.05 & T2.fr_x > T2.fr_y & idx_main;
idx_red = T2.p < 0.05 & T2.fr_x < T2.fr_y & idx_main;
idx_black = T2.p >= 0.05 & idx_main;

% modulation index for each cell
mi = (T2.fr_y - T2.fr_x) ./ (T2.fr_y + T2.fr_x);

for i = 1 : size(T2, 1)
    
    r = find(strcmp(T2.cluster_region{i}, boundaries.region));
    d(i) = boundaries.upper(r) - (boundaries.upper(r) - boundaries.lower(r))*depths(i);
end

scatter(mi(idx_black), d(idx_black), 10, 'k', 'fill', marker_type);
scatter(mi(idx_blue), d(idx_blue), 30, 'b', 'fill', marker_type);
scatter(mi(idx_red), d(idx_red), 30, 'r', 'fill', marker_type);

% plot the layer boundaries
for b_i = 1 : length(boundaries.region)
    
    if b_i == 1
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


