function figure_s4g(data, h_ax)

probe_id    = 'CAA-1110264_rec1_rec2';
cluster_id  = 209;
trial_id    = 42;
bout_n      = 1;
padding     = [-3, 3];
fs          = 10000;

traces_to_plot = {'running', 'translation'};
vertical_spacing = containers.Map({'translation', 'running'}, {40, 65});


%% Get data
[t, traces, spike_times] = ...
    get_example_trace_data(data, probe_id, trial_id, bout_n, cluster_id, padding, fs);


%% Plot
plot_example_trace_data(h_ax, t, traces, spike_times, traces_to_plot, vertical_spacing);
