function sort_idx = figure_2g(data, h_ax)

force_replication   = true;

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
animal_id           = [];


%% extract and analyze data
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
    
    if force_replication
        n_trials = length(these_trials);            % REPLICATES
    else
        n_trials = min(length(these_trials), 10);   % SUGGESTED CHANGE
    end
    
    mm_start_t = nan(1, n_trials);
    mm_end_t = nan(1, n_trials);
    
    for i = 1 : n_trials
        mm_start_t(i) = these_trials(i).mismatch_onset_t();
        mm_end_t(i) = these_trials(i).mismatch_offset_t();
    end
    
    
    for clust_i = 1 : length(clusters)
        
        spike_times = clusters(clust_i).spike_times;
        fr = FiringRate(spike_times);
        
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
        
        cluster_count = cluster_count + 1;
       
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
    end
end

delta_fr = avg_response - avg_baseline;
[~, sort_idx] = sort(delta_fr, 'ascend');
if isempty(h_ax)
    return
end


%% Plot
cols = get_colours();
xy_limits = [0, 35];

line(h_ax, xy_limits, xy_limits, 'color', 'k', 'linewidth', 0.5, 'linestyle', '--');
line(h_ax, xy_limits, xy_limits, 'color', 'k', 'linewidth', 0.5, 'linestyle', '--');

idx = strcmp(change, 'no_change');
scatter(h_ax, avg_baseline(idx), avg_response(idx), scatterball_size(0.73), [0.5, 0.5, 0.5]);
idx = strcmp(change, 'increase');
scatter(h_ax, avg_baseline(idx), avg_response(idx), scatterball_size(1.25), cols('sig_increase'));
idx = strcmp(change, 'decrease');
scatter(h_ax, avg_baseline(idx), avg_response(idx), scatterball_size(1.25), cols('sig_decrease'));

set(h_ax, 'xlim', xy_limits, ...
          'xtick', 0:10:xy_limits(2), ...
          'xticklabel', {'0', '', '', '30'}, ...
          'ylim', xy_limits, ...
          'ytick', 0:10:xy_limits(2), ...
          'yticklabel', {'0', '', '', '30'}, ...
          'fontsize', 8);

text(h_ax, mean(xy_limits), xy_limits(1)-0.1*range(xy_limits), 'FR R+VF (Hz)', ...
            'color', 'k', ...
            'fontsize', 8', ...
            'horizontalalignment', 'center', ...
            'verticalalignment', 'top');
% xlabel(h_ax, 'FR R+VF (Hz)', 'fontsize', 8);

ylabel(h_ax, 'FR R+VF+T (Hz)', 'fontsize', 8);

text(h_ax, 1.5, 30, sprintf('%.2f%%', 100*sum(strcmp(change, 'increase'))/length(change)), 'color', 'k', 'fontsize', 8, ...
    'color', cols('sig_increase'), 'horizontalalignment', 'left', 'verticalalignment', 'top');
text(h_ax, 30, 3, sprintf('%.2f%%', 100*sum(strcmp(change, 'decrease'))/length(change)), 'color', 'k', 'fontsize', 8, ...
    'color', cols('sig_decrease'), 'horizontalalignment', 'right', 'verticalalignment', 'bottom');
