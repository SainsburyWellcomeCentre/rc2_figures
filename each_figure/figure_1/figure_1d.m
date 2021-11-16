function figure_1d(data, h_ax)
%%Figure 1D

probe_id            = 'CAA-1110264_rec1_rec2';
cluster_id          = 209;
trial_id            = 42;
bout_n              = 1;
padding             = [-3, 3];
fs                  = 10000;

traces_to_plot      = {'visual_flow', 'translation'};
vertical_spacing    = containers.Map({'translation', 'visual_flow'}, {20, 45});


%% Data
if isempty(data)
    ctl             = RC2Analysis();
    this_data       = ctl.load_formatted_data(probe_id);
else
    this_data       = get_data_for_probe_id(data, probe_id);
end

[t, traces, spike_times] = get_example_trace_data(this_data, trial_id, bout_n, cluster_id, padding, fs);


%% Plot
plot_example_trace_data(h_ax, t, traces, spike_times, traces_to_plot, vertical_spacing);
