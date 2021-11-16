function line_plot_plot(h_ax, bsl_1, rsp_1, bsl_2, rsp_2, fmt)

n_trials = length(bsl_1);

for i = 1 : n_trials
    line(h_ax, [1, 2], [bsl_1(i), rsp_1(i)], 'color', [0, 0, 0, 0.2], 'linewidth', 0.25);
    line(h_ax, [2, 3], [rsp_1(i), bsl_2(i)], 'color', [0, 0, 0, 0.2], 'linewidth', 0.25);
    line(h_ax, [3, 4], [bsl_2(i), rsp_2(i)], 'color', [0, 0, 0, 0.2], 'linewidth', 0.25);
end

scatter(h_ax, 1*ones(size(bsl_1)), bsl_1, scatterball_size(0.9), 'k', 'fill')
scatter(h_ax, 2*ones(size(rsp_1)), rsp_1, scatterball_size(0.9), 'k', 'fill')
scatter(h_ax, 3*ones(size(bsl_2)), bsl_2, scatterball_size(0.9), 'k', 'fill')
scatter(h_ax, 4*ones(size(rsp_2)), rsp_2, scatterball_size(0.9), 'k', 'fill')

y_labels = repmat({''}, 1, length(fmt.y_ticks));
y_labels{1} = num2str(fmt.y_ticks(1));
y_labels{end} = num2str(fmt.y_ticks(end));

set(h_ax, 'xlim', [0.5, 4.5], ...
          'xtick', [], ...
          'ylim', fmt.y_limits, ...
          'ytick', fmt.y_ticks, ...
          'yticklabel', y_labels, ...
          'fontsize', 8, ...
          'clipping', 'off');

ylabel(h_ax, 'FR (Hz)', 'fontsize', 8);

text(h_ax, 1, -2, fmt.labels{1}, 'color', 'k', 'fontsize', 8, 'horizontalalignment', 'center', 'verticalalignment', 'top');
text(h_ax, 2, -2, fmt.labels{2}, 'color', 'k', 'fontsize', 8, 'horizontalalignment', 'center', 'verticalalignment', 'top');
text(h_ax, 3, -2, fmt.labels{3}, 'color', 'k', 'fontsize', 8, 'horizontalalignment', 'center', 'verticalalignment', 'top');
text(h_ax, 4, -2, fmt.labels{4}, 'color', 'k', 'fontsize', 8, 'horizontalalignment', 'center', 'verticalalignment', 'top');
