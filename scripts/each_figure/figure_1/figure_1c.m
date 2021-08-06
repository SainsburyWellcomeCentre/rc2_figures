function figure_1c(data, h_ax_upper, h_ax_lower)

recording_ids       = experiment_details('mismatch_nov20');
recording_ids       = [recording_ids, experiment_details('visual_flow')];
protocol_types      = {'Coupled', 'CoupledMismatch'};

min_bout_duration   = 2;
fs                  = 10000;
baseline_t          = [-0.4, 0];
response_t          = [0, 0.4];

% display
padding             = [-1, 1];
fr_limits           = [-8, 8];

include_200ms       = true;
real_motion_start   = true;


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
    if ismember(recording_ids{rec_i}, experiment_details('mismatch_nov20'))
        configs = [all_trials(:).config];
        idx_gain = strcmp({configs(:).gain_direction}, 'up');
        idx = idx & idx_gain;
    end
    
    these_trials = all_trials(idx);
    
    bouts = [];
    for trial_i = 1 : length(these_trials)
        these_bouts = these_trials(trial_i).motion_bouts(include_200ms, real_motion_start);
        if ~isempty(these_bouts)
            bouts = [bouts, these_bouts];
        end
    end
    bouts([bouts(:).duration] < min_bout_duration) = [];
    
    for clust_i = 1 : length(clusters)
        
        spike_times = clusters(clust_i).spike_times;
        fr = FiringRate(spike_times);
        
        fr_conv = nan(n_sample_points, length(bouts));
        
        for bout_i = 1 : length(bouts)
            
            fr_conv(:, bout_i) = fr.get_convolution(bouts(bout_i).start_time + common_t);
        end
        
        cluster_count = cluster_count + 1;
        
        fr_mean(cluster_count, :) = mean(fr_conv, 2)';
    end
end

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
population_sem = std(heatmap, [], 1) / sqrt(cluster_count);



%% plot
cols = get_colours();

h_im  = imagesc(h_ax_upper, heatmap);
line(h_ax_upper, [0, 0], [0.5, cluster_count+0.5], 'linestyle', '--', 'color', 'k');
colormap(h_ax_upper, cols('red2blue_map'));
set(h_im, 'xdata', common_t);
set(h_ax_upper, 'clim', fr_limits, 'ytick', [1, cluster_count], 'xlim', padding, 'ylim', [0.5, cluster_count+0.5], ...
          'xcolor', 'none', 'ycolor', 'none', 'yticklabel', [cluster_count, 1]);
text(h_ax_upper, padding(1)-0.2, cluster_count, sprintf('%i', 1), 'horizontalalignment', 'right', 'verticalalignment', 'middle', ...
    'fontsize', 8);
text(h_ax_upper, padding(1)-0.2, 1, sprintf('%i', cluster_count), 'horizontalalignment', 'right', 'verticalalignment', 'middle', ...
    'fontsize', 8);
text(h_ax_upper, padding(1)-0.3, (cluster_count + 1) / 2, 'cell #', 'horizontalalignment', 'center', 'verticalalignment', 'bottom', ...
    'fontsize', 8, 'rotation', 90);
text(h_ax_upper, 0, cluster_count + 3, {'locomotion', 'onset'}, 'horizontalalignment', 'center', 'verticalalignment', 'bottom', ...
    'fontsize', 6);
text(h_ax_upper, padding(2), cluster_count + 3, 'all cells', 'horizontalalignment', 'right', 'verticalalignment', 'bottom', ...
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

