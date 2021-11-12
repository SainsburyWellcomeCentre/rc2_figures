function [t, traces, spike_times] = ...
    get_example_trace_data(data, probe_id, trial_id, bout_n, cluster_id, padding, fs)

% get probe 
this_data = get_data_for_probe_id(data, probe_id);

trials = this_data.motion_trials();
idx = cellfun(@(x)(x.trial_id == trial_id), trials);

this_trial = trials{idx};
bouts = this_trial.motion_bouts(true, true);

idx_to_show = bouts{bout_n}.start_idx+fs*padding(1):bouts{bout_n}.end_idx+fs*padding(2);

traces = containers.Map({'running', 'visual_flow', 'translation'}, ...
                        {this_trial.treadmill_speed(idx_to_show), ... 
                         this_trial.multiplexer_speed(idx_to_show), ...
                         this_trial.stage_speed(idx_to_show)});

t = (idx_to_show - bouts{bout_n}.start_idx) * (1/fs);

idx = [this_data.clusters(:).id] == cluster_id;
spike_times = this_data.clusters(idx).spike_times;

spike_idx = spike_times > (bouts{bout_n}.start_time + padding(1)) & ...
            spike_times < (bouts{bout_n}.end_time + padding(2));

spike_times = spike_times(spike_idx) - bouts{bout_n}.start_time;
