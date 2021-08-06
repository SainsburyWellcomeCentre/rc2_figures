function figure_2h(data, h_ax)

recording_ids       = experiment_details('mismatch_nov20');
protocol_types      = 'CoupledMismatch';
gain_dir            = 'up';

window_t            = 0.1;
n_windows           = 4;

cluster_count       = 0;
p_val               = [];
change              = {};
avg_baseline        = [];
avg_response        = [];
modulation_index    = [];
animal_id           = [];

relative_depth          = [];
layer                   = {};
anatomies               = Anatomy.empty();


%% extract and analyze data
for rec_i = 1 : length(recording_ids)
    
    rec_i
    
    this_data = get_data_for_recording_id(data, recording_ids{rec_i});
    clusters = this_data.VISp_clusters();
    anatomies(rec_i)  = Anatomy(this_data);
    
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
    mm_end_t = nan(1, n_trials);
    
    for i = 1 : n_trials
        mm_start_t(i) = these_trials(i).mismatch_onset_t();
        mm_end_t(i) = these_trials(i).mismatch_offset_t();
    end
    
    
    for clust_i = 1 : length(clusters)
        
        cluster_count = cluster_count + 1;
        
        spike_times = clusters(clust_i).spike_times;
        fr = FiringRate(spike_times);
        
        [relative_depth(cluster_count), layer{cluster_count}] = ...
                anatomies(rec_i).VISp_layer_relative_depth(clusters(clust_i).distance_from_probe_tip);
        assert(strcmp(layer{cluster_count}, clusters(clust_i).region_str));
        
        baseline = nan(n_trials, n_windows);
        response = nan(n_trials, n_windows);
        control = nan(n_trials, n_windows);
        
        for trial_i = 1 : n_trials
            
            if mm_end_t(trial_i) - mm_start_t(trial_i) < 0.05
                continue
            end
            
            for win_i = 1 : n_windows
                
                this_window = [(win_i-1), win_i] * window_t;
                control_window = mm_start_t(trial_i) - 2 * n_windows * window_t + this_window;
                baseline_window = mm_start_t(trial_i) - n_windows * window_t + this_window;
                response_window = mm_start_t(trial_i) + this_window;
                
                control(trial_i, win_i) = fr.get_fr_in_window(control_window);
                baseline(trial_i, win_i) = fr.get_fr_in_window(baseline_window);
                response(trial_i, win_i) = fr.get_fr_in_window(response_window);
            end
        end
        
        avg_baseline(cluster_count) = nanmean(baseline(:));
        avg_response(cluster_count) = nanmean(response(:));
        animal_id(cluster_count) = rec_i;
        
        p = mm_do_ANOVA(baseline', response');
        p_ctl = mm_do_ANOVA(baseline', control');
        
        if p_ctl(1) < 0.05
            p_val(cluster_count) = nan;
            change{cluster_count} = 'no_change';
        else
            p_val(cluster_count) = p(1);
            if p(1) < 0.05
                if avg_baseline(cluster_count) < avg_response(cluster_count)
                    change{cluster_count} = 'increase';
                elseif avg_baseline(cluster_count) > avg_response(cluster_count)
                    change{cluster_count} = 'decrease';
                else
                    error('??');
                end
            else
                change{cluster_count} = 'no_change';
            end
        end
        
        modulation_index(cluster_count) = (avg_response(cluster_count) - avg_baseline(cluster_count)) / ...
                                          (avg_response(cluster_count) + avg_baseline(cluster_count));
    end
end


% average the anatomy
avg_anatomy = AverageAnatomy(anatomies);
[boundaries, cluster_positions] = ...
    avg_anatomy.mi_vs_depth_positions(relative_depth, layer);
% merge layer 6a and 6b
boundaries(end-1) = [];


%% Plot
cols = get_colours();

x_limits = [-1, 1];
histogram_edges = -1:0.1:1;

cortical_thickness = range(boundaries);
space_for_histogram = cortical_thickness * (8.331/20.451); 

y_limits = [boundaries(end)-space_for_histogram, boundaries(1)];
layer_str = {'L1', 'L2/3', 'L4', 'L5', 'L6'};

for b = 1 : length(boundaries)
    line(h_ax, x_limits, boundaries([b, b]), 'color', 'k', 'linewidth', 0.5, 'linestyle', '--');
    if b > 1
        text(h_ax, -1.3, mean(boundaries([b-1, b])), layer_str{b-1}, 'color', 'k', 'fontsize', 8, ...
             'horizontalalignment', 'center', 'verticalalignment', 'middle');
    end
end



idx = strcmp(change, 'no_change');
scatter(h_ax, modulation_index(idx), cluster_positions(idx), scatterball_size(0.73), [0.5, 0.5, 0.5]);
n_no_change = histcounts(modulation_index(idx), histogram_edges);
idx = strcmp(change, 'increase');
scatter(h_ax, modulation_index(idx), cluster_positions(idx), scatterball_size(1.25), cols('sig_increase'));
n_increase = histcounts(modulation_index(idx), histogram_edges);
idx = strcmp(change, 'decrease');
scatter(h_ax, modulation_index(idx), cluster_positions(idx), scatterball_size(1.25), cols('sig_decrease'));
n_decrease = histcounts(modulation_index(idx), histogram_edges);



set(h_ax, 'xlim', x_limits, ...
          'xtick', [-1, 0, 1], ...
          'ylim', y_limits, ...
          'ycolor', 'none', ...
          'fontsize', 8, ...
          'color', 'none');

xlabel(h_ax, 'Modulation index', 'fontsize', 8);
text(h_ax, 0, y_limits(2) + 0.05 * range(y_limits), 'R:VF+T', 'fontsize', 8, 'horizontalalignment', 'center', 'verticalalignment', 'bottom');

% axis for histogram
original_axis_position = get(h_ax, 'position');

layer_height_mm = 19576;
axis_to_layers_mm = 9.655;
subaxis_height_mm = 2.883;
subaxis_y_offset = 1.345;

subaxis_height_ratio = subaxis_height_mm/(layer_height_mm+axis_to_layers_mm);
subaxis_y_offset_ratio = subaxis_y_offset/(layer_height_mm+axis_to_layers_mm);
subaxis_position = [original_axis_position(1), ...
                    original_axis_position(2) + subaxis_y_offset_ratio * original_axis_position(4), ...
                    original_axis_position(3), ...
                    subaxis_height_ratio * original_axis_position(4)];
                
sub_h_ax = a4axis(h_ax.Parent, normpos2mmpos(subaxis_position));

max_count = max([n_no_change, n_increase, n_decrease]);

for i = 1 : length(histogram_edges)-1
    
    if n_no_change(i) > 0
        patch(sub_h_ax, 'xdata', histogram_edges([i, i+1, i+1, i]), ...
                        'ydata', [0, 0, n_no_change(i), n_no_change(i)]/max_count, ...
                        'facecolor', [0.8, 0.8, 0.8], 'edgecolor', [0.8, 0.8, 0.8]);
    end
    
    if n_increase(i) > 0
        patch(sub_h_ax, 'xdata', histogram_edges([i, i+1, i+1, i]), ...
                        'ydata', [0, 0, n_increase(i), n_increase(i)]/max_count, ...
                        'facecolor', 'none', 'edgecolor', cols('sig_increase'));
    end
    
    if n_decrease(i) > 0
        patch(sub_h_ax, 'xdata', histogram_edges([i, i+1, i+1, i]), ...
                        'ydata', [0, 0, n_decrease(i), n_decrease(i)]/max_count, ...
                        'facecolor', 'none', 'edgecolor', cols('sig_decrease'));
    end
    
end


set(sub_h_ax, 'xlim', x_limits, ...
          'xtick', [], ...
          'fontsize', 8, ...
          'clipping', 'off');

% draw line from bottom of axis 
sub_y_limits = [0, 1];
line_length = range(sub_y_limits) * ((layer_height_mm+axis_to_layers_mm-subaxis_y_offset)/subaxis_height_mm);

line(sub_h_ax, [0, 0], sub_y_limits(1) + [0, line_length], 'color', 'k', 'linewidth', 0.5);
set(sub_h_ax, 'ylim', sub_y_limits, 'ytick', sub_y_limits, 'yticklabel', [0, 1], 'layer', 'top');
ylabel(sub_h_ax, {'norm.', 'count'}, 'fontsize', 8);
