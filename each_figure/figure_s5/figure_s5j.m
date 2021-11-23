function figure_s5j(data, h_ax)

experiment_groups   = {'darkness', 'mismatch_darkness_oct21'};
R_trial_groups      = {'R'};
RT_trial_groups     = {'RT', 'RT_gain_up'};


%% Data
[x_median, y_median, direction, spike_class] = ...
    unity_plot_data(data, experiment_groups, R_trial_groups, RT_trial_groups, inf);



%% Print
fprintf('\n\nFigure S5J, R vs. R+T\n');
print_unity_plot_stats(x_median, y_median, direction, spike_class);


%% Plot
fmt.xy_limits       = [0, 20];
fmt.tick_space      = 5;
fmt.line_order      = 'top';
fmt.xlabel          = 'FR R (Hz)';
fmt.ylabel          = 'FR R+T (Hz)';
fmt.include_inset   = false;
fmt.colour_by       = 'significance';

unity_plot_plot(h_ax, x_median, y_median, direction, fmt);
