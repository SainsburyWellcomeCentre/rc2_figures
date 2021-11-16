function [t, traces, t_off] = get_example_mm_trace_data(this_data, trial_id, padding, fs)

this_trial          = this_data.get_trials_with_trial_ids(trial_id);

mm_onset_idx        = find(diff(this_trial.teensy_gain > 2.5) == 1) + 1;
mm_offset_idx       = find(diff(this_trial.teensy_gain > 2.5) == -1) + 1;

idx_to_show = mm_onset_idx+fs*padding(1):mm_onset_idx+fs*padding(2);

traces = containers.Map({'running', 'visual_flow', 'translation'}, ...
                        {this_trial.treadmill_speed(idx_to_show), ... 
                         this_trial.multiplexer_speed(idx_to_show), ...
                         this_trial.stage_speed(idx_to_show)});

t = (idx_to_show - mm_onset_idx) * (1/fs);

t_off = t(idx_to_show == mm_offset_idx) + 0.05;
