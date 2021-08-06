function figure_s2a(data, h_ax)

VariableDefault('h_ax', []);
if isempty(h_ax)
    h_ax = gca();
    hold on;
end

recording_ids       = experiment_details('visual_flow');

force_replication   = false;  % forces replication of old 'results', even though method should change

x_meta.protocol     = 'Coupled';
x_meta.motion       = false;
y_meta.protocol     = 'Coupled';
y_meta.motion       = true;

[x_med, y_med, ~, change, info] = unity_plot_data(data, recording_ids, x_meta, y_meta, force_replication);


recording_ids       = experiment_details('mismatch_nov20');

x_meta.protocol     = 'CoupledMismatch';
x_meta.gain_dir     = 'up';
x_meta.motion       = false;
y_meta.protocol     = 'CoupledMismatch';
y_meta.gain_dir     = 'up';
y_meta.motion       = true;

[x_med_, y_med_, ~, change_, info_] = unity_plot_data(data, recording_ids, x_meta, y_meta, force_replication);

x_med = [x_med(:); x_med_(:)];
y_med = [y_med(:); y_med_(:)];
change = [change(:); change_(:)];
info = [info(:); info_(:)];



%% Plot

fmt.xy_limits = [0, 70];
fmt.tick_space = 20;
fmt.line_order = 'top';
fmt.xlabel = 'FR baseline (Hz)';
fmt.ylabel = 'FR R+VF+T (Hz)';
fmt.include_inset = false;

unity_plot_plot(h_ax, x_med, y_med, change, fmt);



