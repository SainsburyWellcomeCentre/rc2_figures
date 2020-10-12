% compare responses between all conditions
input('sure?')
clear all

import helper.*

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OPTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% what to plot
experiment = 'darkness';  % 'darkness' or 'visual_flow'
combination = 'motion_all_vs_all';  % 'motion_all_vs_all', 'motion_vs_stationary' or 'vestibular'

% data location
formatted_dir = 'C:\Users\Lee\Documents\mvelez\data\formatted_data';
table_dir = 'C:\Users\Lee\Documents\mvelez\data\tables\stationary_vs_motion';

% location in which to save PDF output
plot_basedir = 'C:\Users\Lee\Desktop\Desktop';
save_on = false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CALCULATE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get details
[probe_fnames, prot_x, prot_y, replay_x, replay_y, label_x, label_y, title_str] = experiment_details(experiment, combination);

save_dir = fullfile(plot_basedir, 'mi_vs_depth_plots', experiment, combination);

if save_on
    if ~isfolder(save_dir)
        mkdir(save_dir)
    end
end

% load stationary vs motion tables
T = gather_stationary_vs_motion_table(probe_fnames, table_dir);

boundaries = get_layer_boundaries_and_average(probe_fnames, formatted_dir);
avg_boundaries = average_boundaries(boundaries);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ALL POOLED %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure('position', [680, 30, 1015, 948])
h_ax = cell(size(prot_x));
sp_i = 0;

for i = 1 : size(prot_x, 1)
    for j = 1 : size(prot_x, 2)
        
        sp_i = sp_i + 1;
        
        if isempty(prot_x{i, j})
            continue
        end
        
        h_ax{i, j} = subplot(size(prot_x, 1), size(prot_x, 2), sp_i);
        hold on;
        
        T2 = get_protocols_summary(T, prot_y{i, j}, prot_x{i, j}, replay_y{i, j}, replay_x{i, j});
        
        depths = get_relative_depth(T2, boundaries);
        
        idx_main = true(length(T2.p), 1);
        mi_vs_depth_plot(T2, idx_main, depths, avg_boundaries, h_ax{i, j}, i == 1 & j == size(prot_x, 2));
        
        set(gca, 'ytick', []);
        xlabel('MI');
        title(title_str{i, j});
    end
end

set(gcf, 'paperposition', [0, 0, 20, 20], 'paperpositionmode','manual', 'papersize', [20, 20]);
FigureTitle(gcf, ['pooled, ', experiment]);
if save_on
    save_fname = fullfile(save_dir, 'pooled.pdf');
    print(save_fname, '-bestfit', '-dpdf');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% BY MOUSE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for probe_i = 1 : length(probe_fnames)
    
    figure('position', [680, 30, 1015, 948])
    h_ax = cell(size(prot_x));
    sp_i = 0;
    
    for i = 1 : size(prot_x, 1)
        for j = 1 : size(prot_x, 2)
            
            sp_i = sp_i + 1;
            
            if isempty(prot_x{i, j})
                continue
            end
            
            h_ax{i, j} = subplot(size(prot_x, 1), size(prot_x, 2), sp_i);
            hold on;
            
            T2 = get_protocols_summary(T, prot_y{i, j}, prot_x{i, j}, replay_y{i, j}, replay_x{i, j});
            
            depths = get_relative_depth(T2, boundaries);
            
            idx_main = strcmp(T2.probe_name, probe_fnames{probe_i});
            b = boundaries(strcmp(boundaries.probe_name, probe_fnames{probe_i}), :);
            mi_vs_depth_plot(T2, idx_main, depths, b, h_ax{i, j}, i == 1 & j == size(prot_x, 2));
            
            xlabel('MI');
            title(title_str{i, j});
        end
    end
    
    set(gcf, 'paperposition', [0, 0, 20, 20], 'paperpositionmode','manual', 'papersize', [20, 20]);
    FigureTitle(gcf, probe_fnames{probe_i});
    if save_on
        save_fname = fullfile(save_dir, [probe_fnames{probe_i}, '.pdf']);
        print(save_fname, '-bestfit', '-dpdf');
    end
end

