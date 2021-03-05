function u = unity_plot(T2, idx_main, h_ax, marker_style, plot_histogram, bin_width, ax_limits)

VariableDefault('marker_style', 'o');
VariableDefault('plot_histogram', false);
VariableDefault('bin_width', []);
VariableDefault('ax_limits', []);


idx_blue = T2.p < 0.05 & T2.fr_x > T2.fr_y & idx_main;
idx_red = T2.p < 0.05 & T2.fr_x < T2.fr_y & idx_main;
idx_black = (T2.p >= 0.05 | isnan(T2.p)) & idx_main;

scatter(T2.fr_x(idx_black), T2.fr_y(idx_black), 10, 'k', 'fill', marker_style);
scatter(T2.fr_x(idx_blue), T2.fr_y(idx_blue), 30, [30,144,255]/255, 'fill', marker_style);
scatter(T2.fr_x(idx_red), T2.fr_y(idx_red), 30, 'r', 'fill', marker_style);

% format
if isempty(ax_limits)
    
    m = min([get(gca, 'xlim'), get(gca, 'ylim')]);
    M = max([get(gca, 'xlim'), get(gca, 'ylim')]);
        
else
    
    m = ax_limits(1);
    M = ax_limits(2);
    
end

set(h_ax, 'xlim', [m, M], 'ylim', [m, M]);
u.line = line(h_ax, [m, M], [m, M], 'linestyle', '--', 'color', 'k');
    

% histogram
if plot_histogram
    
    % distance of all points perpendicular to unity line
    points = [T2.fr_x(idx_main), T2.fr_y(idx_main)];
    
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
        [bin_count, bin_edges] = histcounts(dist_to_unity, 'binwidth', bin_width);
    end
    
    % h_limit is the middle of the axis to a corner of the axis
    h_limit = (M - m) / sqrt(2);
    
    % scale the bin counts by the h_limit
    bin_height = bin_count * (h_limit / max(bin_count)) / 2;
    
    % for each bin of the histogram
    for bin_i = 1 : length(bin_height)
        
        % get edges of the bar
        p1 = [(M+m)/2, (M+m)/2] + [1, -1]*bin_edges(bin_i)/sqrt(2);
        p2 = [(M+m)/2, (M+m)/2] + [1, -1]*bin_edges(bin_i+1)/sqrt(2);
        p3 = p2 + bin_height([bin_i, bin_i])/sqrt(2);
        p4 = p1 + bin_height([bin_i, bin_i])/sqrt(2);
        
        % plot patch
        h_patch = patch([p1(1), p2(1), p3(1), p4(1)], ...
              [p1(2), p2(2), p3(2), p4(2)], 'k');
        
        set(h_patch, 'facecolor', 'none', 'edgecolor', 'k');
          
    end
    
end

x_med = median(T2.fr_x(idx_main));
y_med = median(T2.fr_y(idx_main));
x_iqr = prctile(T2.fr_x(idx_main), [25, 75]);
y_iqr = prctile(T2.fr_y(idx_main), [25, 75]);
p_median = signrank(T2.fr_x(idx_main), T2.fr_y(idx_main));

scatter(h_ax, x_med, y_med, [], 'g', 'fill', marker_style);
line(h_ax, x_iqr, y_med([1, 1]), 'color', 'g');
line(h_ax, x_med([1, 1]), y_iqr, 'color', 'g');

if p_median < 0.01
    txt_str = sprintf('p = %.2e \nred = %i (%i%%) \nblue = %i (%i%%)\ntotal = %i', ...
        p_median, ...
        sum(idx_red), ...
        round(100*sum(idx_red)/sum(idx_main)), ...
        sum(idx_blue), ...
        round(100*sum(idx_blue)/sum(idx_main)), ...
        sum(idx_main));
else
    txt_str = sprintf('p = %.2f \nred = %i (%i%%) \nblue = %i (%i%%)\ntotal = %i', ...
        p_median, ...
        sum(idx_red), ...
        round(100*sum(idx_red)/sum(idx_main)), ...
        sum(idx_blue), ...
        round(100*sum(idx_blue)/sum(idx_main)), ...
        sum(idx_main));
end

u.txt = text(h_ax, M, m, txt_str, 'verticalalignment', 'bottom', 'horizontalalignment', 'right');
u.ax = h_ax;
