function bin_count = add_unity_plot_histogram(h_ax, x, y, bin_width, col, fill_on, scale, count_scale)

VariableDefault('bin_width', []);
VariableDefault('col', 'k');
VariableDefault('fill_on', 'no_fill');
VariableDefault('scale', false);

% distance of all points perpendicular to unity line
points = [x(:), y(:)];

dist_to_unity = nan(size(points, 1), 1);

for p_idx = 1 : size(points, 1)
    
    % if both x and y are zero distance is zero
    %   otherwise calculation would return nan
    if points(p_idx, 1) == 0 && points(p_idx, 2) == 0
        dist_to_unity(p_idx) = 0;
        continue
    end
    
    r = norm(points(p_idx, :));
    theta = acos(sum(points(p_idx, :))/(r*sqrt(2)));
    
    if points(p_idx, 1) > points(p_idx, 2)
        dist_to_unity(p_idx) = r * sin(theta);
    else
        dist_to_unity(p_idx) = - r * sin(theta);
    end
    
end

if isempty(bin_width)
    [bin_count, bin_edges] = histcounts(dist_to_unity);
else
    % center the edges around 0
    m = floor(min(dist_to_unity) / bin_width) * bin_width;
    M = ceil(max(dist_to_unity) / bin_width) * bin_width;
    edges = m:bin_width:M;
    [bin_count, bin_edges] = histcounts(dist_to_unity, 'binedges', edges);
end



M = max([h_ax.YLim, h_ax.XLim]);
m = min([h_ax.YLim, h_ax.XLim]);

% h_limit is the middle of the axis to a corner of the axis
h_limit = (M - m) / sqrt(2);

% scale the bin counts by the h_limit
bin_height = bin_count * (h_limit / max(bin_count)) / 2;

% if we are scaling the histogram by another separate count, scale the bin
% heights
if scale
    bin_height = max(bin_count) * bin_height / count_scale;
end

% for each bin of the histogram
for bin_i = 1 : length(bin_height)
    
    % get edges of the bar
    p1 = [(M+m)/2, (M+m)/2] + [1, -1]*bin_edges(bin_i)/sqrt(2);
    p2 = [(M+m)/2, (M+m)/2] + [1, -1]*bin_edges(bin_i+1)/sqrt(2);
    p3 = p2 + bin_height([bin_i, bin_i])/sqrt(2);
    p4 = p1 + bin_height([bin_i, bin_i])/sqrt(2);
    
    % plot patch
    h_patch(bin_i) = patch(h_ax, [p1(1), p2(1), p3(1), p4(1)], ...
        [p1(2), p2(2), p3(2), p4(2)], 'k');
    
    if strcmp(fill_on, 'no_fill')
        set(h_patch(bin_i), 'facecolor', 'none', 'edgecolor', col);
    elseif strcmp(fill_on, 'fill')
        set(h_patch(bin_i), 'facecolor', col, 'edgecolor', col);
    end
    
end

% histogram x-axis
axis_from_edge = 0.3;
px = [m + axis_from_edge*h_limit, M - axis_from_edge*h_limit];
py = [M - axis_from_edge*h_limit, m + axis_from_edge*h_limit];
line(h_ax, px, py, 'color', 'k', 'linewidth', 0.25)