function figure_s3c(data, h_ax)

ctl = RC2Analysis();

probe_ids           = ctl.get_probe_ids('visual_flow', 'mismatch_nov20', 'mismatch_jul21');
trial_type_labels   = {'RVT', 'RVT_gain_up'};

fs                  = 10000;
baseline_t          = [-0.4, 0];
response_t          = [0, 0.4];

% display
padding             = [-1, 1];
fr_limits           = [-8, 8];

threshold_ms        = 0.45;

bouts_options.min_bout_duration   = 2;
bouts_options.include_200ms       = true;


%% extract and analyze data
fr_mean = [];
spike_class = [];

for ii = 1 : length(probe_ids)
    
    this_data = get_data_for_probe_id(data, probe_ids{ii});
    clusters = this_data.VISp_clusters();

    for jj = 1 : length(clusters)
        
        [fr_traces, common_t] = this_data.get_fr_responses(clusters(jj).id, trial_type_labels, 'motion', padding, fs, bouts_options);
        fr_mean(end+1, :) = mean(fr_traces, 1);
        spike_class(end+1) = clusters(jj).duration < threshold_ms;
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

key_size = range(padding) * (0.1/2);


%% plot
cols        = get_colours();

h_im        = imagesc(h_ax, heatmap);
set(h_im, 'xdata', common_t);

line(h_ax, [0, 0], [0.5, n_clusters+0.5], 'linestyle', '--', 'color', 'k');
colormap(h_ax, cols('red2blue_map'));

set(h_ax, 'clim', fr_limits, 'ytick', [1, n_clusters], 'xlim', padding + [-key_size, 0], ...
          'ylim', [0.5, n_clusters+0.5], 'xcolor', 'none', 'ycolor', 'none', 'yticklabel', [n_clusters, 1]);

for i = 1 : n_clusters
    
    if spike_class(i)
        col = [0.5, 0.5, 0.5];
    else
        col = [0, 0, 0];
    end
    
    fill(h_ax, padding(1)+[-key_size, 0, 0, -key_size], i + [-0.5, -0.5, 0.5, 0.5], col, 'edgecolor', 'none');
end

text_x_offset = padding(1) - range(padding) * (0.2/2);
text_y_offset = n_clusters + (3/117)*n_clusters;

text(h_ax, text_x_offset, n_clusters, sprintf('%i', 1), 'horizontalalignment', 'right', 'verticalalignment', 'middle', ...
    'fontsize', 8);
text(h_ax, text_x_offset, 1, sprintf('%i', n_clusters), 'horizontalalignment', 'right', 'verticalalignment', 'middle', ...
    'fontsize', 8);
text(h_ax, text_x_offset, (n_clusters + 1) / 2, 'cell #', 'horizontalalignment', 'center', 'verticalalignment', 'bottom', ...
    'fontsize', 8, 'rotation', 90);
text(h_ax, 0, text_y_offset, {'locomotion', 'onset'}, 'horizontalalignment', 'center', 'verticalalignment', 'bottom', ...
    'fontsize', 6);
text(h_ax, padding(1), text_y_offset, {'\color[rgb]{0.5, 0.5, 0.5}narrow-spike', '\color[rgb]{0, 0, 0}wide-spike'}, 'horizontalalignment', 'center', 'verticalalignment', 'bottom', ...
    'fontsize', 6);


% colorbar
axis_position = get(h_ax, 'position');
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

