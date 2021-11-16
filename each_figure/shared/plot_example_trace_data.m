function plot_example_trace_data(h_ax, t, traces, spike_times, traces_to_plot, vertical_spacing)

cols = get_colours();
symbols = get_symbols();

size_20cmps = 2.735; % size of scale bar in mm on page (determines axis limits)

text_offset = (t(end)-t(1))*(0.1/6);

for i = 1 : length(traces_to_plot)

    plot(h_ax, t, traces(traces_to_plot{i}) + vertical_spacing(traces_to_plot{i}), ...
        'color', cols(traces_to_plot{i}))
    text(h_ax, t(1)-text_offset, vertical_spacing(traces_to_plot{i}), symbols(traces_to_plot{i}), ...
         'color', cols(traces_to_plot{i}), 'horizontalalignment', 'right', ...
         'verticalalignment', 'bottom', 'fontsize', 8);
    
end

scatter(h_ax, spike_times, zeros(size(spike_times)), ...
        scatterball_size(1), 'k', 'fill', 'markerfacealpha', 0.5);

text(h_ax, t(1)-text_offset, 0, 'Sp.', ...
         'color', 'k', 'horizontalalignment', 'right', ...
         'verticalalignment', 'middle', 'fontsize', 8);
    
% format
axis_position = normpos2mmpos(get(h_ax, 'position'));
axis_height = axis_position(4);

y_size = 20*(axis_height / size_20cmps);

ylim(h_ax, -5 + [0, y_size]);
axis(h_ax, 'off');
set(h_ax, 'clipping', 'off');
