function figure_s3c(data, h_ax)

[heatmap, common_t, spike_class] = figure_1c(data, 'no_plot');

fr_limits       = [-8, 8];

cluster_count   = size(heatmap, 1);
padding = common_t([1, end]);
key_size = range(padding) * (0.1/2);


%% plot
cols        = get_colours();

h_im        = imagesc(h_ax, heatmap);
set(h_im, 'xdata', common_t);

line(h_ax, [0, 0], [0.5, cluster_count+0.5], 'linestyle', '--', 'color', 'k');
colormap(h_ax, cols('red2blue_map'));

set(h_ax, 'clim', fr_limits, 'ytick', [1, cluster_count], 'xlim', padding + [-key_size, 0], ...
          'ylim', [0.5, cluster_count+0.5], 'xcolor', 'none', 'ycolor', 'none', 'yticklabel', [cluster_count, 1]);

for i = 1 : cluster_count
    
    if spike_class(i)
        col = [0.5, 0.5, 0.5];
    else
        col = [0, 0, 0];
    end
    
    fill(h_ax, padding(1)+[-key_size, 0, 0, -key_size], i + [-0.5, -0.5, 0.5, 0.5], col, 'edgecolor', 'none');
end

text_x_offset = padding(1) - range(padding) * (0.2/2);
text_y_offset = cluster_count + (3/117)*cluster_count;

text(h_ax, text_x_offset, cluster_count, sprintf('%i', 1), 'horizontalalignment', 'right', 'verticalalignment', 'middle', ...
    'fontsize', 8);
text(h_ax, text_x_offset, 1, sprintf('%i', cluster_count), 'horizontalalignment', 'right', 'verticalalignment', 'middle', ...
    'fontsize', 8);
text(h_ax, text_x_offset, (cluster_count + 1) / 2, 'cell #', 'horizontalalignment', 'center', 'verticalalignment', 'bottom', ...
    'fontsize', 8, 'rotation', 90);
text(h_ax, 0, text_y_offset, {'locomotion', 'onset'}, 'horizontalalignment', 'center', 'verticalalignment', 'bottom', ...
    'fontsize', 6);
text(h_ax, padding(1), text_y_offset, {'\color[rgb]{0.5, 0.5, 0.5}narrow-spike', '\color[rgb]{0, 0, 0}wide-spike'}, 'horizontalalignment', 'center', 'verticalalignment', 'bottom', ...
    'fontsize', 6);


% colorbar
axis_position = get(h_ax, 'position');
axis_width = axis_position(3);
axis_height = axis_position(4);

colorbar_width = (1.4/28.5) * axis_width;
colorbar_height = (13/38) * axis_height;

colorbar_position = [(axis_position(1) + axis_width) + colorbar_width, ...
                     (axis_position(2) + axis_height) - colorbar_height, ...
                     colorbar_width, colorbar_height];
                     
h_ax_colorbar = axes();

set(h_ax_colorbar, ...
    'Color',                    'w', ...
    'XColor',                   'k', ...
    'YColor',                   'k', ...
    'Units',                    'normalized', ...
    'PositionConstraint',       'innerposition', ...
    'InnerPosition',            colorbar_position, ...
    'PlotBoxAspectRatioMode',   'auto');
hold on;

dummy_map = repmat(linspace(0, 1, 64)', 1, 3);
h_im_colorbar = imagesc(dummy_map, [0, 1]);
colormap(h_ax_colorbar, cols('red2blue_map'));
set(h_ax_colorbar, 'xlim', [0.5, 3.5], 'ylim', [0.5, 64.5])
axis off
text(h_ax_colorbar, 3.5, -1, '<-8', 'color', 'k', 'horizontalalignment', 'center', 'verticalalignment', 'top', ...
    'fontsize', 8);
text(h_ax_colorbar, 3.5, 65, '>8', 'color', 'k', 'horizontalalignment', 'center', 'verticalalignment', 'bottom', ...
    'fontsize', 8);
text(h_ax_colorbar, 3.6, 65/2, '\DeltaFR (Hz)', 'color', 'k', 'horizontalalignment', 'center', 'verticalalignment', 'bottom', ...
    'fontsize', 8, 'rotation', 270);

