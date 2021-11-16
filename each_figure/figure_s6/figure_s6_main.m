function figure_s6_main(data)

fig.h_fig = a4figure();

label_positions = {'a', [41, 297 - 22, 0, 0];
                   'b', [88, 297 - 22, 0, 0]; 
                   'c', [134, 297 - 22, 0, 0]};

axes_positions = {'a2', [50, 297 - 35.5, 29, 13];
                  'a3', [50, 297 - 50, 29, 10];
                  'a1', [50, 297 - 55, 29, 35];
                  'b', [96, 297 - 50, 27, 27];
                  'c', [145, 297 - 53, 23, 29]};

fig.h_labels = setup_labels(fig.h_fig, label_positions);
fig.h_ax = setup_axes(fig.h_fig, axes_positions);


tic; figure_s6a(data, fig.h_ax('a1'), fig.h_ax('a2'), fig.h_ax('a3')); fprintf('6A took: %.3f\n', toc);
tic; figure_s6b(data, fig.h_ax('b')); fprintf('6B took: %.3f\n', toc);
tic; figure_s6c(data, fig.h_ax('c')); fprintf('6C took: %.3f\n', toc);
