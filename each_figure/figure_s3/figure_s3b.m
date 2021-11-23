function figure_s3b(data, h_ax1, h_ax2)

threshold_ms        = constants('spiking_class_threshold_ms');

ctl                 = RC2Analysis();
probe_ids           = ctl.get_probe_ids('visual_flow', 'mismatch_nov20', 'mismatch_jul21');

firing_rates        = [];
durations           = [];

for ii = 1 : length(probe_ids)
    
    if isempty(data)
        this_data   = ctl.load_formatted_data(probe_ids{ii});
    else
        this_data   = get_data_for_probe_id(data, probe_ids{ii});
    end
    
    clusters        = this_data.VISp_clusters();
    
    firing_rates    = [firing_rates; [clusters(:).overall_firing_rate]'];
    durations       = [durations; [clusters(:).duration]'];
end


%% Plot

ball_size = scatterball_size(1);
narrow_colour = [0.5, 0.5, 0.5];
wide_colour = [0, 0, 0];
fontsize = 8;
x_limits = [0, 1.2];
x_ticks = 0:0.2:1.2;
y_limits = [0, 60];
y_ticks = 0:20:60;

scatter(h_ax1, durations(durations < threshold_ms), firing_rates(durations < threshold_ms), ball_size, narrow_colour, 'fill');
scatter(h_ax1, durations(durations >= threshold_ms), firing_rates(durations >= threshold_ms), ball_size, wide_colour, 'fill');

xlabel(h_ax1, 'time (ms)', 'fontsize', fontsize);
ylabel(h_ax1, 'FR (Hz)', 'fontsize', fontsize);
set(h_ax1, 'xlim', x_limits, 'xtick', x_ticks, 'ytick', y_ticks, 'fontsize', fontsize);

xtickangle(h_ax1, 0);
line(h_ax1, threshold_ms([1, 1]), y_limits, 'color', 'k', 'linestyle', '--');
title(h_ax1, {'trough-to-peak latencies', ''}, 'fontsize', fontsize, 'fontweight', 'normal');


narrow_bin_edges = 0:0.05:threshold_ms;
wide_bin_edges = threshold_ms:0.05:1.5;
y_limits    = [0, 20];
y_ticks     = 0:10:20;


histogram(h_ax2, durations(durations < threshold_ms), narrow_bin_edges, 'facecolor', narrow_colour, 'edgecolor', 'none', 'facealpha', 1);
histogram(h_ax2, durations(durations >= threshold_ms), wide_bin_edges, 'facecolor', wide_colour, 'edgecolor', 'none', 'facealpha', 1);

xlabel(h_ax2, 'time (ms)');
ylabel(h_ax2, '# clusters');
set(h_ax2, 'xlim', x_limits, 'xtick', x_ticks, 'ytick', y_ticks, 'fontsize', fontsize);
line(h_ax2, threshold_ms([1, 1]), y_limits, 'color', 'k', 'linestyle', '--');
xtickangle(h_ax2, 0);
