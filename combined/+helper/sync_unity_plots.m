function sync_unity_plots(u)

m = inf;
M = -inf;

for i = 1 : length(u)
    m = min([m, get(u{i}.ax, 'xlim'), get(u{i}.ax, 'ylim')]);
    M = max([M, get(u{i}.ax, 'xlim'), get(u{i}.ax, 'ylim')]);
end

for i = 1 : length(u)
    set(u{i}.ax, 'xlim', [m, M], 'ylim', [m, M]);
    set(u{i}.line, 'xdata', [m, M], 'ydata', [m, M]);
    set(u{i}.txt, 'position', [M, m]);
end
