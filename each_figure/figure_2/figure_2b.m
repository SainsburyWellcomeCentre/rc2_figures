function figure_2b(data, h_ax1, h_ax2, h_ax3)

probe_id                = 'CAA-1112874_rec1_rec2_rec3';
cluster_id              = 187;
trial_group_label       = 'RVT_gain_up';
padding                 = [-1, 1];
fs                      = 10000;


%% Data

[spike_times, t, mean_trace, sd_trace] = get_example_mm_raster_data(data, probe_id, cluster_id, trial_group_label, padding, fs);


%% Plot
fmt.print_slip = true;

plot_example_mm_raster_data({h_ax1, h_ax2, h_ax3}, spike_times, t, mean_trace, sd_trace, fmt);
