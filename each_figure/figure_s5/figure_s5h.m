function figure_s5h(data, h_ax)

probe_id    = 'CA_176_3_rec1_rec2_rec3';
cluster_id  = 274;
trial_id    = 25;
bout_n      = 1;
padding     = [-3, 3];
fs          = 10000;

traces_to_plot = {'running', 'translation'};
vertical_spacing = containers.Map({'translation', 'running'}, {30, 80});


%% Data
if isempty(data)
    ctl = RC2Analysis();
    this_data = ctl.load_formatted_data(probe_id);
else
    this_data = get_data_for_probe_id(data, probe_id);
end

[t, traces, spike_times] = get_example_trace_data(this_data, trial_id, bout_n, cluster_id, padding, fs);


%% Plot
plot_example_trace_data(h_ax, t, traces, spike_times, traces_to_plot, vertical_spacing);


%% Annotate

% scale bars
x_scale_bar_duration    = 1;  % s
x_scale_bar_end         = t(end);
x_scale_bar_y_pos       = -5;

line(h_ax, x_scale_bar_end + [-x_scale_bar_duration, 0], x_scale_bar_y_pos([1, 1]), 'color', 'k', 'linewidth', 0.5);
text(h_ax, x_scale_bar_end-x_scale_bar_duration/2, x_scale_bar_y_pos, sprintf('%is', x_scale_bar_duration), ...
    'color', 'k', ...
    'horizontalalignment', 'center', ...
    'verticalalignment', 'top', ...
    'fontsize', 8);


y_scale_bar_height      = 20;  % cm/s
y_scale_bar_start       = 90;
y_scale_bar_x_pos       = t(end)+0.2;

line(h_ax, y_scale_bar_x_pos([1, 1]), y_scale_bar_start + [0, y_scale_bar_height], 'color', 'k', 'linewidth', 0.5);
text(h_ax, y_scale_bar_x_pos, y_scale_bar_start + y_scale_bar_height/2, sprintf('%icm/s', y_scale_bar_height), ...
        'color', 'k', ...
        'horizontalalignment', 'center', ...
        'verticalalignment', 'bottom', ...
        'rotation', 270, ...
        'fontsize', 8);