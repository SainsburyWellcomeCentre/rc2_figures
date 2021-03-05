% shuffle spikes

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

window_t = 0.4; % s
n_reps = 1000;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CALCULATE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

warning('off', 'MATLAB:table:RowsAddedExistingVars');
T = table();
r = 0;

for exp_i = 1 : length(experiment)
    
    [probe_fnames, protocols, ~, replay_of, ~, ~, ~, title_str, vis_stim, gain_directions] = experiment_details(experiment{exp_i}, combination{exp_i});
    
    for probe_i = 1 : length(probe_fnames)
        
        str_probe = sprintf('Probe %i of %i\n', probe_i, length(probe_fnames));
        fprintf(str_probe);
            
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
        
        % get the start and end of the gain change for each trial
        protocol = cell(length(trials), 1);
        gain_dir = cell(length(trials), 1);
        accept_trial = true(length(trials), 1);
        mm_start_sample  = nan(length(trials), 1);
        mm_start_t  = nan(length(trials), 1);
        hstgrm = cell(length(selected_clusters), length(trials));
        rand_start_t = nan(n_reps, length(trials));
        rand_start_idx = nan(n_reps, length(trials));
        
        for trial_i = 1 : length(trials)
            
            str_trial = sprintf('Trial %i of %i\n', trial_i, length(trials));
            fprintf(str_trial);
            
            protocol{trial_i} = trials(trial_i).protocol;
            gain_dir{trial_i} = trials(trial_i).config.gain_direction;
            
            % start of mismatch window in trial sample point
            mm_start_sample(trial_i) = find(diff(trials(trial_i).teensy_gain > 2.5) == 1) + 1;
            mm_end_sample = find(diff(trials(trial_i).teensy_gain > 2.5) == -1) + 1;
            mm_start_t(trial_i) = trials(trial_i).probe_t(mm_start_sample(trial_i));
            mm_end_t = trials(trial_i).probe_t(mm_end_sample);
            
            if mm_end_t - mm_start_t(trial_i) < 0.05
                accept_trial(trial_i) = false;
            end
            
            % compute firing rate during trial
            for cluster_i = 1 : length(selected_clusters)
                 hstgrm{cluster_i, trial_i} = ...
                    cluster_fr(cluster_i).get_convolution(trials(trial_i).probe_t);
            end
            
            motion_mask = trials(trial_i).treadmill_motion_mask();
            motion_mask(mm_start_sample(trial_i) - 0.4*10e3 : end) = false;
            
            % find indices where there is 400ms of motion data beyond that point
            motion_onset_idx = find(diff(motion_mask) == 1)+1;
            motion_offset_idx = find(diff(motion_mask) == -1)+1;
            if isempty(motion_onset_idx)
               accept_trial(trial_i) = false;
               warning('empty durations')
               continue
            end
            motion_offset_idx(motion_offset_idx < motion_onset_idx(1)) = [];
            motion_onset_idx(motion_onset_idx > length(motion_mask)-0.4*10e3) = [];
            durations = motion_offset_idx - motion_onset_idx;
            
            motion_onset_idx(durations < 0.4*10e3) = [];
            motion_offset_idx(durations < 0.4*10e3) = [];
            durations(durations < 0.4*10e3) = [];
            if isempty(durations)
               accept_trial(trial_i) = false;
               warning('empty durations')
               continue
            end
            
            motion_offset_idx = motion_offset_idx - 0.4*10e3;
            new_flag = false(size(motion_mask));
            for i = 1 : length(motion_onset_idx)
                new_flag(motion_onset_idx(i):motion_offset_idx(i)) = true;
            end
            
            rand_start_idx(:, trial_i) = randi(sum(new_flag), n_reps, 1);
            rand_start_t(:, trial_i) = trials(trial_i).probe_t(rand_start_idx(:, trial_i));
            
            % get a random list of start points
%             rand_start_t(:, trial_i) = trials(trial_i).probe_t(1) + ...
%                 (mm_start_t(trial_i) - trials(trial_i).probe_t(1) - window_t) * rand(n_reps, 1);
%             
%             above_rand_t = bsxfun(@gt, trials(trial_i).probe_t(:)', rand_start_t(:, trial_i));
%             [~, rand_start_idx(:, trial_i)] = max(above_rand_t, [], 2);
            
%             fprintf(repmat('\b', 1, length(str_trial)));
        end
        
        %%
        for prot_i = 1 : length(protocols)
            
            % index of trials with this protocol and gain direction
            % (and also valid)
            idx = strcmp(protocols{prot_i}, protocol) & ...
                strcmp(gain_directions{prot_i}, gain_dir) & ...
                accept_trial;
            
            % start index of trials of interest
            start_t = mm_start_t(idx);
            start_idx = mm_start_sample(idx);
            
            % get true response PSTH for each cluster
            for cluster_i = 1 : length(selected_clusters)
                
                t = cellfun(@(x, y)(x(y + (0:window_t*10e3-1))), ...
                    hstgrm(cluster_i, idx), num2cell(start_idx)', ...
                    'uniformoutput', false);
                real_psth = mean(cat(2, t{:}), 2);
                
                real_mean_fr = nan(sum(idx), 4);
                
                for wind_i = 1 : 4
                    real_mean_fr(:, wind_i) = arrayfun(@(x)(cluster_fr(cluster_i).get_fr_in_window([x, x+0.1])), ...
                                start_t + (wind_i-1)*0.1);
                end
                
                real_mean_fr = mean(real_mean_fr);
                
                shuff_psth = nan(length(real_psth), n_reps);
                shuff_mean_fr = nan(n_reps, 4);
                for rep_i = 1 : n_reps
                    these_rand_start_idx = rand_start_idx(rep_i, idx);
                    t = cellfun(@(x, y)(x(y + (0:window_t*10e3-1))), ...
                        hstgrm(cluster_i, idx), num2cell(these_rand_start_idx), ...
                        'uniformoutput', false);
                    shuff_psth(:, rep_i) = mean(cat(2, t{:}), 2);
                    
                    
                    these_rand_start_t = rand_start_t(rep_i, idx);
                    this_shuff_mean_fr = nan(sum(idx), 4);
                    for wind_i = 1 : 4
                        this_shuff_mean_fr(:, wind_i) = arrayfun(@(x)(cluster_fr(cluster_i).get_fr_in_window([x, x+0.1])), ...
                            these_rand_start_t + (wind_i-1)*0.1);
                    end
                    
                    shuff_mean_fr(rep_i, :) = mean(this_shuff_mean_fr, 1);
                    
                end
                
                r = r + 1;
                
                T.probe_name{r} = probe_fnames{probe_i};
                T.cluster_id(r) = selected_clusters(cluster_i).id;
                T.cluster_region{r} = selected_clusters(cluster_i).region_str;
                T.cluster_depth(r) = selected_clusters(cluster_i).depth;
                T.cluster_from_tip(r) = selected_clusters(cluster_i).distance_from_probe_tip;
                T.protocol{r} = protocols{prot_i};
                T.gain_direction{r} = gain_directions{prot_i};
                T.trial_ids{r} = find(idx);
                
                T.real_psth{r} = real_psth;
                T.shuff_psth_mean{r} = mean(shuff_psth, 2);
                T.shuff_psth_up{r} = prctile(shuff_psth, 97.5, 2);
                T.shuff_psth_down{r} = prctile(shuff_psth, 2.5, 2);
                
                T.real_fr{r} = real_mean_fr;
                T.shuff_fr_mean{r} = mean(shuff_mean_fr, 1);
                T.shuff_fr_up{r} = prctile(shuff_mean_fr, 97.5, 1);
                T.shuff_fr_down{r} = prctile(shuff_mean_fr, 2.5, 1);
                
            end
        end
        
%         fprintf(repmat('\b', 1, length(str_probe)));
    end
end

save('mismatch_nov20_shuffle2_table.mat', 'T');
