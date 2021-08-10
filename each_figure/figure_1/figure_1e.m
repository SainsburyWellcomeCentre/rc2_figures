function figure_1e(data, h_ax)

recording_id = 'CAA-1110264_rec1_rec2';
session_n = 1;
cluster_id = 209;
trial_id = 38;
bout_n = 1;
padding = [-3, 3];
fs = 10000;

traces_to_plot = {'visual_flow', 'translation'};
vertical_spacing = containers.Map({'translation', 'visual_flow'}, {20, 55});


%% Get data
[t, traces, spike_times] = ...
    get_example_trace_data(data, recording_id, session_n, cluster_id, trial_id, bout_n, padding, fs);



%% Plot
plot_example_trace_data(h_ax, t, traces, spike_times, traces_to_plot, vertical_spacing);


%% Annotations

% scale bars
line(h_ax, [t(end)-1, t(end)], [-5, -5], 'color', 'k', 'linewidth', 0.5);
line(h_ax, [t(end), t(end)]+0.2, [30, 50], 'color', 'k', 'linewidth', 0.5);

text(h_ax, t(end)-0.5, -6, '1s', 'color', 'k', 'horizontalalignment', 'center', 'verticalalignment', 'top', 'fontsize', 8);
text(h_ax, t(end)+0.2, 40, '20cm/s', 'color', 'k', 'horizontalalignment', 'center', 'verticalalignment', 'bottom', 'rotation', 270, 'fontsize', 8);
