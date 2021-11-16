function modulation_index_plot(h_ax, modulation_index, direction, avg_anatomy, averaged_cortical_position, fmt)

cols                = get_colours();

x_limits            = [-1, 1];
histogram_edges     = -1:0.1:1;

% dimensions of axes
layer_height_mm     = 20.451;  % distance in mm from lowest to highest cortical layer
axis_to_layers_mm   = 8.331;   % distance from bottom of axis to lowest cortical layer
subaxis_height_mm   = 3.765;   % height of the histogram axis
subaxis_y_offset    = 1.093;   % offset in mm from bottom of axis to histogram

% get averaged VISp layer boundaries
boundaries = avg_anatomy.average_VISp_boundaries_from_pia;
% merge VISp6a and VIS6b
layer_str = {'L1', 'L2/3', 'L4', 'L5', 'L6'};
boundaries(end-1) = [];

% amount of space for histogram at bottom in y-axis units
cortical_thickness = range(avg_anatomy.average_VISp_boundaries_from_pia);
space_for_histogram = cortical_thickness * (axis_to_layers_mm / layer_height_mm); 

% y-limits of the whole axis including the histogram at bottom (we will
% reverse the y-axis later, so for now space is at the top)
y_limits = [boundaries(1), boundaries(end) + space_for_histogram];

% plot the boundaries and text
for ii = 1 : length(boundaries)
    
    line(h_ax, x_limits, boundaries([ii, ii]), 'color', 'k', 'linewidth', 0.5, 'linestyle', '--');
    
    % print layer text
    if ii < length(boundaries)
        x_pos = x_limits(1) - 0.15 * range(x_limits);
        text(h_ax, x_pos, mean(boundaries([ii, ii+1])), layer_str{ii}, ...
                'color', 'k', ...
                'fontsize', 8, ...
                'horizontalalignment', 'center', ...
                'verticalalignment', 'middle');
    end
end



idx = direction == 0;
scatter(h_ax, modulation_index(idx), averaged_cortical_position(idx), scatterball_size(0.73), [0.5, 0.5, 0.5]);
n_no_change = histcounts(modulation_index(idx), histogram_edges);

idx = direction == 1;
scatter(h_ax, modulation_index(idx), averaged_cortical_position(idx), scatterball_size(1.25), cols('sig_increase'));
n_increase = histcounts(modulation_index(idx), histogram_edges);

idx = direction == -1;
scatter(h_ax, modulation_index(idx), averaged_cortical_position(idx), scatterball_size(1.25), cols('sig_decrease'));
n_decrease = histcounts(modulation_index(idx), histogram_edges);



set(h_ax, 'xlim', x_limits, ...
          'xtick', [-1, 0, 1], ...
          'ylim', y_limits, ...
          'ycolor', 'none', ...
          'ydir', 'reverse', ...
          'fontsize', 8, ...
          'color', 'none');

xlabel(h_ax, fmt.x_label, 'fontsize', 8);
      
% position of the axis we have just used to plot depth vs MI
original_axis_position = get(h_ax, 'position');

% height of axis for histogram (ratio of original axis)
subaxis_height_ratio = subaxis_height_mm / (layer_height_mm + axis_to_layers_mm);

% height offset of this axis (ratio of original axis)
subaxis_y_offset_ratio = subaxis_y_offset / (layer_height_mm + axis_to_layers_mm);

% position of new axis
subaxis_position = [original_axis_position(1), ...
                    original_axis_position(2) + subaxis_y_offset_ratio * original_axis_position(4), ...
                    original_axis_position(3), ...
                    subaxis_height_ratio * original_axis_position(4)];

% create new axis on A4 paper
sub_h_ax = a4axis(h_ax.Parent, normpos2mmpos(subaxis_position));

% maximun count in any of the bins
max_count = max([n_no_change, n_increase, n_decrease]);

% plot the histogram as individual bins
for i = 1 : length(histogram_edges)-1
    
    if n_no_change(i) > 0
        patch(sub_h_ax, 'xdata', histogram_edges([i, i+1, i+1, i]), ...
                        'ydata', [0, 0, n_no_change(i), n_no_change(i)]/max_count, ...
                        'facecolor', [0.8, 0.8, 0.8], 'edgecolor', [0.8, 0.8, 0.8]);
    end
    
    if n_increase(i) > 0
        patch(sub_h_ax, 'xdata', histogram_edges([i, i+1, i+1, i]), ...
                        'ydata', [0, 0, n_increase(i), n_increase(i)]/max_count, ...
                        'facecolor', 'none', 'edgecolor', cols('sig_increase'));
    end
    
    if n_decrease(i) > 0
        patch(sub_h_ax, 'xdata', histogram_edges([i, i+1, i+1, i]), ...
                        'ydata', [0, 0, n_decrease(i), n_decrease(i)]/max_count, ...
                        'facecolor', 'none', 'edgecolor', cols('sig_decrease'));
    end
end

set(sub_h_ax, 'xlim', x_limits, ...
              'xtick', [], ...
              'fontsize', 8, ...
              'clipping', 'off');

% draw line from bottom of axis to top
sub_y_limits = [0, 1];
line_length = range(sub_y_limits) * ((layer_height_mm+axis_to_layers_mm-subaxis_y_offset)/subaxis_height_mm);

line(sub_h_ax, [0, 0], sub_y_limits(1) + [0, line_length], 'color', 'k', 'linewidth', 0.5);
set(sub_h_ax, 'ylim', sub_y_limits, 'ytick', sub_y_limits, 'yticklabel', [0, 1], 'layer', 'top');
ylabel(sub_h_ax, {'norm.', 'count'}, 'fontsize', 8);
