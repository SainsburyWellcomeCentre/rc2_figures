function heatmap = get_rvt_heatmap(data)

%
baseline_t      = [-0.4, 0];
response_t      = [0, 0.4];
heatmap_padding = [-1, 1];

% waveforms
config         = config_rc2_analysis();

recording_ids  = experiment_details('visual_flow', 'protocols');
recording_ids  = [recording_ids, experiment_details('mismatch_nov20', 'protocols')];


% common timebase on which to compute the firing rates
n_samples = ceil(range(heatmap_padding)*10000);
common_t = linspace(heatmap_padding(1), heatmap_padding(2), n_samples)';
baseline_idx = common_t < baseline_t(2) & common_t >= baseline_t(1);


all_cluster_fr  = [];
p_all           = [];
is_increase     = [];
store_spiking_class   = {};

for rec_i = 1 : length(recording_ids)
    
    this_data       = get_data_for_recording_id(data, recording_id);
    clusters        = this_data.VISp_clusters([], spiking_class);
    
    if isempty(clusters)
        error('no VISp clusters: %s', recording_id);
    end
    
    exp_obj = get_experiment(this_data, config);
    
    if strcmp(data.experiment_type, 'visual_flow')
        protocol_id = 1;
    else
        protocol_id = 2;
    end
    
    % get time of motion bout onsets for this protocol
    motion_bouts = exp_obj.motion_bouts_by_protocol(protocol_id, true, true);
    motion_bouts = motion_bouts([motion_bouts(:).duration] > 2);
    
    if isempty(motion_bouts)
        continue
    end
    
    start_t = [motion_bouts(:).start_time];
    
    for cluster_i = 1 : length(clusters)
        
        fr = FiringRate(clusters(cluster_i).spike_times);
        cluster_fr = nan(n_samples, length(motion_bouts));
        
        for bout_i = 1 : length(motion_bouts)
            
            this_t = start_t(bout_i) + common_t;
            cluster_fr(:, bout_i) = fr.get_convolution(this_t);
        end
        
        avg_fr = mean(cluster_fr, 2);
        
        % subtract baseline
        all_cluster_fr(:, end+1) = avg_fr - mean(avg_fr(baseline_idx));
        store_spiking_class{end+1} = clusters(cluster_i).duration < 0.45;
        
        % get significant clusters
        x           = exp_obj.trial_stationary_fr(clusters(cluster_i).id, protocol_id);
        y           = exp_obj.trial_motion_fr(clusters(cluster_i).id, protocol_id);
        
        [~, ~, p_all(end+1, 1), is_increase(end+1, 1)] = compare_groups_with_signrank(x, y);
    end
end

% the delta FR response for each cluster to this protocol
delta_response      = mean(all_cluster_fr(response_idx, :), 1);

% index of clusters, sorted by magnitude of response
[~, sorted_idx]     = sort(delta_response, 'ascend');

heatmap             = all_cluster_fr(:, sorted_idx)';

