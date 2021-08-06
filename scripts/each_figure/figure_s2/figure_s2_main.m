function fig = figure_s2_main(data)

fig.h_fig = a4figure();

label_positions = {'a', [68, 297 - 23, 0, 0];
                   'b', [107, 297 - 23, 0, 0]; 
                   'c', [68, 297 - 71, 0, 0];
                   'd', [107, 297 - 71, 0, 0]};

axes_positions = {'a', [77, 297 - 57, 24, 24];
                  'b', [116, 297 - 57, 24, 24];
                  'c', [77, 297 - 113, 24, 24];
                  'd', [116, 297 - 113, 24, 24]};

              
fig.h_labels = setup_labels(fig.h_fig, label_positions);
fig.h_ax = setup_axes(fig.h_fig, axes_positions);

tic; figure_s2a(data, fig.h_ax('a')); fprintf('S2A took: %.3f\n', toc);
tic; figure_s2b(data, fig.h_ax('b')); fprintf('S2B took: %.3f\n', toc);
tic; figure_s2c(data, fig.h_ax('c')); fprintf('S2C took: %.3f\n', toc);
tic; figure_s2d(data, fig.h_ax('d')); fprintf('S2D took: %.3f\n', toc);
