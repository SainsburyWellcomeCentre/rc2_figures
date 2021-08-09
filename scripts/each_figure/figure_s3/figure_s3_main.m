function figure_s3_main(data)


fig.h_fig = a4figure();

label_positions = {'a', [40, 297 - 13, 0, 0];
                   'b', [84, 297 - 13, 0, 0]; 
                   'c', [125, 297 - 13, 0, 0];
                   'd', [124, 297 - 69, 0, 0]};

axes_positions = {'a_upper', [50.795, 297 - 50.334, 28.393, 28.393];
                  'a_lower', [50.795, 297 - 100, 28.393, 28.393];
                  'b_upper', [94.5, 297 - 50, 27, 27];
                  'b_lower', [94.5, 297 - 100, 27, 27];
                  'c', [133.8, 297 - 59.8, 30, 37.8];
                  'd', [133.8, 297 - 100, 27, 27]};

              
fig.h_labels = setup_labels(fig.h_fig, label_positions);
fig.h_ax = setup_axes(fig.h_fig, axes_positions);

tic; figure_s3a(data, fig.h_ax('a_upper'), fig.h_ax('a_lower')); fprintf('S3A took: %.3f\n', toc);
tic; figure_s3b(data, fig.h_ax('b_upper'), fig.h_ax('b_lower')); fprintf('S3B took: %.3f\n', toc);
tic; figure_s3c(data, fig.h_ax('c')); fprintf('S3C took: %.3f\n', toc);
tic; figure_s3d(data, fig.h_ax('d')); fprintf('S3D took: %.3f\n', toc);


