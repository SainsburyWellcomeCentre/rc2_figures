function figure_s3d(data, h_ax)

ctl                     = RC2Analysis();
probe_ids               = ctl.get_probe_ids('visual_flow');
x_trial_group_labels    = {'V_RVT', 'V_RV'};
y_trial_group_labels    = {'VT_RVT', 'VT_RV'};
threshold_ms            = 0.45;


%% Data

c                       = 0;
x_med                   = [];
y_med                   = [];
direction               = [];
spike_class             = [];

for ii = 1 : length(probe_ids)
    
    if isempty(data)
        this_data = ctl.load_formatted_data(probe_ids{ii});
    else
        this_data = get_data_for_probe_id(data, probe_ids{ii});
    end
    
    clusters = this_data.VISp_clusters();
    
    for jj = 1 : length(clusters)
        
        c = c + 1;
        
        [~, ~, direction(c), x_med(c), y_med(c)] = this_data.is_motion_vs_motion_significant(clusters(jj).id, x_trial_group_labels, y_trial_group_labels);
        
        spike_class(c) = clusters(jj).duration < threshold_ms;
    end
end


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

unity_plot_plot(h_ax, x_med, y_med, spike_class, fmt);

% histograms
counts = add_unity_plot_histogram(h_ax, x_med(spike_class == 0), y_med(spike_class == 0), bin_width, cols('wide_spiking'));
add_unity_plot_histogram(h_ax, x_med(spike_class == 1), y_med(spike_class == 1), bin_width, cols('narrow_spiking'), 'fill', true, max(counts));
