function figure_s2b(data, h_ax)

VariableDefault('h_ax', []);
if isempty(h_ax)
    h_ax = gca();
    hold on;
end

% replication
restrict_trials     = false;
account_for_cluster = true;


%%
recording_ids       = experiment_details('visual_flow');


x_meta.protocol = 'ReplayOnly';
x_meta.motion = false;
x_meta.gain_dir = '';
x_meta.replay_of = 'Coupled';

y_meta.protocol = 'ReplayOnly';
y_meta.motion = true;
x_meta.gain_dir = '';
y_meta.replay_of = 'Coupled';



[x_med, y_med, ~, change, info] = unity_plot_data(data, recording_ids, x_meta, y_meta, restrict_trials);

if account_for_cluster
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