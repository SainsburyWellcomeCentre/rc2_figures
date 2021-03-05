% For mismatch experiments,
%       CAA-1112872_rec1_rec1b_rec2_rec3
%       CAA-1112874_rec1_rec2_rec3
%       CAA-1113219_rec1_rec2_rec3, etc.
%
% For each trial,
%  calculate the average "natural" velocity during the 200ms mismatch period
%   (i.e. before gain change)
%
%  Look for 200ms windows during the baseline period matching that velocity.
%  Compute delta_FR as difference of firing rate during mismatch period
%   and average of firing rates during the matching baseline periods
%
%  Compute delta_MM as difference between peak "natural" velocity and
%   velocity after gain change
%
% Scatter delta_MM against delta_FR (each dot = trial)
%
% Calculate R^2 and p from correlation... (for now)


% plot rasters for an animalzzz
clear all
close all


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OPTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

experiment = {'mismatch_nov20'};  % 'darkness', 'visual_flow', 'head_tilt', 'mismatch_nov20'
combination = {'protocols'};

formatted_data_dir = 'C:\Users\Lee\Documents\mvelez\data\formatted_data';

baseline_window_t   = 0.4;
window_t            = 0.1;          % size of window
n_windows           = 4;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CALCULATE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

warning('off', 'MATLAB:table:RowsAddedExistingVars');
T = table();
r = 0;

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
            trials = [data.sessions(1).trials, data.sessions(2).trials];
        else
            trials = [data.sessions(1).trials];
        end
        n_trials = length(trials);
        
        
        % get the start and end of the gain change for each trial
        protocol    = cell(n_trials, 1);
        gain_dir    = cell(n_trials, 1);
        
        mm_start_t  = nan(n_trials, 1);
        mm_end_t    = nan(n_trials, 1);
        
        fr_response = nan(n_windows, n_trials, length(selected_clusters));
        fr_baseline = nan(n_trials, length(selected_clusters));
        
        for trial_i = 1 : n_trials
            
            protocol{trial_i} = trials(trial_i).protocol;
            gain_dir{trial_i} = trials(trial_i).config.gain_direction;
            
            % start of mismatch window in trial sample point
            mm_start_sample = find(diff(trials(trial_i).teensy_gain > 2.5) == 1) + 1;
            mm_end_sample = find(diff(trials(trial_i).teensy_gain > 2.5) == -1) + 1;
            mm_start_t(trial_i) = trials(trial_i).probe_t(mm_start_sample);
            mm_end_t(trial_i) = trials(trial_i).probe_t(mm_end_sample);
            
            % calculate windows
            baseline_limits = mm_start_t(trial_i) + [-baseline_window_t, 0];
            window_limits = nan(n_windows, 2);
            for wind_i = 1 : n_windows
                window_limits(wind_i, :) = mm_start_t(trial_i) + [wind_i-1, wind_i]*window_t;
            end
            
            % compute firing rate during mismatch window and baseline for
            % each cluster
            for cluster_i = 1 : length(selected_clusters)
                
                fr_baseline(trial_i, cluster_i) = cluster_fr(cluster_i).get_fr_in_window(baseline_limits);
                
                for wind_i = 1 : n_windows
                    fr_response(wind_i, trial_i, cluster_i) = cluster_fr(cluster_i).get_fr_in_window(window_limits(wind_i, :));
                end
            end
        end
        
        % create table
        for trial_i = 1 : n_trials
            for cluster_i = 1 : length(selected_clusters)
                
                if mm_end_t(trial_i) - mm_start_t(trial_i) < 0.05
                    continue
                end
                
                r = r + 1;
                
                T.probe_name{r} = probe_fnames{probe_i};
                T.cluster_id(r) = selected_clusters(cluster_i).id;
                T.cluster_region{r} = selected_clusters(cluster_i).region_str;
                T.cluster_depth(r) = selected_clusters(cluster_i).depth;
                T.cluster_from_tip(r) = selected_clusters(cluster_i).distance_from_probe_tip;
                T.protocol{r} = trials(trial_i).protocol;
                T.gain_direction{r} = trials(trial_i).config.gain_direction;
                T.trial_id(r) = trials(trial_i).id;
                T.session_id{r} = trials(trial_i).session.id;
                
                T.fr_response{r} = fr_response(:, trial_i, cluster_i);
                T.fr_baseline(r) = fr_baseline(trial_i, cluster_i);
                
            end
        end
    end
end

save(sprintf('mismatch_nov20_%ims_baseline_preceding_mulit_window.mat', 1e3*window_t), 'T', 'baseline_window_t', 'window_t', 'n_windows');