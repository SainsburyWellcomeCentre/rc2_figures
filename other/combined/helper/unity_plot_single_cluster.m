function u = unity_plot_single_cluster(T2, idx_main, h_ax)

assert(sum(idx_main) == 1);
T2 = T2(idx_main, :);

scatter(h_ax, T2.all_x{1}(1:T2.N), T2.all_y{1}(1:T2.N), 10, [0.5, 0.5, 0.5], 'fill');

% format
m = min([get(gca, 'xlim'), get(gca, 'ylim')]);
M = max([get(gca, 'xlim'), get(gca, 'ylim')]);

set(h_ax, 'xlim', [m, M], 'ylim', [m, M]);
u.line = line(h_ax, [m, M], [m, M], 'linestyle', '--', 'color', 'k');

x_med = nanmedian(T2.all_x{1}(1:T2.N));
y_med = nanmedian(T2.all_y{1}(1:T2.N));
x_iqr = prctile(T2.all_x{1}(1:T2.N), [25, 75]);
y_iqr = prctile(T2.all_y{1}(1:T2.N), [25, 75]);
p_median = signrank(T2.all_x{1}(1:T2.N), T2.all_y{1}(1:T2.N));

if p_median < 0.05 && x_med > y_med
    col = [30,144,255]/255;
elseif p_median < 0.05 && x_med < y_med
    col = 'r';
elseif p_median < 0.05 && x_med == y_med
    col = 'm';
else
    col = 'k';
end

scatter(h_ax, x_med, y_med, 20, col, 'fill');
line(h_ax, x_iqr, y_med([1, 1]), 'color', col);
line(h_ax, x_med([1, 1]), y_iqr, 'color', col);

if p_median < 0.01
    txt_str = sprintf('p = %.2e', p_median);
else
    txt_str = sprintf('p = %.2f', p_median);
end
u.txt = text(h_ax, M, m, txt_str, 'verticalalignment', 'bottom', 'horizontalalignment', 'right');
u.ax = h_ax;
