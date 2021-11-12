function fig = figure_2_main(data)

fig.h_fig = a4figure();

label_positions = {'a', [41, 297 - 22, 0, 0];
                   'b', [41, 297 - 64, 0, 0]; 
                   'c', [41, 297 - 95, 0, 0];
                   'd', [88, 297 - 22, 0, 0];
                   'e', [88, 297 - 64, 0, 0];
                   'f', [88, 297 - 95, 0, 0];
                   'g', [134, 297 - 22, 0, 0];
                   'h', [134, 297 - 60, 0, 0];
                   'i', [134, 297 - 101, 0, 0]};

axes_positions = {'a', [50, 297 - 56.672, 29, 29.171];
                  'b1', [50, 297 - 90, 29, 26.8];
                  'b2', [50, 297 - 73, 29, 7.125];
                  'b3', [50, 297 - 90, 29, 12.83];
                  'c2', [50, 297 - 108.5, 29, 13];
                  'c3', [50, 297 - 123, 29, 10];
                  'c1', [50, 297 - 128, 29, 35];
                  'd', [97, 297 - 56.672, 29, 29.171];
                  'e1', [97, 297 - 90, 29, 26.8];
                  'e2', [97, 297 - 73, 29, 7.125];
                  'e3', [97, 297 - 90, 29, 12.83];
                  'f2', [97, 297 - 108.5, 29, 13];
                  'f3', [97, 297 - 123, 29, 10];
                  'f1', [97, 297 - 128, 29, 35];
                  'g', [142, 297 - 50, 27, 27];
                  'h', [145, 297 - 91, 23, 29];
                  'i', [144, 297 - 130, 25, 25]};

              
fig.h_labels = setup_labels(fig.h_fig, label_positions);
fig.h_ax = setup_axes(fig.h_fig, axes_positions);

% tic; figure_2a(data, fig.h_ax('a')); fprintf('2A took: %.3f\n', toc);
% tic; figure_2b(data, fig.h_ax('b1'), fig.h_ax('b2'), fig.h_ax('b3')); fprintf('2B took: %.3f\n', toc);
% tic; figure_2c(data, fig.h_ax('c1'), fig.h_ax('c2'), fig.h_ax('c3')); fprintf('2C took: %.3f\n', toc);
% tic; figure_2d(data, fig.h_ax('d')); fprintf('2D took: %.3f\n', toc);
% tic; figure_2e(data, fig.h_ax('e1'), fig.h_ax('e2'), fig.h_ax('e3')); fprintf('2E took: %.3f\n', toc);
% tic; figure_2f(data, fig.h_ax('f1'), fig.h_ax('f2'), fig.h_ax('f3')); fprintf('2F took: %.3f\n', toc);
% tic; figure_2g(data, fig.h_ax('g')); fprintf('2G took: %.3f\n', toc);
tic; figure_2h(data, fig.h_ax('h')); fprintf('2H took: %.3f\n', toc);
tic; figure_2i(data, fig.h_ax('i')); fprintf('2I took: %.3f\n', toc);

