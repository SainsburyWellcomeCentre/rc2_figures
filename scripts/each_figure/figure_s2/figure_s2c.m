function figure_s2c(data, h_ax)

recording_ids       = experiment_details('visual_flow');

x_meta.protocol = 'EncoderOnly';
x_meta.motion = false;
y_meta.protocol = 'EncoderOnly';
y_meta.motion = true;

[x_med, y_med, p_val, change] = unity_plot_data(data, recording_ids, x_meta, y_meta);


%% Plot

fmt.xy_limits = [0, 70];
fmt.tick_space = 20;
fmt.line_order = 'top';
fmt.xlabel = 'FR baseline (Hz)';
fmt.ylabel = 'FR R+VF (Hz)';
fmt.include_inset = false;

unity_plot_plot(h_ax, x_med, y_med, change, fmt);