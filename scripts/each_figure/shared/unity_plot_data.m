function [x_med, y_med, p_val, change, info] = unity_plot_data(data, recording_ids, x_meta, y_meta, force_replication)

csv_dir             = 'D:\mvelez\summary_data\stationary_vs_motion_fr';

cluster_count       = 0;
x_med               = [];
y_med               = [];
p_val               = [];
change              = {};


for rec_i = 1 : length(recording_ids)
    
    csv_fname = fullfile(csv_dir, sprintf('%s.csv', recording_ids{rec_i}));
    svm_table = readsvmtable(csv_fname);
    
    this_data = get_data_for_recording_id(data, recording_ids{rec_i});
    clusters = this_data.VISp_clusters();
    
    for clust_i = 1 : length(clusters)
        
        
        x = get_fr_vector(x_meta);
        
        idx = svm_table.cluster_id == clusters(clust_i).id & svm_table.protocol == y_meta.protocol;
        
        if isfield(y_meta, 'gain_dir')
            % get all trials for this recording
            if strcmp(recording_ids{rec_i}, 'CAA-1112872_rec1_rec1b_rec2_rec3')
                all_trials = [this_data.data.sessions(1).trials, this_data.data.sessions(2).trials];
            else
                all_trials = [this_data.data.sessions(1).trials];
            end
            configs = [all_trials(:).config];
            gain_up_trial_ids = [all_trials(strcmp({configs(:).gain_direction}, y_meta.gain_dir)).id];
            idx = idx & ismember(svm_table.trial_id, gain_up_trial_ids);
        end
        
        if y_meta.motion
            y = svm_table.motion_firing_rate(idx);
        else
            y = svm_table.stationary_firing_rate(idx);
        end
        
        assert(length(x) == length(y));
        
        cluster_count = cluster_count + 1;
        
        if ~force_replication
            n_trials = min(length(x), 10);
            x = x(1:n_trials);
            y = y(1:n_trials);
        end
            
        
        x_med(cluster_count) = nanmedian(x);
        y_med(cluster_count) = nanmedian(y);
        
        [p_val(cluster_count), ~, stats] = signrank(x, y);
        
        info(cluster_count).n = sum(~isnan(x));
        info(cluster_count).n = sum(~isnan(y));
        
        info(cluster_count).n_nan = sum(isnan(x));
        info(cluster_count).n_nan = sum(isnan(y));
        
        info(cluster_count).odd_zero_issue = false;
        
        % catch cases where medians are equal but there is a significant
        % difference between the groups
        if p_val(cluster_count) < 0.05
            
            if x_med(cluster_count) == y_med(cluster_count)
                
                info(cluster_count).odd_zero_issue = true;
                [~, ~, stats_opp] = signrank(y, x);
                
                if stats_opp.signedrank > stats.signedrank
                    change{cluster_count} = 'increase';
                elseif stats_opp.signedrank < stats.signedrank
                    change{cluster_count} = 'decrease';
                else
                    error('Signed ranks are equal?');
                end
                
            elseif x_med(cluster_count) < y_med(cluster_count)
                
                change{cluster_count} = 'increase';
                
            elseif x_med(cluster_count) > y_med(cluster_count)
                
                change{cluster_count} = 'decrease';
            end
            
        elseif p_val(cluster_count) >= 0.05
            
            change{cluster_count} = 'no_change';
        else
            warning('p value not numeric');
        end
    end
end



function v = get_fr_vector(cluster_id, meta, recording_id)

idx = svm_table.cluster_id == cluster_id & svm_table.protocol == meta.protocol;

if ~isempty(meta.gain_dir)
    
    % get all trials for this recording
    if strcmp(r, 'CAA-1112872_rec1_rec1b_rec2_rec3')
        all_trials = [this_data.data.sessions(1).trials, this_data.data.sessions(2).trials];
    else
        all_trials = [this_data.data.sessions(1).trials];
    end
    
    configs = [all_trials(:).config];
    gain_up_trial_ids = [all_trials(strcmp({configs(:).gain_direction}, x_meta.gain_dir)).id];
    idx = idx & ismember(svm_table.trial_id, gain_up_trial_ids);
end

if x_meta.motion
    x = svm_table.motion_firing_rate(idx);
else
    x = svm_table.stationary_firing_rate(idx);
end