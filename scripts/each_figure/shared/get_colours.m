function col = get_colours()

load('r2bcmap.mat', 'map')

keyval = {'running', [147, 96, 55]/255;
          'visual_flow', [243, 146, 0]/255;
          'translation', [0, 141, 54]/255;
          'red2blue_map', map;
          'sig_increase', [229, 37, 33]/255;
          'sig_decrease', [71, 131, 196]/255;
          'no_change', [0.5, 0.5, 0.5];
          'narrow_spiking', [0.5, 0.5, 0.5];
          'wide_spiking', [0, 0, 0];
          'e_not_tuned', [33, 37, 229]/255;
          'e_high_speeds', [123, 153, 243]/255;
          'e_low_speeds', [2, 16, 138]/255;
          's_not_tuned', [196, 131, 71]/255;
          's_high_speeds', [220, 156, 0]/255;
          's_low_speeds', [184, 113, 29]/255};

col = containers.Map(keyval(:, 1), keyval(:, 2));
                     
