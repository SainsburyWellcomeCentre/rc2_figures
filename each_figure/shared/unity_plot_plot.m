function unity_plot_plot(h_ax, x_med, y_med, direction, fmt)

fontsize        = 8;
linewidth       = 0.5;
cols            = get_colours();
large_ball      = 1.25;
small_ball      = 0.73;

xy_limits       = fmt.xy_limits;
tick_space      = fmt.tick_space;

% unity line
if strcmp(fmt.line_order, 'bottom')
    line(h_ax, xy_limits, xy_limits, ...
            'color', 'k', ...
            'linewidth', linewidth, ...
            'linestyle', '--');
end

% add dots
if strcmp(fmt.colour_by, 'significance')
    
    idx = direction == 0;
    scatter(h_ax, x_med(idx), y_med(idx), scatterball_size(small_ball), cols('no_change'));
    idx = direction == 1;
    scatter(h_ax, x_med(idx), y_med(idx), scatterball_size(large_ball), cols('sig_increase'));
    idx = direction == -1;
    scatter(h_ax, x_med(idx), y_med(idx), scatterball_size(large_ball), cols('sig_decrease'));
    
elseif strcmp(fmt.colour_by, 'spike_class')
    
    idx = direction == 0;
    scatter(h_ax, x_med(idx), y_med(idx), scatterball_size(large_ball), cols('wide_spiking'));
    idx = direction == 1;
    scatter(h_ax, x_med(idx), y_med(idx), scatterball_size(large_ball), cols('narrow_spiking'));
else
    error('color_by wrong')
end

% get ticks
first_tick = ceil(xy_limits(1)/tick_space)*tick_space;
these_ticks = first_tick:tick_space:xy_limits(2);
n_ticks = length(these_ticks);

% plot labels
tick_labels = arrayfun(@(x)(''), 1:n_ticks, 'uniformoutput', false);
tick_labels{1} = num2str(these_ticks(1));
tick_labels{end} = num2str(these_ticks(end));


set(h_ax, 'clipping', 'off', ...
          'fontsize', fontsize, ...
          'xlim', xy_limits, ...
          'xtick', these_ticks, ...
          'xticklabel', tick_labels, ...
          'ylim', xy_limits, ...
          'ytick', these_ticks, ...
          'yticklabel', tick_labels);

xlabel(h_ax, fmt.xlabel, 'fontsize', fontsize);
ylabel(h_ax, fmt.ylabel, 'fontsize', fontsize);

% put percentage increase and decrease
if strcmp(fmt.colour_by, 'significance')
    
    prc_increase = 100 * sum(direction == 1) / length(direction);
    prc_decrease = 100 * sum(direction == -1) / length(direction);
    
    x_position = range(xy_limits)*(3/70);
    y_position = range(xy_limits)*(40/70);
    
    
    text(h_ax, x_position, y_position, sprintf('%.1f%%', prc_increase), ...
        'fontsize', fontsize, ...
        'color', cols('sig_increase'), ...
        'horizontalalignment', 'left', ...
        'verticalalignment', 'middle');
    
    if prc_decrease < eps
        str = sprintf('%.0f%%', prc_decrease);
    else
        str = sprintf('%.1f%%', prc_decrease);
    end
    
    text(h_ax, y_position, x_position, str, ...
        'fontsize', fontsize, ...
        'color', cols('sig_decrease'), ...
        'horizontalalignment', 'center', ...
        'verticalalignment', 'bottom');
end

if strcmp(fmt.line_order, 'top')
    line(h_ax, xy_limits, xy_limits, ...
            'color', 'k', ...
            'linewidth', linewidth, ...
            'linestyle', '--');
end


% inset
if fmt.include_inset
    
    axis_position = get(h_ax, 'position');
    
    inset_offset_units  = 40;
    inset_size_units    = 20;
    inset_pad           = 3;
    inset_xy_limits     = [0, 5];
    
    inset_axis_position(1) = axis_position(1) + (inset_offset_units/xy_limits(2)) * axis_position(3);
    inset_axis_position(2) = axis_position(2) + (inset_offset_units/xy_limits(2)) * axis_position(4);
    inset_axis_position(3) = (inset_size_units/xy_limits(2)) * axis_position(3);
    inset_axis_position(4) = (inset_size_units/xy_limits(2)) * axis_position(4);
    
    patch(h_ax, 'xdata', [inset_offset_units-inset_pad, ...
        inset_offset_units+inset_size_units+inset_pad, ...
        inset_offset_units+inset_size_units+inset_pad, ...
        inset_offset_units-inset_pad], ...
        'ydata', [inset_offset_units-inset_pad, ...
        inset_offset_units-inset_pad, ...
        inset_offset_units+inset_size_units+inset_pad, ...
        inset_offset_units+inset_size_units+inset_pad], ...
        'facecolor', [0.9, 0.9, 0.9], ...
        'edgecolor', 'none');
    
    h_inset = axes('position', inset_axis_position);
    hold on;
    
    if strcmp(fmt.colour_by, 'significance')
        
        idx = direction == 0;
        scatter(h_inset, x_med(idx), y_med(idx), scatterball_size(small_ball), cols('no_change'));
        idx = direction == 1;
        scatter(h_inset, x_med(idx), y_med(idx), scatterball_size(large_ball), cols('sig_increase'));
        idx = direction == -1;
        scatter(h_inset, x_med(idx), y_med(idx), scatterball_size(large_ball), cols('sig_decrease'));
        
    elseif strcmp(fmt.colour_by, 'spike_class')
        
        idx = direction == 0;
        scatter(h_inset, x_med(idx), y_med(idx), scatterball_size(large_ball), cols('wide_spiking'));
        idx = direction == 1;
        scatter(h_inset, x_med(idx), y_med(idx), scatterball_size(large_ball), cols('narrow_spiking'));
    else
        error('color_by wrong')
    end
    
    line(h_inset, inset_xy_limits, inset_xy_limits, 'color', 'k', 'linewidth', 0.5, 'linestyle', '--');
    line(h_inset, inset_xy_limits, inset_xy_limits, 'color', 'k', 'linewidth', 0.5, 'linestyle', '--');
    
    set(h_inset, 'xlim', inset_xy_limits, ...
        'xtick', inset_xy_limits, ...
        'xticklabel', '', ...
        'ylim', inset_xy_limits, ...
        'ytick', inset_xy_limits, ...
        'yticklabel', '');
end
