% run plotting of all figures

save_enabled = true;
save_dir = fullfile('C:\Users\lee\Desktop', sprintf('figures_%s', datestr(now, 'yyyymmdd_HHMM')));

% whether to load all data at the outset (requires huge amount of ram - up
% to 128GB, but make things MUCH faster)
load_data_at_start = true;


%% Run

if load_data_at_start
    load_all_data;
else
    data = [];
end

if save_enabled && ~isfolder(save_dir)
    mkdir(save_dir);
end
    
% create figures and plot
figure_1_main(data);
save_figure(save_dir, 'figure_1', save_enabled);

figure_2_main(data);
save_figure(save_dir, 'figure_2', save_enabled);

figure_s2_main(data);
save_figure(save_dir, 'figure_s2', save_enabled);

figure_s3_main(data);
save_figure(save_dir, 'figure_s3', save_enabled);

figure_s4_main();
save_figure(save_dir, 'figure_s4', save_enabled);

figure_s5_main(data);
save_figure(save_dir, 'figure_s5', save_enabled);

figure_s6_main(data);
save_figure(save_dir, 'figure_s6', save_enabled);
