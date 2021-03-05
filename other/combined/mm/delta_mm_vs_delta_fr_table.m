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

allwindow       = {};
response_type   = {'average', 'peak'}; % 'average' or 'peak'
baseline_type   = 'preceding'; % 'speed_matched', 'preceding'
window_type     = 'mm_period'; % 'mm_period', 'arbitrary'
window_t        = [0.2];          % size of window (only if window_type is 'arbitrary'

for resp_i = 1 : length(response_type)
    for wi = 1 : length(window_t)
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% CALCULATE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % allwindow = {};
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
                    mismatch_trials = [data.sessions(1).trials, data.sessions(2).trials];
                else
                    mismatch_trials = [data.sessions(1).trials];
                end
                
                % get the start and end of the gain change for each trial
                protocol = cell(length(mismatch_trials), 1);
                gain_dir = cell(length(mismatch_trials), 1);
                start_t = nan(length(mismatch_trials), 1);
                end_t = nan(length(mismatch_trials), 1);
                start_idx = nan(length(mismatch_trials), 1);
                end_idx = nan(length(mismatch_trials), 1);
                velocity_mm = nan(length(mismatch_trials), 1);
                fr_mm = nan(length(mismatch_trials), length(selected_clusters));
                fr_baseline = nan(length(mismatch_trials), length(selected_clusters));
                baseline_start_t = cell(length(mismatch_trials), 1);
                baseline_start_idx = cell(length(mismatch_trials), 1);
                fr_baseline_all = cell(length(mismatch_trials), length(selected_clusters));
                
                for trial_i = 1 : length(mismatch_trials)
                    
                    protocol{trial_i} = mismatch_trials(trial_i).protocol;
                    gain_dir{trial_i} = mismatch_trials(trial_i).config.gain_direction;
                    
                    % start and end of mismatch window in trial sample point
                    idx_start = find(diff(mismatch_trials(trial_i).teensy_gain > 2.5) == 1) + 1;
                    
                    if strcmp(window_type, 'mm_period')
                        idx_end = find(diff(mismatch_trials(trial_i).teensy_gain > 2.5) == -1) + 1; % idx_start + 0.5*30e3;%
                    elseif strcmp(window_type, 'arbitrary')
                        idx_end = idx_start + window_t(wi) * 10e3;
                    end
                    
                    assert(length(idx_start) == 1, 'More than one gain change onset');
                    assert(length(idx_end) == 1, 'More than one gain change offset');
                    assert(idx_start < idx_end, 'Onset occurs after offset');
                    
                    % start and end of mismatch window in probe time
                    start_t(trial_i) = mismatch_trials(trial_i).probe_t(idx_start);
                    end_t(trial_i) = mismatch_trials(trial_i).probe_t(idx_end);
                    
                    % compute running velocity during mismatch window
                    velocity_mm(trial_i) = mean(mismatch_trials(trial_i).velocity(idx_start:idx_end));
                    
                    % location of maximum difference +ve or negative
                    [~, max_idx] = max(abs(mismatch_trials(trial_i).gain_teensy(idx_start:idx_end) - ...
                        mismatch_trials(trial_i).velocity(idx_start:idx_end)));
                    
                    % signed difference
                    delta_mm(trial_i) = ...
                        mismatch_trials(trial_i).gain_teensy(idx_start + max_idx - 1) - ...
                        mismatch_trials(trial_i).velocity(idx_start + max_idx - 1);
                    
                    % look for windows matching that velocity (run backwards)
                    window_size = idx_end - idx_start;
                    window_dt = end_t(trial_i) - start_t(trial_i);
                    
                    allwindow{end+1, 1} = window_dt;
                    allwindow{end, 2} = trial_i;
                    allwindow{end, 3} = probe_i;
                    allwindow{end, 4} = protocol{trial_i};
                    allwindow{end, 5} = gain_dir{trial_i};
                    
                    if strcmp(baseline_type, 'speed_matched')
                        
                        % first run backwards
                        baseline_idx_start = ...
                            match_value_in_trace(mismatch_trials(trial_i).velocity(idx_start-1 : -1 : 1), ...
                            window_size, velocity_mm(trial_i), 0.1*velocity_mm(trial_i));
                        
                        % correct for fact it was running backwards....
                        baseline_idx_start = sort((idx_start-1) - baseline_idx_start - window_size + 2);
                        baseline_start_t{trial_i} = mismatch_trials(trial_i).probe_t(baseline_idx_start);
                        baseline_start_idx{trial_i} = baseline_idx_start;
                        
                    elseif strcmp(baseline_type, 'preceding')
                        
                        baseline_idx_start = idx_start - window_size;
                        baseline_start_t{trial_i} = mismatch_trials(trial_i).probe_t(baseline_idx_start);
                        baseline_start_idx{trial_i} = baseline_idx_start;
                        
                    end
                    
                    % compute firing rate during mismatch window and baseline for
                    % each cluster
                    for cluster_i = 1 : length(selected_clusters)
                        
                        if strcmp(response_type{resp_i}, 'average')
                            
                            % firing rate during mismatch window
                            fr_mm(trial_i, cluster_i) = ...
                                cluster_fr(cluster_i).get_fr_in_window([start_t(trial_i), end_t(trial_i)]);
                            
                            % baseline
                            for window_i = 1 : length(baseline_start_t{trial_i})
                                fr_baseline_all{trial_i, cluster_i}(window_i) = ...
                                    cluster_fr(cluster_i).get_fr_in_window([baseline_start_t{trial_i}(window_i), ...
                                    baseline_start_t{trial_i}(window_i) + window_dt]);
                            end
                            
                            % average speed-matched baseline firing rate
                            fr_baseline(trial_i, cluster_i) = mean(fr_baseline_all{trial_i, cluster_i});
                            
                        elseif strcmp(response_type{resp_i}, 'peak')
                            
                            t = mismatch_trials(trial_i).probe_t;
                            spk_conv = cluster_fr(cluster_i).get_convolution(t);
                            fr_mm(trial_i, cluster_i) = max(spk_conv(idx_start:idx_end));
                            % baseline
                            for window_i = 1 : length(baseline_start_t{trial_i})
                                fr_baseline_all{trial_i, cluster_i}(window_i) = max(spk_conv(baseline_start_idx{trial_i}(window_i):idx_start-1));
                            end
                            fr_baseline(trial_i, cluster_i) = mean(fr_baseline_all{trial_i, cluster_i});
                            
                        end
                    end
                    
                    start_idx(trial_i) = idx_start;
                    end_idx(trial_i) = idx_end;
                    
                end
                
                delta_fr = fr_mm - fr_baseline;
                
                % create table
                n_removed = 0;
                for trial_i = 1 : length(mismatch_trials)
                    for cluster_i = 1 : length(selected_clusters)
                        
                        if end_t(trial_i) - start_t(trial_i) < 0.05
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
                        
                        T.fr_mm(r) = fr_mm(trial_i, cluster_i);
                        T.fr_baseline(r) = fr_baseline(trial_i, cluster_i);
                        T.delta_fr(r) = delta_fr(trial_i, cluster_i);
                        T.delta_mm(r) = delta_mm(trial_i);
                        T.start_t(r) = start_t(trial_i);
                        T.end_t(r) = end_t(trial_i);
                        T.start_idx(r) = start_idx(trial_i);
                        T.end_idx(r) = end_idx(trial_i);
                        T.baseline_start_t{r} = baseline_start_t{trial_i};
                        T.baseline_start_idx{r} = baseline_start_idx{trial_i};
                        T.n_baseline_periods(r) = length(fr_baseline_all{trial_i, cluster_i});
                    end
                end
            end
        end
        
        fprintf('# trials removed: %i\n', n_removed);
        
        save(sprintf('mismatch_nov20_%ims_%s_baseline_preceding.mat', 1e3*window_t(wi), response_type{resp_i}), 'T');
        
    end
end
