clear all
close all


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OPTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

experiment = {'mismatch_nov20'};  % 'darkness', 'visual_flow', 'head_tilt', 'mismatch_nov20'
combination = {'protocols'};

formatted_data_dir  = 'C:\Users\Lee\Documents\mvelez\data\formatted_data';
save_matfname       = 'mismatch_nov20_200ms_sliding_window_peak.mat';
save_on             = true;

% start and end points of window over which to look for the min and max response
peak_window_t            = [0, 0.3];

% window size to average over for the min and max (min/max plus/minus
% avg_window_t/2)
avg_window_t            = 0.2;

% common time base of response window
common_time_base        = linspace(peak_window_t(1), ...
                                   peak_window_t(2)+avg_window_t, ...
                                   round((range(peak_window_t)+avg_window_t)*10e3));

c = 0;
max_response_time       = [];
min_response_time       = [];

response_max_t          = {};
response_min_t          = {};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CALCULATE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

warning('off', 'MATLAB:table:RowsAddedExistingVars');
T = table();
r = 0;

for exp_i = 1 : length(experiment)
    
    % get details of the experiment
    [probe_fnames, protocols, ~, replay_of, ~, ~, ~, title_str, vis_stim, gain_directions] = experiment_details(experiment{exp_i}, combination{exp_i});
    
    % number of protocols
    n_protocols = length(protocols);
    
    for probe_i = 1 : length(probe_fnames)
        
        % location of the formatted data and cluster ID list
        formatted_data_fname = fullfile(formatted_data_dir, [probe_fnames{probe_i}, '.mat']);
        
        % load the formatted data
        data = load_data(formatted_data_fname);
        
        % get selected clusters
        selected_clusters = get_selected_clusters(data);
        
        % store number of clusters
        n_clusters = length(selected_clusters);
        
        % create object array handling firing rates
        for cluster_i = 1 : n_clusters
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
        
        % store whether to reject the trial (by default accept)
        accept_trial = true(n_trials, 1);
        
        % store the mismatch onset time for each trial (in probe time)
        mm_start_t  = nan(n_trials, 1);
        
        % spike convolution for each cluster for each trial
        fr_convolution = cell(n_trials, n_clusters);
        
        % store baseline firing rate
        fr_baseline = nan(n_trials, n_clusters);
        
        % for each trial, get protocol type, gain direction, mismatch
        % start time, whether it is a botched trial, and the spike
        % convolution for each cluster
        for trial_i = 1 : n_trials
            
            % save protocol and gain direction
            protocol{trial_i} = trials(trial_i).protocol;
            gain_dir{trial_i} = trials(trial_i).config.gain_direction;
            
            % start of and end of mismatch window
            mm_start_sample = find(diff(trials(trial_i).teensy_gain > 2.5) == 1) + 1;
            mm_end_sample = find(diff(trials(trial_i).teensy_gain > 2.5) == -1) + 1;
            mm_start_t(trial_i) = trials(trial_i).probe_t(mm_start_sample);
            mm_end_t = trials(trial_i).probe_t(mm_end_sample);
            
            % reject trials in which the mismatch window is < 50ms
            if mm_end_t - mm_start_t(trial_i) < 0.05
                accept_trial(trial_i) = false;
            end
            
            % time base of response window
            response_window_time_base = mm_start_t(trial_i) + common_time_base;
            
            % start and end of baseline period
            baseline_window = mm_start_t(trial_i) + [-avg_window_t, 0];
            
            % for each cluster, get the convolved firing rate in the "response window" 
            for cluster_i = 1 : n_clusters
                
                % convolved firing rate for each cluster for each trial
                fr_convolution{trial_i, cluster_i} = ...
                    cluster_fr(cluster_i).get_convolution(response_window_time_base)';
                
                % can get the baseline period here
                fr_baseline(trial_i, cluster_i) = ...
                    cluster_fr(cluster_i).get_fr_in_window(baseline_window);
            end
        end
        
        % store the time of the max and min response (averaged over all
        % trials in a protocol), relative to the mismatch onset
        response_max_t{probe_i} = nan(n_protocols, n_clusters);
        response_min_t{probe_i} = nan(n_protocols, n_clusters);
        
        % loop over protocols and get the peak response time for each
        % cluster
        for prot_i = 1 : n_protocols
            
            % index of trials with this protocol and gain direction
            this_protocol_flag = strcmp(protocols{prot_i}, protocol) & ...
                strcmp(gain_directions{prot_i}, gain_dir) & ...
                accept_trial;
            
            for cluster_i = 1 : n_clusters
                
                % concatentate all responses for cluster, for protocol
                fr_conv_cat = cat(2, fr_convolution{this_protocol_flag, cluster_i});
                
                % get mean firing rate for this cluster, this protocol
                mean_fr = mean(fr_conv_cat, 2);
                
                % slide window across and find peak
                n_points_window = avg_window_t * 10e3;
                n_windows = length(common_time_base) - n_points_window;
                
                fr_window = nan(n_windows, 1);
                for i = 1 : n_windows
                    fr_window(i) = mean(mean_fr(i + (0:n_points_window-1)));
                end
                
                % index of max and min for cluster, for protocol
                [~, response_max_idx] = max(fr_window);
                [~, response_min_idx] = min(fr_window);
                
                % time of max and min response relative to mismatch onset
                response_max_t{probe_i}(prot_i, cluster_i) = common_time_base(response_max_idx);
                response_min_t{probe_i}(prot_i, cluster_i) = common_time_base(response_min_idx);
                
                if prot_i == 1
                    c = c + 1;
                end
                
                max_response_time(c, 1) = probe_i;
                max_response_time(c, 2) = selected_clusters(cluster_i).id;
                max_response_time(c, 2+prot_i) = response_max_t{probe_i}(prot_i, cluster_i);
                
                min_response_time(c, 1) = probe_i;
                min_response_time(c, 2) = selected_clusters(cluster_i).id;
                min_response_time(c, 2+prot_i) = response_min_t{probe_i}(prot_i, cluster_i);
            end
        end
        
        % store max and min response firing rates
        fr_response_max = nan(n_trials, n_clusters);
        fr_response_min = nan(n_trials, n_clusters);
        
        % again, loop over trials to get the mean firing at the peak/trough
        % of averaged response
        for trial_i = 1 : n_trials
            
            % skip botched trials
            if ~accept_trial(trial_i)
                continue
            end
            
            % get index of protocol
            prot_idx = find(strcmp(trials(trial_i).protocol, protocols) & ...
                strcmp(trials(trial_i).config.gain_direction, gain_directions));
            
            for cluster_i = 1 : n_clusters
                
                % get start and end points of "response" window to average
                % firing rate
                response_max_window = mm_start_t(trial_i) + response_max_t{probe_i}(prot_idx, cluster_i) + [0, avg_window_t];
                response_min_window = mm_start_t(trial_i) + response_min_t{probe_i}(prot_idx, cluster_i) + [0, avg_window_t];
                
                % get the response firing rate
                fr_response_max(trial_i, cluster_i) = ...
                    cluster_fr(cluster_i).get_fr_in_window(response_max_window);
                fr_response_min(trial_i, cluster_i) = ...
                    cluster_fr(cluster_i).get_fr_in_window(response_min_window);
                
                
                % append to table
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
                
                T.max_t(r) = response_max_t{probe_i}(prot_idx, cluster_i);
                T.min_t(r) = response_min_t{probe_i}(prot_idx, cluster_i);
                T.fr_baseline(r) = fr_baseline(trial_i, cluster_i);
                T.fr_response_max(r) = fr_response_max(trial_i, cluster_i);
                T.fr_response_min(r) = fr_response_min(trial_i, cluster_i);
                
            end
        end
    end
end

if save_on
    save(save_matfname, 'T', 'peak_window_t', 'avg_window_t', 'response_max_t', 'response_min_t');
end