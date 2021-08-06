function figure_2f(data, h_ax1, h_ax2, h_ax3)

recording_ids       = experiment_details('mismatch_nov20');
protocol_types      = 'EncoderOnlyMismatch';
gain_dir            = 'up';

fs                  = 10000;
baseline_t          = [-1, 0];
response_t          = [0, 1];

% display
padding             = [-1, 1];
fr_limits           = [-8, 8];


%% extract and analyze data
n_sample_points     = ceil(range(padding)*fs);
common_t            = linspace(padding(1), padding(2), n_sample_points);

cluster_count       = 0;
fr_mean             = [];


for rec_i = 1 : length(recording_ids)
    rec_i
    this_data = get_data_for_recording_id(data, recording_ids{rec_i});
    
    clusters = this_data.VISp_clusters();
    
    % get all trials for this recording
    if strcmp(recording_ids{rec_i}, 'CAA-1112872_rec1_rec1b_rec2_rec3')
        all_trials = [this_data.data.sessions(1).trials, this_data.data.sessions(2).trials];
    else
        all_trials = [this_data.data.sessions(1).trials];
    end
    
    % find trials of chosen type
    idx = ismember({all_trials(:).protocol}, protocol_types);
    
    configs = [all_trials(:).config];
    idx_gain = strcmp({configs(:).gain_direction}, gain_dir);
    idx = idx & idx_gain;
    
    
    these_trials = all_trials(idx);
    
    n_trials = length(these_trials);
    
    mm_start_t = nan(1, n_trials);
    for i = 1 : n_trials
        mm_start_t(i) = these_trials(i).mismatch_onset_t();
    end
    
    
    for clust_i = 1 : length(clusters)
        
        spike_times = clusters(clust_i).spike_times;
        fr = FiringRate(spike_times);
        
        fr_conv = nan(n_sample_points, n_trials);
        
        for i = 1 : n_trials
            fr_conv(:, i) = fr.get_convolution(mm_start_t(i) + common_t);
        end
        
        cluster_count = cluster_count + 1;
        
        fr_mean(cluster_count, :) = mean(fr_conv, 2)';
    end
end

% reorder heatmap
baseline_idx = common_t >= baseline_t(1) & common_t < baseline_t(2);

cluster_idx_sorted = figure_2g(data, []);

heatmap = fr_mean(cluster_idx_sorted, :);
heatmap = bsxfun(@minus, heatmap, mean(heatmap(:, baseline_idx), 2));

population_average = mean(heatmap, 1);
population_sem = std(heatmap, [], 1) / sqrt(cluster_count);



%% plot
cols = get_colours();



h_im  = imagesc(h_ax2, heatmap);
colormap(h_ax2, cols('red2blue_map'));

set(h_im, 'xdata', common_t);
set(h_ax2, 'clim', fr_limits, ...
           'xlim', padding, ...
           'ylim', [0.5, cluster_count+0.5], ...
           'xcolor', 'none', ...
           'ycolor', 'none');

text(h_ax2, padding(1)-0.2, cluster_count, sprintf('%i', 1), ...
    'horizontalalignment', 'right', ...
    'verticalalignment', 'middle', ...
    'fontsize', 8);

text(h_ax2, padding(1)-0.2, 1, sprintf('%i', cluster_count), ...
    'horizontalalignment', 'right', ...
    'verticalalignment', 'middle', ...
    'fontsize', 8);

text(h_ax2, padding(1)-0.3, (cluster_count + 1) / 2, 'cell #', ...
    'horizontalalignment', 'center', ...
    'verticalalignment', 'bottom', ...
    'fontsize', 8, ...
    'rotation', 90);

text(h_ax2, padding(2), cluster_count + 3, 'all cells', ...
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
axis(h_ax1, 'off');

