% PTSH

% plot rasters for an animal
clear all
close all

import helper.*

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OPTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

experiment = {'mismatch_nov20'};  % 'darkness', 'visual_flow', 'head_tilt', 'mismatch_nov20'
combination = {'protocols'};

formatted_data_dir = 'C:\Users\Lee\Documents\mvelez\data\formatted_data';

bin_t = 0.02;
window_t = 0.4;          % size of window (only if window_type is 'arbitrary'
nhstbin = ceil(window_t/bin_t);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CALCULATE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

warning('off', 'MATLAB:table:RowsAddedExistingVars');
T = table();
r = 0;
n_removed = 0;

for exp_i = 1 : length(experiment)
    
    [probe_fnames, protocols, ~, replay_of, ~, ~, ~, title_str, vis_stim, gain_dir] = experiment_details(experiment{exp_i}, combination{exp_i});
    
    for probe_i = 1 : length(probe_fnames)
        probe_i
        % location of the formatted data and cluster ID list
        formatted_data_fname = fullfile(formatted_data_dir, [probe_fnames{probe_i}, '.mat']);
        
        % load the formatted data
        data = load_data(formatted_data_fname);
        
        % get selected clusters
        selected_clusters = get_selected_clusters(data);
        
        % create object array handling firing rates
        for cluster_i = 1 : length(selected_clusters)
            cluster_fr(cluster_i) = FiringRate(selected_clusters(cluster_i).spike_times);
        end
        
        % get mismatch trials
        if strcmp(probe_fnames{probe_i}, 'CAA-1112872_rec1_rec1b_rec2_rec3')
            mismatch_trials = [data.sessions(1).trials, data.sessions(2).trials];
        else
            mismatch_trials = [data.sessions(1).trials];
        end
        
        % get the start and end of the gain change for each trial
        protocol = cell(length(mismatch_trials), 1);
        gain_dir = cell(length(mismatch_trials), 1);
        start_t = nan(length(mismatch_trials), 1);
        end_trigger_t = nan(length(mismatch_trials), 1);
        end_t = nan(length(mismatch_trials), 1);
        start_idx = nan(length(mismatch_trials), 1);
        end_idx = nan(length(mismatch_trials), 1);
        velocity_mm = nan(length(mismatch_trials), 1);
        fr_mm = nan(length(mismatch_trials), length(selected_clusters));
        fr_baseline = nan(length(mismatch_trials), length(selected_clusters));
        baseline_start_t = nan(length(mismatch_trials), 1);
        baseline_start_idx = nan(length(mismatch_trials), 1);
        fr_baseline_all = cell(length(mismatch_trials), length(selected_clusters));
        
        hstgm_baseline = cell(length(mismatch_trials), length(selected_clusters));
        hstgm_response = cell(length(mismatch_trials), length(selected_clusters));
        
        for trial_i = 1 : length(mismatch_trials)
            
            protocol{trial_i} = mismatch_trials(trial_i).protocol;
            gain_dir{trial_i} = mismatch_trials(trial_i).config.gain_direction;
            
            % start and end of mismatch window in trial sample point
            idx_start = find(diff(mismatch_trials(trial_i).teensy_gain > 2.5) == 1) + 1;
            idx_trigger_end = find(diff(mismatch_trials(trial_i).teensy_gain > 2.5) == -1) + 1;
            idx_end = idx_start + window_t * 10e3;
            
            assert(length(idx_start) == 1, 'More than one gain change onset');
            assert(length(idx_end) == 1, 'More than one gain change offset');
            assert(idx_start < idx_end, 'Onset occurs after offset');
            
            % start and end of mismatch window in probe time
            start_t(trial_i) = mismatch_trials(trial_i).probe_t(idx_start);
            end_trigger_t(trial_i) = mismatch_trials(trial_i).probe_t(idx_trigger_end);
            end_t(trial_i) = mismatch_trials(trial_i).probe_t(idx_end);
            
            % location of maximum difference +ve or negative
            [~, max_idx] = max(abs(mismatch_trials(trial_i).gain_teensy(idx_start:idx_end) - ...
                mismatch_trials(trial_i).velocity(idx_start:idx_end)));
            
            % signed difference
            delta_mm(trial_i) = ...
                mismatch_trials(trial_i).gain_teensy(idx_start + max_idx - 1) - ...
                mismatch_trials(trial_i).velocity(idx_start + max_idx - 1);
            
            baseline_start_idx(trial_i) = idx_start - window_t * 10e3;
            baseline_start_t(trial_i) = mismatch_trials(trial_i).probe_t(baseline_start_idx(trial_i));
            
            
            % compute firing rate during mismatch window and baseline for
            % each cluster
            for cluster_i = 1 : length(selected_clusters)
                
                hstgm_baseline{trial_i, cluster_i} = ...
                    cluster_fr(cluster_i).get_histogram([baseline_start_t(trial_i), ...
                                                         start_t(trial_i)], ...
                                                         bin_t);
                
                hstgm_response{trial_i, cluster_i} = ...
                    cluster_fr(cluster_i).get_histogram([start_t(trial_i), end_t(trial_i)], bin_t);
                
            end
        end
        
        
        % create table
        for trial_i = 1 : length(mismatch_trials)
            for cluster_i = 1 : length(selected_clusters)
                
                if end_trigger_t(trial_i) - start_t(trial_i) < 0.05
                    n_removed = n_removed + 1;
                    continue
                end
                
                r = r + 1;
                
                T.probe_name{r} = probe_fnames{probe_i};
                T.cluster_id(r) = selected_clusters(cluster_i).id;
                T.cluster_region{r} = selected_clusters(cluster_i).region_str;
                T.cluster_depth(r) = selected_clusters(cluster_i).depth;
                T.cluster_from_tip(r) = selected_clusters(cluster_i).distance_from_probe_tip;
                T.protocol{r} = mismatch_trials(trial_i).protocol;
                T.gain_direction{r} = mismatch_trials(trial_i).config.gain_direction;
                T.trial_id(r) = mismatch_trials(trial_i).id;
                T.session_id{r} = mismatch_trials(trial_i).session.id;
                
%                 T.fr_mm(r) = fr_mm(trial_i, cluster_i);
%                 T.fr_baseline(r) = fr_baseline(trial_i, cluster_i);
%                 T.delta_fr(r) = delta_fr(trial_i, cluster_i);
%                 T.delta_mm(r) = delta_mm(trial_i);
                T.start_t(r) = start_t(trial_i);
                T.end_t(r) = end_t(trial_i);
                T.start_idx(r) = start_idx(trial_i);
                T.end_idx(r) = end_idx(trial_i);
                T.baseline_start_t(r) = baseline_start_t(trial_i);
                T.baseline_start_idx(r) = baseline_start_idx(trial_i);
%                 T.n_baseline_periods(r) = length(fr_baseline_all{trial_i, cluster_i});
                T.hstgm_baseline{r} = hstgm_baseline{trial_i, cluster_i};
                T.hstgm_response{r} = hstgm_response{trial_i, cluster_i};
            end
        end
    end
end

fprintf('# trials removed: %i\n', n_removed);
Tpsth = T;
