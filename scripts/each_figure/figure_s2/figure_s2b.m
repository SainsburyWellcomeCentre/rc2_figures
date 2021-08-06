function figure_s2b(data, h_ax)

VariableDefault('h_ax', []);
if isempty(h_ax)
    h_ax = gca();
    hold on;
end

% for replication with previous versions
restrict_trials         = false;
weird_cluster_remove    = true;



recording_ids       = experiment_details('visual_flow');

x_meta.protocol = 'ReplayOnly';
x_meta.motion = false;
x_meta.gain_dir = '';
if restrict_trials
    x_meta.replay_of = 'Coupled';
else
    x_meta.replay_of = '';
end

y_meta.protocol = 'ReplayOnly';
y_meta.motion = true;
y_meta.gain_dir = '';
if restrict_trials
    y_meta.replay_of = 'Coupled';
else
    y_meta.replay_of = '';
end

[x_med, y_med, ~, change, info] = unity_plot_data(data, recording_ids, x_meta, y_meta, restrict_trials);



if weird_cluster_remove
    zero_issue = [info(:).odd_zero_issue];
    change(zero_issue) = {'no_change'};
end

%% Plot

fmt.xy_limits = [0, 70];
fmt.tick_space = 20;
fmt.line_order = 'top';
fmt.xlabel = 'FR baseline (Hz)';
fmt.ylabel = 'FR VF (Hz)';
fmt.include_inset = false;

unity_plot_plot(h_ax, x_med, y_med, change, fmt);
