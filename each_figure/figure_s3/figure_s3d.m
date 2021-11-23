function figure_s3d(data, h_ax)

experiment_groups       = {'visual_flow'};
x_trial_group_labels    = {'V_RVT', 'V_RV'};
y_trial_group_labels    = {'VT_RVT', 'VT_RV'};


%% Data
[x_median, y_median, ~, spike_class] = ...
    unity_plot_data(data, experiment_groups, x_trial_group_labels, y_trial_group_labels, inf);


%% Plot
cols            = get_colours();
bin_width       = 2;

fmt.xy_limits = [0, 60];
fmt.tick_space = 20;
fmt.line_order = 'bottom';
fmt.xlabel = 'FR VF (Hz)';
fmt.ylabel = 'FR VF+T (Hz)';
fmt.include_inset = false;
fmt.colour_by = 'spike_class';

narrow_idx = strcmp(spike_class, 'narrow');
wide_idx = strcmp(spike_class, 'wide');

unity_plot_plot(h_ax, x_median, y_median, narrow_idx, fmt);

% histograms
counts = add_unity_plot_histogram(h_ax, x_median(wide_idx), y_median(wide_idx), bin_width, cols('wide_spiking'));
add_unity_plot_histogram(h_ax, x_median(narrow_idx), y_median(narrow_idx), bin_width, cols('narrow_spiking'), 'fill', true, max(counts));
