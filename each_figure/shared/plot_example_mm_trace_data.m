function plot_example_mm_trace_data(h_ax, t, traces, t_off, traces_to_plot, vertical_spacing, gain_offsets, gain_heights, fmt)

cols                = get_colours();
symbols             = get_symbols();

size_30cmps         = 4.998; % size of scale bar in mm on page (determines axis limits)

axis_position = normpos2mmpos(get(h_ax, 'position'));
axis_height = axis_position(4);
y_size = 30*(axis_height / size_30cmps);
patch(h_ax, 'xdata', [0, t_off, t_off, 0], 'ydata', [0, 0, y_size, y_size], 'facecolor', [0.9, 0.9, 0.9], 'edgecolor', 'none');

if fmt.print_slip
    text(h_ax, 0.125, y_size, 'slip', ...
            'color', 'k', ...
            'fontsize', 6, ...
            'horizontalalignment', 'center', ...
            'verticalalignment', 'top');
end

text_offset = (t(end)-t(1))*(0.1/6);

for ii = 1 : length(traces_to_plot)

    plot(h_ax, t, traces(traces_to_plot{ii}) + vertical_spacing(traces_to_plot{ii}), ...
        'color', cols(traces_to_plot{ii}))
    
    
    gain_trace = get_gain_trace(t, t_off, gain_heights(traces_to_plot{ii}));
    
    plot(h_ax, t, gain_offsets(traces_to_plot{ii}) + gain_trace, 'color', cols(traces_to_plot{ii}));
    
    text(h_ax, t(1)-text_offset, vertical_spacing(traces_to_plot{ii}), symbols(traces_to_plot{ii}), ...
            'color', cols(traces_to_plot{ii}), ...
            'fontsize', 8, ...
            'horizontalalignment', 'right', ...
            'verticalalignment', 'bottom');

    text(h_ax, t(1), gain_offsets(traces_to_plot{ii}), 'gain', ...
            'color', cols(traces_to_plot{ii}), ...
            'fontsize', 6, ...
            'horizontalalignment', 'left', ...
            'verticalalignment', 'top');
     
end

xlim(h_ax, t([1, end]));
ylim(h_ax, [0, y_size]);
axis(h_ax, 'off');
set(h_ax, 'clipping', 'off');


%% Annotate

% scale bars
line(h_ax, [t(end)-0.5, t(end)], [-15, -15], 'color', 'k', 'linewidth', 0.5);
line(h_ax, [t(end), t(end)]+0.1, [0, 30], 'color', 'k', 'linewidth', 0.5);
text(h_ax, t(end)-0.25, -18, '0.5s', 'color', 'k', 'horizontalalignment', 'center', 'verticalalignment', 'top', 'fontsize', 8);
text(h_ax, t(end)+0.1, 15, '30cm/s', 'color', 'k', 'horizontalalignment', 'center', 'verticalalignment', 'bottom', 'rotation', 270, 'fontsize', 8);



function gain_trace = get_gain_trace(t, t_off, h)

gain_trace = zeros(1, length(t));

up_idx = t >= 0 & t < 0.05;
gain_trace(up_idx) = h * (0:sum(up_idx)-1) / sum(up_idx);

flat_idx = t >= 0.05 & t < t_off - 0.05;
gain_trace(flat_idx) = h;

down_idx = t >= t_off - 0.05 & t < t_off;
gain_trace(down_idx) = h * (sum(down_idx)-1:-1:0) / sum(down_idx);
