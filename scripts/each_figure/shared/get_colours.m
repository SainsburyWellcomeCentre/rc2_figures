function col = get_colours()

load('r2bcmap.mat', 'map')

col = containers.Map({'running', 'visual_flow', 'translation', 'red2blue_map', 'sig_increase', 'sig_decrease', 'no_change', 'narrow_spiking', 'wide_spiking'}, ...
                     {[147, 96, 55]/255, [243, 146, 0]/255, [0, 141, 54]/255, map, [229, 37, 33]/255, [71, 131, 196]/255, [0.5, 0.5, 0.5], [0.5, 0.5, 0.5], [0, 0, 0]});
                     
