function figure_1k(data, h_ax)

csv_dir = 'D:\mvelez\summary_data\stationary_vs_motion_fr';

recording_ids       = experiment_details('visual_flow');
recording_ids       = [recording_ids, experiment_details('mismatch_nov20')];

cols                = get_colours();

R_VF_med            = [];
R_VF_T_med          = [];
p_val               = [];
change              = {};
cluster_count       = 0;


for rec_i = 1 : length(recording_ids)
    
    this_data = get_data_for_recording_id(data, recording_ids{rec_i});
    
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
    end
end



%% Plot
xy_limits = [0, 70];
hold on;

line(h_ax, xy_limits, xy_limits, 'color', 'k', 'linewidth', 0.5, 'linestyle', '--');
line(h_ax, xy_limits, xy_limits, 'color', 'k', 'linewidth', 0.5, 'linestyle', '--');

idx = strcmp(change, 'no_change');
scatter(h_ax, R_VF_med(idx), R_VF_T_med(idx), scatterball_size(0.73), [0.5, 0.5, 0.5]);
idx = strcmp(change, 'increase');
scatter(h_ax, R_VF_med(idx), R_VF_T_med(idx), scatterball_size(1.25), cols('sig_increase'));
idx = strcmp(change, 'decrease');
scatter(h_ax, R_VF_med(idx), R_VF_T_med(idx), scatterball_size(1.25), cols('sig_decrease'));

set(h_ax, 'xlim', xy_limits, ...
          'xtick', 0:20:xy_limits(2), ...
          'xticklabel', {'0', '', '', '60'}, ...
          'ylim', xy_limits, ...
          'ytick', 0:20:xy_limits(2), ...
          'yticklabel', {'0', '', '', '60'}, ...
          'fontsize', 8);
xlabel(h_ax, 'FR R+VF (Hz)', 'fontsize', 8);
ylabel(h_ax, 'FR R+VF+T (Hz)', 'fontsize', 8);

text(h_ax, 3, 40, sprintf('%.1f%%', 100*sum(strcmp(change, 'increase'))/length(change)), 'color', 'k', 'fontsize', 8, ...
    'color', cols('sig_increase'), 'horizontalalignment', 'left', 'verticalalignment', 'middle');
text(h_ax, 40, 3, sprintf('%.1f%%', 100*sum(strcmp(change, 'decrease'))/length(change)), 'color', 'k', 'fontsize', 8, ...
    'color', cols('sig_decrease'), 'horizontalalignment', 'center', 'verticalalignment', 'bottom');






