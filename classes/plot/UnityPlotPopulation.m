classdef UnityPlotPopulation < UnityPlot
    
    properties
        
        p
        marker_style = 'o'
    end
    
    methods
        
        function obj = UnityPlotPopulation(x, y, p, h_ax)
            
            obj = obj@UnityPlot(x, y, h_ax);
            
            obj.p = p;
        end
        
        
        function plot(obj)
            
            idx_blue = obj.p < 0.05 & obj.x > obj.y;
            idx_red = obj.p < 0.05 & obj.x < obj.y;
            idx_black = obj.p >= 0.05 | isnan(obj.p);
            
            scatter(obj.x(idx_black), obj.y(idx_black), scatterball_size(0.8), obj.black, 'fill', obj.marker_style);
            scatter(obj.x(idx_blue), obj.y(idx_blue), scatterball_size(1.2), obj.blue, 'fill', obj.marker_style);
            scatter(obj.x(idx_red), obj.y(idx_red), scatterball_size(1.2), obj.red, 'fill', obj.marker_style);
            
            % format
            m = min([get(obj.h_ax, 'xlim'), get(obj.h_ax, 'ylim')]);
            M = max([get(obj.h_ax, 'xlim'), get(obj.h_ax, 'ylim')]);
            
            set(obj.h_ax, 'xlim', [m, M], 'ylim', [m, M]);
            obj.h_line = line(obj.h_ax, [m, M], [m, M], 'linestyle', '--', 'color', 'k');
            
            x_med = nanmedian(obj.x);
            y_med = nanmedian(obj.y);
            x_iqr = prctile(obj.x, [25, 75]);
            y_iqr = prctile(obj.y, [25, 75]);
            p_median = signrank(obj.x, obj.y);
            
            scatter(obj.h_ax, x_med, y_med, scatterball_size(1.3), 'g', 'fill');
            line(obj.h_ax, x_iqr, y_med([1, 1]), 'color', 'g');
            line(obj.h_ax, x_med([1, 1]), y_iqr, 'color', 'g');
            
            if p_median < 0.01
                txt_str = sprintf('p = %.2e \nred = %i (%i%%) \nblue = %i (%i%%)\ntotal = %i', ...
                    p_median, ...
                    sum(idx_red), ...
                    round(100*sum(idx_red)/length(obj.p)), ...
                    sum(idx_blue), ...
                    round(100*sum(idx_blue)/length(obj.p)), ...
                    length(obj.p));
            else
                txt_str = sprintf('p = %.2f \nred = %i (%i%%) \nblue = %i (%i%%)\ntotal = %i', ...
                    p_median, ...
                    sum(idx_red), ...
                    round(100*sum(idx_red)/length(obj.p)), ...
                    sum(idx_blue), ...
                    round(100*sum(idx_blue)/length(obj.p)), ...
                    length(obj.p));
            end
            
            obj.h_txt = text(obj.h_ax, M, m, txt_str, 'verticalalignment', 'bottom', 'horizontalalignment', 'right', ...
                'fontsize', 6);
            
        end
        
    end
    
end