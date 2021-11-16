function figure_1c(data, h_ax_upper, h_ax_lower)
%%Figure 1C

ctl                 = RC2Analysis();
probe_ids           = ctl.get_probe_ids('visual_flow', 'mismatch_nov20', 'mismatch_jul21');
trial_type_labels   = {'RVT', 'RVT_gain_up'};
fs                  = 10000;
baseline_t          = [-0.4, 0];
response_t          = [0, 0.4];
padding             = [-1, 1];
fr_limits           = [-8, 8];

bouts_options.min_bout_duration   = 2;
bouts_options.include_200ms       = true;


%% extract and analyze data
fr_mean = [];

for ii = 1 : length(probe_ids)
    
    if isempty(data)
        this_data = ctl.load_formatted_data(probe_ids{ii});
    else
        this_data = get_data_for_probe_id(data, probe_ids{ii});
    end
    
    clusters = this_data.VISp_clusters();

    for jj = 1 : length(clusters)
        
        [fr_traces, common_t] = this_data.get_fr_responses(clusters(jj).id, trial_type_labels, 'motion', padding, fs, bouts_options);
        fr_mean(end+1, :) = mean(fr_traces, 1);
    end
end

n_clusters = size(fr_mean, 1);

% reorder heatmap
baseline_idx = common_t >= baseline_t(1) & common_t < baseline_t(2);
response_idx = common_t >= response_t(1) & common_t < response_t(2);

baseline_fr = mean(fr_mean(:, baseline_idx), 2);
response_fr = mean(fr_mean(:, response_idx), 2);

delta_fr = response_fr - baseline_fr;

[~, cluster_idx_sorted] = sort(delta_fr, 'ascend');

heatmap = fr_mean(cluster_idx_sorted, :);

heatmap = bsxfun(@minus, heatmap, mean(heatmap(:, baseline_idx), 2));

population_average = mean(heatmap, 1);
population_sem = std(heatmap, [], 1) / sqrt(n_clusters);



%% plot
cols = get_colours();

h_im  = imagesc(h_ax_upper, heatmap);
line(h_ax_upper, [0, 0], [0.5, n_clusters+0.5], 'linestyle', '--', 'color', 'k');
colormap(h_ax_upper, cols('red2blue_map'));
set(h_im, 'xdata', common_t);
set(h_ax_upper, 'clim', fr_limits, 'ytick', [1, n_clusters], 'xlim', padding, 'ylim', [0.5, n_clusters+0.5], ...
          'xcolor', 'none', 'ycolor', 'none', 'yticklabel', [n_clusters, 1]);
text(h_ax_upper, padding(1)-0.2, n_clusters, sprintf('%i', 1), 'horizontalalignment', 'right', 'verticalalignment', 'middle', ...
    'fontsize', 8);
text(h_ax_upper, padding(1)-0.2, 1, sprintf('%i', n_clusters), 'horizontalalignment', 'right', 'verticalalignment', 'middle', ...
    'fontsize', 8);
text(h_ax_upper, padding(1)-0.3, (n_clusters + 1) / 2, 'cell #', 'horizontalalignment', 'center', 'verticalalignment', 'bottom', ...
    'fontsize', 8, 'rotation', 90);
text(h_ax_upper, 0, n_clusters + 3, {'locomotion', 'onset'}, 'horizontalalignment', 'center', 'verticalalignment', 'bottom', ...
    'fontsize', 6);
text(h_ax_upper, padding(2), n_clusters + 3, 'all cells', 'horizontalalignment', 'right', 'verticalalignment', 'bottom', ...
    'fontsize', 6);

% colorbar
axis_position = get(h_ax_upper, 'position');
axis_width = axis_position(3);
axis_height = axis_position(4);

colorbar_width = (1.4/28.5) * axis_width;
colorbar_height = (13/38) * axis_height;

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
h_im_colorbar = imagesc(dummy_map, [0, 1]);
colormap(h_ax_colorbar, cols('red2blue_map'));
set(h_ax_colorbar, 'xlim', [0.5, 3.5], 'ylim', [0.5, 64.5])
axis off
text(h_ax_colorbar, 3.5, -1, '<-8', 'color', 'k', 'horizontalalignment', 'center', 'verticalalignment', 'top', ...
    'fontsize', 8);
text(h_ax_colorbar, 3.5, 65, '>8', 'color', 'k', 'horizontalalignment', 'center', 'verticalalignment', 'bottom', ...
    'fontsize', 8);
text(h_ax_colorbar, 3.6, 65/2, '\DeltaFR (Hz)', 'color', 'k', 'horizontalalignment', 'center', 'verticalalignment', 'bottom', ...
    'fontsize', 8, 'rotation', 270);

% lower axis
plot(h_ax_lower, common_t, population_average, 'color', 'k', 'linewidth', 0.75);
plot(h_ax_lower, common_t, population_average+population_sem, 'color', [0.5, 0.5, 0.5], 'linewidth', 0.25);
plot(h_ax_lower, common_t, population_average-population_sem, 'color', [0.5, 0.5, 0.5], 'linewidth', 0.25);
set(h_ax_lower, 'ylim', [-2, 6], 'ytick', -2:2:6, 'yticklabel', {'', '0', '', '', '6'}, 'xlim', padding, 'xcolor', 'none', ...
    'clipping', 'off', 'fontsize', 8);
ylabel(h_ax_lower, '\DeltaFR (Hz)', 'fontsize', 8);

line(h_ax_lower, [0, 0], [-2, 25], 'color', 'k', 'linestyle', '--', 'linewidth', 0.5);
line(h_ax_lower, [padding(2)-0.5, padding(2)], [-2, -2], 'color', 'k', 'linewidth', 0.5);
text(h_ax_lower, padding(2)-0.25, -2.2, '0.5s', 'color', 'k', 'horizontalalignment', 'center', 'verticalalignment', 'top', ...
    'fontsize', 8);

