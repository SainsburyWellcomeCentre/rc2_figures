classdef MIDepthPlot < RC2Axis
    
    properties
        
        h_lines
        h_txt
        
        x
        y
        depths
        boundaries
        regions
        p
        mi
        
    end
    
    
    methods
        
        function obj = MIDepthPlot(x, y, p, depths, boundaries, regions, h_ax)
            
            VariableDefault('h_ax', []);
            
            obj = obj@RC2Axis(h_ax);
            
            if ~exist('x', 'var')
                return
            end
            
            obj.x = x;
            obj.y = y;
            obj.depths = depths;
            obj.boundaries = boundaries;
            obj.regions = regions;
            obj.p = p;
            
            obj.mi = (y - x) ./ (y + x);
            
            idx_blue = obj.p < 0.05 & obj.x > obj.y;
            idx_red = obj.p < 0.05 & obj.x < obj.y;
            idx_black = obj.p >= 0.05 | isnan(obj.p);
            
            scatter(obj.mi(idx_black), obj.depths(idx_black), scatterball_size(0.8), obj.black, 'fill');
            scatter(obj.mi(idx_blue), obj.depths(idx_blue), scatterball_size(1.2), obj.blue, 'fill');
            scatter(obj.mi(idx_red), obj.depths(idx_red), scatterball_size(1.2), obj.red, 'fill');
            
            for b_i = 1 : length(obj.boundaries)
                line([-1, 1], obj.boundaries(b_i)*[1, 1], 'color', 'k', 'linestyle', '--');
            end
            
            set(obj.h_ax, 'xlim', [-1, 1], 'ylim', [boundaries(end)-10, boundaries(1)+10], ...
                'ytick', [], 'xtick', [-1, 0, 1]);
            
        end
        
        
        function print_layers(obj, position)
            
            VariableDefault('position', 'right');
            
            % format
            for b_i = 1 : length(obj.boundaries)
    
                if b_i < length(obj.boundaries)-1
                    if strcmp(position, 'right')
                        text(1, sum(obj.boundaries(b_i) + obj.boundaries(b_i+1))/2, obj.regions{b_i}, ...
                            'horizontalalignment', 'left', 'verticalalignment', 'middle')
                    else
                        text(-1, sum(obj.boundaries(b_i) + obj.boundaries(b_i+1))/2, obj.regions{b_i}, ...
                            'horizontalalignment', 'right', 'verticalalignment', 'middle')
                    end
                end
            end
        end
    end
end