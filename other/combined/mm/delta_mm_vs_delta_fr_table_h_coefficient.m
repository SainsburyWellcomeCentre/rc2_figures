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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OPTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

experiment = {'mismatch_nov20'};  % 'darkness', 'visual_flow', 'head_tilt', 'mismatch_nov20'
combination = {'protocols'};

formatted_data_dir = 'C:\Users\Lee\Documents\mvelez\data\formatted_data';

response_window     = [50, 400];    % response window to examine after mismatch onset (ms)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CALCULATE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

warning('off', 'MATLAB:table:RowsAddedExistingVars');
T = table();
r = 0;

for exp_i = 1 : length(experiment)
    
    [probe_fnames, protocols, ~, replay_of, ~, ~, ~, title_str, vis_stim, gain_directions] = experiment_details(experiment{exp_i}, combination{exp_i});
    
    for probe_i = 1 : length(probe_fnames)
        
        probe_i
        
        % location of the formatted data and cluster ID list
        formatted_data_fname = fullfile(formatted_data_dir, [probe_fnames{probe_i}, '.mat']);
        
        % load the formatted data
        data = load_data(formatted_data_fname);
        
        % get selected clusters
        selected_clusters = get_selected_clusters(data);        
        
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
        accept_trial = true(n_trials, 1);
        
        mm_start_t  = nan(n_trials, 1);
        
        stim_locked_spike_times = cell(length(selected_clusters), 1);
        
       for trial_i = 1 : n_trials
            
            protocol{trial_i} = trials(trial_i).protocol;
            gain_dir{trial_i} = trials(trial_i).config.gain_direction;
            
            % start of mismatch window in trial sample point
            mm_start_sample = find(diff(trials(trial_i).teensy_gain > 2.5) == 1) + 1;
            mm_end_sample = find(diff(trials(trial_i).teensy_gain > 2.5) == -1) + 1;
            mm_start_t(trial_i) = trials(trial_i).probe_t(mm_start_sample);
            mm_end_t = trials(trial_i).probe_t(mm_end_sample);
            
            if mm_end_t - mm_start_t(trial_i) < 0.05
                accept_trial(trial_i) = false;
            end
            
            % compute firing rate during mismatch window and baseline for
            % each cluster
            for cluster_i = 1 : length(selected_clusters)
                
                tc = selected_clusters(cluster_i);
                temp = 1e3*(tc.spike_times(tc.spike_times > mm_start_t(trial_i) - 5 & tc.spike_times < mm_start_t(trial_i) + 5) - mm_start_t(trial_i));
                
                % get spikes within 5 seconds
                stim_locked_spike_times{cluster_i}{trial_i, 1} = temp(:)';
                
            end
        end
        
        for cluster_i = 1 : length(selected_clusters)
            for prot_i = 1 : length(protocols)
                for gain_i = 1 : length(gain_directions)
                    
                    idx = strcmp(protocols{prot_i}, protocol) & ...
                        strcmp(gain_directions{gain_i}, gain_dir) & ...
                        accept_trial;
                    
                    these_spikes_around_stim = stim_locked_spike_times{cluster_i}(idx);
                    n_stimuli = length(these_spikes_around_stim);
                    mean_fr = selected_clusters(cluster_i).firing_rate;
                    
                    [kern, hcoeffs, hcoeffs2D] = ...
                        hcoeff(these_spikes_around_stim, ...
                               1e3*selected_clusters(cluster_i).spike_times(:)', ...
                               mean_fr, ...
                               n_stimuli, ...
                               response_window, ...
                               true);
                    
                    r = r + 1;
                    
                    T.probe_name{r} = probe_fnames{probe_i};
                    T.cluster_id(r) = selected_clusters(cluster_i).id;
                    T.cluster_region{r} = selected_clusters(cluster_i).region_str;
                    T.cluster_depth(r) = selected_clusters(cluster_i).depth;
                    T.cluster_from_tip(r) = selected_clusters(cluster_i).distance_from_probe_tip;
                    T.protocol{r} = protocols{prot_i};
                    T.gain_direction{r} = gain_directions{gain_i};
                    T.trial_ids{r} = find(idx);
                    
                    T.kern{r} = kern;
                    T.hcoeffs{r} = hcoeffs;
                    T.hcoeffs2D{r} = hcoeffs2D;
                    
                end
            end
        end
    end
end

save('mismatch_nov20_h_coefficient.mat', 'T');