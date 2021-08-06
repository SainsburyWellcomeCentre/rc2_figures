function figure_s2a(data, h_ax)

VariableDefault('h_ax', []);
if isempty(h_ax)
    h_ax = gca();
    hold on;
end

% for replication with previous versions
restrict_trials         = false;
weird_cluster_remove    = true;



recording_ids       = experiment_details('visual_flow');

x_meta.protocol     = 'Coupled';
x_meta.motion       = false;
x_meta.gain_dir     = '';
x_meta.replay_of    = '';

y_meta.protocol     = 'Coupled';
y_meta.gain_dir     = '';
y_meta.motion       = true;
y_meta.replay_of    = '';

[x_med, y_med, ~, change, info] = unity_plot_data(data, recording_ids, x_meta, y_meta, restrict_trials);



recording_ids       = experiment_details('mismatch_nov20');

x_meta.protocol     = 'CoupledMismatch';
x_meta.motion       = false;
x_meta.gain_dir     = 'up';
x_meta.replay_of    = '';

y_meta.protocol     = 'CoupledMismatch';
y_meta.motion       = true;
y_meta.gain_dir     = 'up';
y_meta.replay_of    = '';

[x_med_, y_med_, ~, change_, info_] = unity_plot_data(data, recording_ids, x_meta, y_meta, restrict_trials);



x_med = [x_med(:); x_med_(:)];
y_med = [y_med(:); y_med_(:)];
change = [change(:); change_(:)];
info = [info(:); info_(:)];



if weird_cluster_remove
    zero_issue = [info(:).odd_zero_issue];
    change(zero_issue) = {'no_change'};
end

%% Plot

fmt.xy_limits = [0, 70];
fmt.tick_space = 20;
fmt.line_order = 'top';
fmt.xlabel = 'FR baseline (Hz)';
fmt.ylabel = 'FR R+VF+T (Hz)';
fmt.include_inset = false;

unity_plot_plot(h_ax, x_med, y_med, change, fmt);
