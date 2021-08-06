function figure_1d(data, h_ax)

recording_id = 'CAA-1110264_rec1_rec2';
session_n = 1;
cluster_id = 209;
trial_id = 42;
bout_n = 1;
padding = [-3, 3];
fs = 10000;

cols = get_colours();

traces_to_plot = {'visual_flow', 'translation'};
vertical_spacing = containers.Map({'translation', 'visual_flow'}, {20, 45});


%% Get data
[t, traces, spike_times] = ...
    get_example_trace_data(data, recording_id, session_n, cluster_id, trial_id, bout_n, padding, fs);


%% Plot
plot_example_trace_data(h_ax, t, traces, spike_times, traces_to_plot, vertical_spacing);
