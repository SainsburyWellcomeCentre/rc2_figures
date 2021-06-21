function [firing_rates, durations, recording_id, cluster_id] = get_waveform_durations()

% waveforms
config         = config_rc2_analysis();
loader         = Loader(config);

recording_ids  = experiment_details('visual_flow', 'protocols');
recording_ids  = [recording_ids, experiment_details('mismatch_nov20', 'protocols')];

recording_id = [];
cluster_id = [];
firing_rates = [];
durations = [];

for rec_i = 1 : length(recording_ids)
    
    rec_i
        
    data = loader.formatted_data(recording_ids{rec_i});
    clusters = data.VISp_clusters();
    
    recording_id = [recording_id; rec_i * ones(length(clusters), 1)];
    cluster_id = [cluster_id; [clusters(:).id]'];
    firing_rates = [firing_rates; [clusters(:).firing_rate]'];
    durations = [durations; [clusters(:).duration]'];
end
