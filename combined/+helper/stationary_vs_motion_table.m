function T = stationary_vs_motion_table(formatted_fname)

% location of the formatted data
data = load_data(formatted_fname);

% get the probe recording name
[~, probe_fname, ~] = fileparts(formatted_fname);

warning('off', 'MATLAB:table:RowsAddedExistingVars');
T = table();
r = 0;

for trial_i = 1 : length(data.sessions(1).trials)
    
    trial = data.sessions(1).trials(trial_i);
    
    % get masks
    treadmill_motion_mask = trial.treadmill_motion_mask();
    analysis_window = trial.analysis_window();
    camera_motion_mask = trial.camera_motion_mask;
    baseline_mask = trial.baseline_mask();
    
    stationary_mask = (analysis_window & ~treadmill_motion_mask & ~camera_motion_mask) | ...
        (baseline_mask & ~camera_motion_mask);
%     stationary_mask = (analysis_window & ~treadmill_motion_mask);
    motion_mask = (analysis_window & treadmill_motion_mask);
    
    treadmill_stationary_time = sum(analysis_window & ~treadmill_motion_mask)/trial.fs;
    stationary_time = sum(stationary_mask)/trial.fs;
    motion_time = sum(motion_mask)/trial.fs;
    
    for clust_i = 1 : length(data.selected_clusters)
        
        cluster = get_cluster_by_id(data.clusters, data.selected_clusters(clust_i));
        
        % get convolved firing rate
        fr = FiringRate(cluster.spike_times);
        fr_conv = fr.get_convolution(trial.probe_t);
        
        stationary_rate = mean(fr_conv(stationary_mask));
        motion_rate = mean(fr_conv(motion_mask));
        
        r = r + 1;
        
        % fill the table
        T.probe_name{r} = probe_fname;
        T.cluster_id(r) = cluster.id;
        T.cluster_region{r} = cluster.region_str;
        T.cluster_depth(r) = cluster.depth;
        T.cluster_from_tip(r) = cluster.distance_from_probe_tip;
        T.protocol{r} = trial.protocol;
        T.replay_of{r} = trial.replay_of;
        T.trial_id(r) = trial.id;
        T.stationary_firing_rate(r) = stationary_rate;
        T.time_stationary(r) = stationary_time;
        T.time_treadmill_stationary(r) = treadmill_stationary_time;
        T.motion_firing_rate(r) = motion_rate;
        T.time_motion(r) = motion_time;
        if isfield(trial.config, 'enable_vis_stim')
            T.vis_stim(r) = str2double(trial.config.enable_vis_stim);
        end
    end
end