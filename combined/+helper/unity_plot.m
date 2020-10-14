function u = unity_plot(T2, idx_main, h_ax)

idx_blue = T2.p < 0.05 & T2.fr_x > T2.fr_y & idx_main;
idx_red = T2.p < 0.05 & T2.fr_x < T2.fr_y & idx_main;
idx_black = T2.p >= 0.05 & idx_main;

scatter(T2.fr_x(idx_black), T2.fr_y(idx_black), 10, 'k', 'fill');
scatter(T2.fr_x(idx_blue), T2.fr_y(idx_blue), 20, [30,144,255]/255, 'fill');
scatter(T2.fr_x(idx_red), T2.fr_y(idx_red), 20, 'r', 'fill');

% format
m = min([get(gca, 'xlim'), get(gca, 'ylim')]);
M = max([get(gca, 'xlim'), get(gca, 'ylim')]);

set(h_ax, 'xlim', [m, M], 'ylim', [m, M]);
u.line = line(h_ax, [m, M], [m, M], 'linestyle', '--', 'color', 'k');

x_med = median(T2.fr_x(idx_main));
y_med = median(T2.fr_y(idx_main));
x_iqr = prctile(T2.fr_x(idx_main), [25, 75]);
y_iqr = prctile(T2.fr_y(idx_main), [25, 75]);
p_median = signrank(T2.fr_x(idx_main), T2.fr_y(idx_main));

scatter(h_ax, x_med, y_med, [], 'g', 'fill');
line(h_ax, x_iqr, y_med([1, 1]), 'color', 'g');
line(h_ax, x_med([1, 1]), y_iqr, 'color', 'g');

txt_str = sprintf('p = %.2f \nred = %i (%i%%) \nblue = %i (%i%%)\ntotal = %i', ...
    p_median, ...
    sum(idx_red), ...
    round(100*sum(idx_red)/sum(idx_main)), ...
    sum(idx_blue), ...
    round(100*sum(idx_blue)/sum(idx_main)), ...
    sum(idx_main));
u.txt = text(h_ax, M, m, txt_str, 'verticalalignment', 'bottom', 'horizontalalignment', 'right');
u.ax = h_ax;
