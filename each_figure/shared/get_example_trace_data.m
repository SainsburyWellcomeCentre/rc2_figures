function [t, traces, spike_times] = ...
    get_example_trace_data(this_data, trial_id, bout_n, cluster_id, padding, fs)
%%get traces (running, visual flow and translation) for trial with trial
%%ID, motion bout # within trial

trials = this_data.motion_trials();
idx = cellfun(@(x)(x.trial_id == trial_id), trials);

this_trial = trials{idx};
bouts = this_trial.motion_bouts(true, true);

idx_to_show = bouts{bout_n}.start_idx+fs*padding(1):bouts{bout_n}.end_idx+fs*padding(2);

if ~isempty(this_trial.multiplexer_output)
    traces = containers.Map({'running', 'visual_flow', 'translation'}, ...
                            {this_trial.treadmill_speed(idx_to_show), ... 
                             this_trial.multiplexer_speed(idx_to_show), ...
                             this_trial.stage_speed(idx_to_show)});
else
    traces = containers.Map({'running', 'translation'}, ...
                            {this_trial.treadmill_speed(idx_to_show), ... 
                             this_trial.stage_speed(idx_to_show)});
end
                     
t = (idx_to_show - bouts{bout_n}.start_idx) * (1/fs);

idx = [this_data.clusters(:).id] == cluster_id;
spike_times = this_data.clusters(idx).spike_times;

spike_idx = spike_times > (bouts{bout_n}.start_time + padding(1)) & ...
            spike_times < (bouts{bout_n}.end_time + padding(2));

spike_times = spike_times(spike_idx) - bouts{bout_n}.start_time;
