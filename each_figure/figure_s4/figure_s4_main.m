function fig = figure_s4_main(data)

fig.h_fig = a4figure();

label_positions = {'a', [42, 297 - 22, 0, 0];
                   'b', [83, 297 - 22, 0, 0]; 
                   'c', [42, 297 - 59, 0, 0];
                   'd', [83, 297 - 59, 0, 0];
                   'e', [42, 297 - 136, 0, 0];
                   'f', [83, 297 - 136, 0, 0];
                   'g', [125, 297 - 22, 0, 0];
                   'h', [125, 297 - 59, 0, 0];
                   'i', [125, 297 - 107, 0, 0];
                   'j', [125, 297 - 136, 0, 0]};

axes_positions = {'a', [50, 297 - 47, 27.5, 10];
                  'b', [90, 297 - 51, 27, 27];
                  'e', [50, 297 - 165, 28.5, 28.5];
                  'f', [90, 297 - 165, 28.5, 28.5];
                  'g', [132, 297 - 49, 32, 17];
                  'h', [132, 297 - 96, 32, 24];
                  'i', [134, 297 - 121, 28.5, 11];
                  'j', [134, 297 - 165, 28.5, 28.5]};

fig.h_labels = setup_labels(fig.h_fig, label_positions);
fig.h_ax = setup_axes(fig.h_fig, axes_positions);

% create special axes for c
[h_ax_s4cd_main, h_ax_s4cd_histogram] = figure_s4cd_axes_positions(fig.h_fig);


tic; figure_s4a(data, fig.h_ax('a')); fprintf('S4A took: %.3f\n', toc);
tic; figure_s4b(data, fig.h_ax('b')); fprintf('S4B took: %.3f\n', toc);
tic; figure_s4cd(data, h_ax_s4cd_main, h_ax_s4cd_histogram); fprintf('S4C & D took: %.3f\n', toc);
tic; figure_s4e(data, fig.h_ax('e')); fprintf('S4E took: %.3f\n', toc);
tic; figure_s4f(data, fig.h_ax('f')); fprintf('S4F took: %.3f\n', toc);
tic; figure_s4g(data, fig.h_ax('g')); fprintf('S4G took: %.3f\n', toc);
tic; figure_s4h(data, fig.h_ax('h')); fprintf('S4H took: %.3f\n', toc);
tic; figure_s4i(fig.h_ax('i')); fprintf('S4I took: %.3f\n', toc);
tic; figure_s4j(data, fig.h_ax('j')); fprintf('S4J took: %.3f\n', toc);
