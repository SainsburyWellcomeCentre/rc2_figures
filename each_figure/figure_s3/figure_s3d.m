function figure_s3d(data, h_ax)

% for replication with previous versions
restrict_trials         = false;
weird_cluster_remove    = false;

recording_ids       = experiment_details('visual_flow');

x_meta.protocol     = 'ReplayOnly';
x_meta.motion       = true;
x_meta.gain_dir     = '';
x_meta.replay_of    = '';

y_meta.protocol     = 'StageOnly';
y_meta.motion       = true;
y_meta.gain_dir     = '';
y_meta.replay_of    = '';

[x_med, y_med, ~, ~, info] = unity_plot_data(data, recording_ids, x_meta, y_meta, restrict_trials);


if weird_cluster_remove
    zero_issue = [info(:).odd_zero_issue];
    change(zero_issue) = {'no_change'};
end

spike_class = [info(:).spike_class];

%% Plot

fmt.xy_limits = [0, 70];
fmt.tick_space = 20;
fmt.line_order = 'bottom';
fmt.xlabel = 'FR VF (Hz)';
fmt.ylabel = 'FR VF+T (Hz)';
fmt.include_inset = true;
fmt.colour_by = 'spike_class';


unity_plot_plot(h_ax, x_med, y_med, spike_class, fmt);
