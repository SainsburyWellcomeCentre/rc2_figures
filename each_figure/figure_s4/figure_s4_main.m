function figure_s4_main(data)

fig.h_fig = a4figure();

label_positions = {'a', [42, 297 - 22, 0, 0];
                   'b', [84, 297 - 22, 0, 0];
                   'c', [42, 297 - 59, 0, 0];
                   'd', [84, 297 - 59, 0, 0];
                   'e', [42, 297 - 136, 0, 0];
                   'f', [84, 297 - 136, 0, 0];
                   'g', [125.5, 297 - 22, 0, 0];
                   'h', [125.5, 297 - 59, 0, 0];
                   'i', [125.5, 297 - 107, 0, 0];
                   'j', [125.5, 297 - 136, 0, 0]};

axes_positions = {'c', [50.8, 297 - 80.8, 18.5, 18.5;
                        50.8, 297 - 103.5, 18.5, 18.5;
                        50.8, 297 - 126.2, 18.5, 18.5];
                  'd', [90.5, 297 - 80.8, 18.5, 18.5;
                        90.5, 297 - 103.5, 18.5, 18.5;
                        90.5, 297 - 126.2, 18.5, 18.5];
                  'e', [50.8, 297 - 165.3, 28.7, 28.7];
                  'f', [90.5, 297 - 165.3, 28.7, 28.7]};

              
fig.h_labels = setup_labels(fig.h_fig, label_positions);
fig.h_ax = setup_axes(fig.h_fig, axes_positions);

% tic; figure_s4a(data, fig.h_ax('a')); fprintf('S4A took: %.3f\n', toc);
% tic; figure_s4b(data, fig.h_ax('b')); fprintf('S4B took: %.3f\n', toc);
% tic; figure_s4c(data, fig.h_ax('c')); fprintf('S4C took: %.3f\n', toc);
