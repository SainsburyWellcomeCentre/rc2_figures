function figure_2a(data, h_ax)

probe_id            = 'CAA-1112872_rec1_rec1b_rec2_rec3';
trial_id            = 33;
padding             = [-1.1, 1.1];
fs                  = 10000;

traces_to_plot      = {'running', 'visual_flow', 'translation'};
vertical_spacing    = containers.Map({'translation', 'visual_flow', 'running'}, {7, 65, 120});
gain_offsets        = containers.Map({'translation', 'visual_flow', 'running'}, {0, 65, 120});
gain_heights        = containers.Map({'translation', 'visual_flow', 'running'}, {22.2209, 22.2209 0});


%% Data
if isempty(data)
    ctl             = RC2Analysis();
    this_data       = ctl.load_formatted_data(probe_id);
else
    this_data       = get_data_for_probe_id(data, probe_id);
end

[t, traces, t_off]  = get_example_mm_trace_data(this_data, trial_id, padding, fs);


%% Plot
fmt.print_slip = true;

plot_example_mm_trace_data(h_ax, t, traces, t_off, traces_to_plot, vertical_spacing, gain_offsets, gain_heights, fmt);
