function figure_1l(data, h_ax)

csv_dir = 'D:\mvelez\summary_data\stationary_vs_motion_fr';

recording_ids       = experiment_details('visual_flow');
recording_ids       = [recording_ids, experiment_details('mismatch_nov20')];

cols = get_colours();

R_VF_med                = [];
R_VF_T_med              = [];
p_val                   = [];
change                  = {};
cluster_count           = 0;
modulation_index        = [];

relative_depth          = [];
layer                   = {};
anatomies               = Anatomy.empty();

for rec_i = 1 : length(recording_ids)
    
    this_data = get_data_for_recording_id(data, recording_ids{rec_i});
    anatomies(rec_i)  = Anatomy(this_data);
    
    csv_fname = fullfile(csv_dir, sprintf('%s.csv', recording_ids{rec_i}));
    svm_table = readsvmtable(csv_fname);
    
    clusters = this_data.VISp_clusters();
    
    for clust_i = 1 : length(clusters)
        
        if ismember(recording_ids{rec_i}, experiment_details('mismatch_nov20'))
            
            % get all trials for this recording
            if strcmp(recording_ids{rec_i}, 'CAA-1112872_rec1_rec1b_rec2_rec3')
                all_trials = [this_data.data.sessions(1).trials, this_data.data.sessions(2).trials];
            else
                all_trials = [this_data.data.sessions(1).trials];
            end
            configs = [all_trials(:).config];
            gain_up_trial_ids = [all_trials(strcmp({configs(:).gain_direction}, 'up')).id];
            
            idx_rvf = svm_table.cluster_id == clusters(clust_i).id & svm_table.protocol == 'EncoderOnlyMismatch' & ...
                ismember(svm_table.trial_id, gain_up_trial_ids);
            idx_rvft = svm_table.cluster_id == clusters(clust_i).id & svm_table.protocol == 'CoupledMismatch' & ...
                ismember(svm_table.trial_id, gain_up_trial_ids);
        else
            idx_rvf = svm_table.cluster_id == clusters(clust_i).id & svm_table.protocol == 'EncoderOnly';
            idx_rvft = svm_table.cluster_id == clusters(clust_i).id & svm_table.protocol == 'Coupled';
        end
        
        R_VF = svm_table.motion_firing_rate(idx_rvf);
        R_VF_T = svm_table.motion_firing_rate(idx_rvft);
        
        if length(R_VF) ~= length(R_VF_T)
            n_trials = min(length(R_VF), length(R_VF_T));
            R_VF = R_VF(1:n_trials);
            R_VF_T = R_VF_T(1:n_trials);
        end
        
        n_trials = min(length(R_VF), 10);
        R_VF = R_VF(1:n_trials);
        R_VF_T = R_VF_T(1:n_trials);
        
        cluster_count = cluster_count + 1;
        R_VF_med(cluster_count) = nanmedian(R_VF);
        R_VF_T_med(cluster_count) = nanmedian(R_VF_T);
        [p_val(cluster_count), ~, stats] = signrank(R_VF, R_VF_T);
        
        [relative_depth(cluster_count), layer{cluster_count}] = ...
                anatomies(rec_i).VISp_layer_relative_depth(clusters(clust_i).distance_from_probe_tip);
        assert(strcmp(layer{cluster_count}, clusters(clust_i).region_str));
        
        if R_VF_med(cluster_count) < eps
            R_VF_med(cluster_count) = 0;
        end
        if R_VF_T_med(cluster_count) < eps
            R_VF_T_med(cluster_count) = 0;
        end
        
        % catch cases where medians are equal but there is a significant
        % difference between the groups
        if p_val(cluster_count) < 0.05
            
            if cluster_count == 114
                disp('')
            end
            if R_VF_med(cluster_count) == R_VF_T_med(cluster_count)
                
                [~, ~, stats_opp] = signrank(R_VF_T, R_VF);
                if stats_opp.signedrank > stats.signedrank
                    change{cluster_count} = 'increase';
                elseif stats_opp.signedrank < stats.signedrank
                    change{cluster_count} = 'decrease';
                else
                    error('Signed ranks are equal?');
                end
                
            elseif R_VF_med(cluster_count) < R_VF_T_med(cluster_count)
                
                change{cluster_count} = 'increase';
            elseif R_VF_med(cluster_count) > R_VF_T_med(cluster_count)
                
                change{cluster_count} = 'decrease';
            end
            
        elseif p_val(cluster_count) >= 0.05
            
            change{cluster_count} = 'no_change';
        else
            warning('p value not numeric');
        end
        
        modulation_index(cluster_count) = (R_VF_T_med(cluster_count) - R_VF_med(cluster_count)) / ...
                                          (R_VF_T_med(cluster_count) + R_VF_med(cluster_count));
    end
end


% average the anatomy
avg_anatomy = AverageAnatomy(anatomies);
[boundaries, cluster_positions] = ...
    avg_anatomy.mi_vs_depth_positions(relative_depth, layer);
% merge layer 6a and 6b
boundaries(end-1) = [];


%% Plot
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

xlabel(h_ax, {'Modulation index', 'R+VF vs. R+VF+T'}, 'fontsize', 8);

% axis for histogram
original_axis_position = get(h_ax, 'position');

layer_height_mm = 20.451;
axis_to_layers_mm = 8.331;
subaxis_height_mm = 3.765;
subaxis_y_offset = 1.093;

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


