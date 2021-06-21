% get example data
[wide_waveforms, narrow_waveforms, wide_mean, narrow_mean,  wide_isis_ms, narrow_isis_ms, t, isi_edges] = get_example_raw_waveforms();

% get waveform durations
[firing_rates, durations, recording_id, cluster_id] = get_waveform_durations();


threshold = 0.45;

%%
h_fig = a4figure();

h_label = a4figure_text('a', h_fig, [48, 297 - 18, 0, 0]);
set(h_label, 'fontsize', 12, 'fontname', 'Arial');
h_label = a4figure_text('b', h_fig, [90, 297 - 18, 0, 0]);
set(h_label, 'fontsize', 12, 'fontname', 'Arial');
h_label = a4figure_text('c', h_fig, [132, 297 - 18, 0, 0]);
set(h_label, 'fontsize', 12, 'fontname', 'Arial');
h_label = a4figure_text('d', h_fig, [132, 297 - 62, 0, 0]);
set(h_label, 'fontsize', 12, 'fontname', 'Arial');

h_ax_a_upper = a4axis(h_fig, [57, 297 - 50, 27, 27]);
h_ax_a_lower = a4axis(h_fig, [57, 297 - 93, 27, 27]);
h_ax_b_upper = a4axis(h_fig, [99, 297 - 50, 27, 27]);
h_ax_b_lower = a4axis(h_fig, [99, 297 - 93, 27, 27]);
h_ax_c = a4axis(h_fig, [141, 297 - 50, 27, 27]);
h_ax_d = a4axis(h_fig, [141, 297 - 93, 27, 27]);


% Fig S3a
plot(h_ax_a_upper, t, wide_waveforms, 'color', [0.5, 0.5, 0.5], 'linewidth', 0.25);
plot(h_ax_a_upper, t, wide_mean, 'color', [0, 0, 0], 'linewidth', 0.75);

xlabel(h_ax_a_upper, 'time (ms)');
ylabel(h_ax_a_upper, '\muVolts');
xlim(h_ax_a_upper, [-0.6, 1.2])
ylim(h_ax_a_upper, [-400, 200])
set(h_ax_a_upper, 'xtick', -0.5:0.5:1, 'ytick', -400:200:200, 'fontsize', 8, 'fontname', 'Arial');
xtickangle(h_ax_a_upper, 0);
title(h_ax_a_upper, {'putative excitatory', 'neuron'}, 'fontsize', 8, 'fontweight', 'normal', 'fontname', 'Arial');


plot(h_ax_a_lower, t, narrow_waveforms, 'color', [0.5, 0.5, 0.5], 'linewidth', 0.25);
plot(h_ax_a_lower, t, narrow_mean, 'color', [0, 0, 0], 'linewidth', 0.75);

xlabel(h_ax_a_lower, 'time (ms)');
ylabel(h_ax_a_lower, '\muVolts');
xlim(h_ax_a_lower, [-0.6, 1.2])
ylim(h_ax_a_lower, [-400, 200])
set(h_ax_a_lower, 'xtick', -0.5:0.5:1, 'ytick', -400:200:200, 'fontsize', 8, 'fontname', 'Arial');
xtickangle(h_ax_a_lower, 0);



% Fig S3a, insets
h_ax_a_upper_inset_bck = a4axis(h_fig, [73.5, 297 - 49, 15.5, 15.5]); axis off;
fill(h_ax_a_upper_inset_bck, [0, 1, 1, 0], [0, 0, 1, 1], [0.94, 0.94, 0.94], 'edgecolor', 'k', 'linewidth', 0.25);
h_ax_a_upper_inset = a4axis(h_fig, [76.75, 297 - 44, 10, 10]);
histogram(h_ax_a_upper_inset, wide_isis_ms, isi_edges, 'facecolor', 'k')
xlim(h_ax_a_upper_inset, [-30, 30]);
set(h_ax_a_upper_inset, 'xtick', -20:20:20, 'ytick', [], 'fontsize', 5, 'fontname', 'Arial', 'color', 'none');
xtickangle(h_ax_a_upper_inset, 0);
text(h_ax_a_upper_inset_bck, (8.25/15.5), 0, 'ISI (ms)', 'fontsize', 5, 'fontname', 'Arial', 'horizontalalignment', 'center', 'verticalalignment', 'bottom');
text(h_ax_a_upper_inset_bck, 0, 0.6, 'norm. count', 'fontsize', 5, 'fontname', 'Arial', 'horizontalalignment', 'center', 'verticalalignment', 'top', 'rotation', 90);

h_ax_a_lower_inset_bck = a4axis(h_fig, [73.5, 297 - 92, 15.5, 15.5]); axis off;
fill(h_ax_a_lower_inset_bck, [0, 1, 1, 0], [0, 0, 1, 1], [0.94, 0.94, 0.94], 'edgecolor', 'k', 'linewidth', 0.25);
h_ax_a_lower_inset = a4axis(h_fig, [76.75, 297 - 87, 10, 10]);
histogram(h_ax_a_lower_inset, narrow_isis_ms, isi_edges, 'facecolor', 'k')
xlim(h_ax_a_lower_inset, [-30, 30]);
set(h_ax_a_lower_inset, 'xtick', -20:20:20, 'ytick', [], 'fontsize', 5, 'fontname', 'Arial', 'color', 'none');
xtickangle(h_ax_a_lower_inset, 0);
text(h_ax_a_lower_inset_bck, (8.25/15.5), 0, 'ISI (ms)', 'fontsize', 5, 'fontname', 'Arial', 'horizontalalignment', 'center', 'verticalalignment', 'bottom');
text(h_ax_a_lower_inset_bck, 0, 0.6, 'norm. count', 'fontsize', 5, 'fontname', 'Arial', 'horizontalalignment', 'center', 'verticalalignment', 'top', 'rotation', 90);



% Fig S3b
ball_size = scatterball_size(1);
scatter(h_ax_b_upper, durations(durations < threshold), firing_rates(durations < threshold), ball_size, [0.6, 0.6, 0.6], 'fill');
scatter(h_ax_b_upper, durations(durations >= threshold), firing_rates(durations >= threshold), ball_size, [0, 0, 0], 'fill');

xlabel(h_ax_b_upper, 'time (ms)');
ylabel(h_ax_b_upper, 'FR (Hz)');
xlim(h_ax_b_upper, [0, 1.2]);
set(h_ax_b_upper, 'xtick', 0:0.2:1.2, 'ytick', 0:20:60, 'fontsize', 8, 'fontname', 'Arial');
xtickangle(h_ax_b_upper, 0);
line(h_ax_b_upper, threshold([1, 1]), get(h_ax_b_upper, 'ylim'), 'color', 'k', 'linestyle', '--');
title(h_ax_b_upper, {'trough-to-peak latencies', ''}, 'fontsize', 8, 'fontweight', 'normal', 'fontname', 'Arial');

set(h_fig, 'currentaxes', h_ax_b_lower);
histogram(durations(durations < threshold), 0:0.05:0.45, 'facecolor', [0.6, 0.6, 0.6], 'edgecolor', 'none', 'facealpha', 1);
histogram(durations(durations >= threshold), 0.45:0.05:1.5, 'facecolor', [0, 0, 0], 'edgecolor', 'none', 'facealpha', 1);

xlabel(h_ax_b_lower, 'time (ms)');
ylabel(h_ax_b_lower, '# clusters');
xlim(h_ax_b_lower, [0, 1.2]);
set(h_ax_b_lower, 'xtick', 0:0.2:1.2, 'ytick', 0:10:30, 'fontsize', 8, 'fontname', 'Arial');
line(h_ax_b_lower, threshold([1, 1]), get(h_ax_b_lower, 'ylim'), 'color', 'k', 'linestyle', '--');
xtickangle(h_ax_b_lower, 0);



print('suppfigure3.pdf', '-dpdf');

