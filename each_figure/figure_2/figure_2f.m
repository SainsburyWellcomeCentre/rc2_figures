function figure_2f(data, h_ax1, h_ax2, h_ax3)

ctl = RC2Analysis();

probe_ids           = ctl.get_probe_ids('mismatch_nov20', 'mismatch_jul21');
trial_group_labels  = {'RV_gain_up'};
order_by_label      = {'RVT_gain_up'};

fs                  = 10000;

baseline_t          = [-0.4, 0];

% display
padding             = [-1, 1];
fr_limits           = [-8, 8];



%% extract and analyze data
fr_mean             = [];
response_magnitude  = [];

for ii = 1 : length(probe_ids)
    
    this_data   = get_data_for_probe_id(data, probe_ids{ii});
    clusters    = this_data.VISp_clusters();

    for jj = 1 : length(clusters)
        
        [fr_traces, common_t]       = this_data.get_fr_responses(clusters(jj).id, trial_group_labels, 'mismatch', padding, fs);
        fr_mean(end+1, :)           = mean(fr_traces, 1);
        response_magnitude(end+1)   = this_data.get_mismatch_response(clusters(jj).id, order_by_label);
    end
end

n_clusters = size(fr_mean, 1);

% reorder heatmap
baseline_idx            = common_t >= baseline_t(1) & common_t < baseline_t(2);
[~, cluster_idx_sorted] = sort(response_magnitude, 'ascend');
heatmap                 = fr_mean(cluster_idx_sorted, :);

% subtract baseline period
heatmap                 = bsxfun(@minus, heatmap, mean(heatmap(:, baseline_idx), 2));

% compute population average and sem
population_average      = mean(heatmap, 1);
population_sem          = std(heatmap, [], 1) / sqrt(n_clusters);



%% plot
cols = get_colours();



h_im  = imagesc(h_ax2, heatmap);
colormap(h_ax2, cols('red2blue_map'));

set(h_im, 'xdata', common_t);
set(h_ax2, 'clim', fr_limits, ...
           'xlim', padding, ...
           'ylim', [0.5, n_clusters+0.5], ...
           'xcolor', 'none', ...
           'ycolor', 'none');

text(h_ax2, padding(1)-0.2, n_clusters, sprintf('%i', 1), ...
    'horizontalalignment', 'right', ...
    'verticalalignment', 'middle', ...
    'fontsize', 8);

text(h_ax2, padding(1)-0.2, 1, sprintf('%i', n_clusters), ...
    'horizontalalignment', 'right', ...
    'verticalalignment', 'middle', ...
    'fontsize', 8);

text(h_ax2, padding(1)-0.3, (n_clusters + 1) / 2, 'cell #', ...
    'horizontalalignment', 'center', ...
    'verticalalignment', 'bottom', ...
    'fontsize', 8, ...
    'rotation', 90);

text(h_ax2, padding(2), n_clusters + 3, 'all cells', ...
    'horizontalalignment', 'right', ...
    'verticalalignment', 'bottom', ...
    'fontsize', 6);

% colorbar
axis_position = get(h_ax2, 'position');
axis_width = axis_position(3);
axis_height = axis_position(4);

colorbar_width = (1.4/28.5) * axis_width;
colorbar_height = axis_height;

colorbar_position = [(axis_position(1) + axis_width) + colorbar_width, ...
                     (axis_position(2) + axis_height) - colorbar_height, ...
                     colorbar_width, colorbar_height];
                     
h_ax_colorbar = axes();

set(h_ax_colorbar, ...
    'Color',                    'w', ...
    'XColor',                   'k', ...
    'YColor',                   'k', ...
    'Units',                    'normalized', ...
    'PositionConstraint',       'innerposition', ...
    'InnerPosition',            colorbar_position, ...
    'PlotBoxAspectRatioMode',   'auto');
hold on;

dummy_map = repmat(linspace(0, 1, 64)', 1, 3);
imagesc(dummy_map, [0, 1]);
colormap(h_ax_colorbar, cols('red2blue_map'));

set(h_ax_colorbar, ...
    'xlim', [0.5, 3.5], ...
    'ylim', [0.5, 64.5]);

axis off;

text(h_ax_colorbar, 3.5, -1, '<-8', ...
    'color', 'k', ...
    'horizontalalignment', 'center', ...
    'verticalalignment', 'top', ...
    'fontsize', 8);

text(h_ax_colorbar, 3.5, 65, '>8', ...
    'color', 'k', ...
    'horizontalalignment', 'center', ...
    'verticalalignment', 'bottom', ...
    'fontsize', 8);

text(h_ax_colorbar, 3.6, 65/2, '\DeltaFR (Hz)', ...
    'color', 'k', ...
    'horizontalalignment', 'center', ...
    'verticalalignment', 'bottom', ...
    'fontsize', 8, 'rotation', 270);

% lower axis
plot(h_ax3, common_t, population_average, 'color', 'k', 'linewidth', 0.75);
plot(h_ax3, common_t, population_average+population_sem, 'color', [0.5, 0.5, 0.5], 'linewidth', 0.25);
plot(h_ax3, common_t, population_average-population_sem, 'color', [0.5, 0.5, 0.5], 'linewidth', 0.25);
set(h_ax3, 'ylim', [-2, 4], 'ytick', -2:2:4, 'yticklabel', {'', '0', '', '4'}, 'xlim', padding, 'xcolor', 'none', ...
    'clipping', 'off', 'fontsize', 8);
ylabel(h_ax3, '\DeltaFR (Hz)', 'fontsize', 8);

line(h_ax3, [padding(2)-0.5, padding(2)], [-2, -2], 'color', 'k', 'linewidth', 0.5);
text(h_ax3, padding(2)-0.25, -2.2, '0.5s', 'color', 'k', 'horizontalalignment', 'center', 'verticalalignment', 'top', ...
    'fontsize', 8);


% slip region patch
patch(h_ax1, 'xdata', [0, 0.25, 0.25, 0], 'ydata', [0, 0, 1, 1], 'facecolor', [0, 0, 0], 'edgecolor', [0, 0, 0], 'facealpha', 0.1, 'edgealpha', 0.1);
set(h_ax1, ...
    'xlim', padding, ...
    'color', 'none');
text(h_ax1, 0.125, 1.01, 'slip', 'color', 'k', 'fontsize', 6, 'horizontalalignment', 'center', 'verticalalignment', 'top');
axis(h_ax1, 'off');