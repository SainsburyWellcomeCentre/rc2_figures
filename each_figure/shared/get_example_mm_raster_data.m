function [spike_times, t, mean_trace, sd_trace] = get_example_mm_raster_data(data, probe_id, cluster_id, trial_group_label, padding, fs)

ctl                 = RC2Analysis();

if isempty(data)
    this_data           = ctl.load_formatted_data(probe_id);
else
    this_data           = get_data_for_probe_id(data, probe_id);
end

these_trials        = this_data.get_trials_with_trial_group_label(trial_group_label);
n_trials            = length(these_trials);

% spike times
this_cluster        = this_data.get_cluster_with_id(cluster_id);


mm_start_t = nan(1, n_trials);
for ii = 1 : n_trials
    mm_start_t(ii) = these_trials{ii}.mismatch_onset_t();
end


t = this_data.timebase(padding, fs);
spike_times = cell(1, n_trials);
fr_conv = nan(length(t), n_trials);

for ii = 1 : n_trials
    
    start_time = mm_start_t(ii);
    
    fr_conv(:, ii) = this_cluster.fr.get_convolution(start_time + t);
    
    spike_idx = this_cluster.spike_times > (start_time + padding(1)) & ...
                this_cluster.spike_times < (start_time + padding(2));
    spike_times{ii} = this_cluster.spike_times(spike_idx) - start_time;
end

mean_trace = mean(fr_conv, 2);
sd_trace = std(fr_conv, [], 2) / sqrt(n_trials);
