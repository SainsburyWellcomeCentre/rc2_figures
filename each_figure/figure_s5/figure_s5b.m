function figure_s5b(data, h_ax)

ctl                 = RC2Analysis();
probe_ids           = ctl.get_probe_ids('darkness', 'mismatch_darkness_oct21');
trial_group_labels  = {'T_bank', 'T_RT', 'T_R', 'T'};


%% Data

c                   = 0;
x_med               = [];
y_med               = [];
direction           = [];
spike_class         = {};

for ii = 1 : length(probe_ids)
    
    if isempty(data)
        this_data   = ctl.load_formatted_data(probe_ids{ii});
    else
        this_data   = get_data_for_probe_id(data, probe_ids{ii});
    end
    
    clusters    = this_data.VISp_clusters();
    
    for jj = 1 : length(clusters)
        
        c = c + 1;
        [~, ~, direction(c), x_med(c), y_med(c)] = this_data.is_stationary_vs_motion_significant(clusters(jj).id, trial_group_labels);
        spike_class{c} = clusters(jj).spiking_class;
    end
end


%% Print
fprintf('\n\nFigure S5B, T, stationary vs. motion\n');
print_unity_plot_stats(x_med, y_med, direction, spike_class);


%% Plot
fmt.xy_limits       = [0, 20];
fmt.tick_space      = 5;
fmt.line_order      = 'top';
fmt.xlabel          = 'FR baseline (Hz)';
fmt.ylabel          = 'FR T (Hz)';
fmt.include_inset   = true;
fmt.colour_by       = 'significance';

unity_plot_plot(h_ax, x_med, y_med, direction, fmt);
