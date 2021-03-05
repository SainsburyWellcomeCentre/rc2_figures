function probe_layout(data)

level = floor((double(0:201))/2)+1;
x = repmat([1, 3, 2, 4], ceil(202/4), 1)';
x = x(1:202);

cmap = colormap('parula');

figure; hold on
for i = 1 : length(data)
    i
    idx = round(1 + 63*(data(i) - min(data)) / (max(data) - min(data)));
    if isnan(idx); continue; end
    fill([x(i)-0.5, x(i)+0.5, x(i)+0.5, x(i)-0.5], ...
         [level(i)-0.5, level(i)-0.5, level(i)+0.5, level(i)+0.5], ...
         cmap(idx, :))
end