function figure_s3a(data, h_ax1, h_ax2)

VariableDefault('h_ax1', []);
VariableDefault('h_ax2', []);

if isempty(h_ax1)
    h_ax1 = gca();
    hold on;
end


[wide_waveforms, narrow_waveforms, wide_mean, narrow_mean,  wide_isis_ms, narrow_isis_ms, t, isi_edges] = ...
    get_example_raw_waveforms();

fontsize = 8;
x_limits = [-0.6, 1.2];
x_ticks = -0.5:0.5:1;
y_limits = [-400, 200];
y_ticks = -400:200:200;




% Fig S3a
plot(h_ax1, t, wide_waveforms, 'color', [0.5, 0.5, 0.5], 'linewidth', 0.25);
plot(h_ax1, t, wide_mean, 'color', [0, 0, 0], 'linewidth', 0.75);

xlabel(h_ax1, 'time (ms)');
ylabel(h_ax1, '\muVolts');
xlim(h_ax1, x_limits)
ylim(h_ax1, y_limits)
set(h_ax1, 'xtick', x_ticks, 'ytick', y_ticks, 'fontsize', fontsize);
xtickangle(h_ax1, 0);
title(h_ax1, {'putative excitatory', 'neuron'}, 'fontsize', fontsize, 'fontweight', 'normal');



plot(h_ax2, t, narrow_waveforms, 'color', [0.5, 0.5, 0.5], 'linewidth', 0.25);
plot(h_ax2, t, narrow_mean, 'color', [0, 0, 0], 'linewidth', 0.75);

xlabel(h_ax2, 'time (ms)');
ylabel(h_ax2, '\muVolts');
xlim(h_ax2, x_limits)
ylim(h_ax2, y_limits)
set(h_ax2, 'xtick', x_ticks, 'ytick', y_ticks, 'fontsize', fontsize);
xtickangle(h_ax2, 0);
title(h_ax2, {'putative inhibitory', 'neuron'}, 'fontsize', fontsize, 'fontweight', 'normal');



%%
plot_inset(h_ax1, wide_isis_ms, isi_edges);
plot_inset(h_ax2, narrow_isis_ms, isi_edges);



function plot_inset(h_ax, isi, isi_edges)

x_lim_hist = [-30, 30];
x_ticks_hist = -20:20:20;

axis_position = get(h_ax, 'position');

inset_1_ratio = (15.714 / 28.393);  % ratio of grey box to main axis
inset_1_x_offset = (66.895 - 50.795) / 28.393;  % amount to offset the inset
inset_1_y_offset = (50.334 - 49.406) / 28.393;  % amount to offset the inset

inset_2_ratio = (10.597 / 15.714);  % ratio of inset axes to grey box
inset_2_x_offset = (70.151 - 66.895) / 15.714;
inset_2_y_offset = (49.406 - 44.846) / 15.714;
                

inset_1_position = [axis_position(1) + inset_1_x_offset * axis_position(3), ...
                    axis_position(2) + inset_1_y_offset * axis_position(4), ...
                    axis_position(3) * inset_1_ratio, ...
                    axis_position(4) * inset_1_ratio];

inset_2_position = [inset_1_position(1) + inset_2_x_offset * inset_1_position(3), ...
                    inset_1_position(2) + inset_2_y_offset * inset_1_position(4), ...
                    inset_1_position(3) * inset_2_ratio, ...
                    inset_1_position(4) * inset_2_ratio];

h_ax_inset_1 = axes('position', inset_1_position);
fill(h_ax_inset_1, [0, 1, 1, 0], [0, 0, 1, 1], [0.94, 0.94, 0.94], 'edgecolor', 'none');
set(h_ax_inset_1, 'xlim', [0, 1], 'ylim', [0, 1]);
axis(h_ax_inset_1, 'off');

                
h_ax_inset_2 = axes('position', inset_2_position);

histogram(h_ax_inset_2, isi, isi_edges, 'facecolor', 'k');
box(h_ax_inset_2, 'off');
set(h_ax_inset_2, 'xlim', x_lim_hist, 'xtick', x_ticks_hist, 'ytick', [], 'fontsize', 5, 'fontname', 'Arial', 'color', 'none');
xtickangle(h_ax_inset_2, 0);
text(h_ax_inset_1, (8.25/15.5), 0, 'ISI (ms)', 'fontsize', 5, 'horizontalalignment', 'center', 'verticalalignment', 'bottom');
text(h_ax_inset_1, 0, 0.6, 'norm. count', 'fontsize', 5, 'horizontalalignment', 'center', 'verticalalignment', 'top', 'rotation', 90);

