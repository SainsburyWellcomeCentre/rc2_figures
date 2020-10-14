% compare responses between all conditions
input('sure?')
close all
clear all

import helper.*

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OPTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% what to plot
experiment = {'visual_flow', 'visual_flow', 'visual_flow', ...
    'darkness', 'darkness', 'darkness', 'head_tilt'};  % 'darkness', 'visual_flow', 'head_tilt'
combination = {'motion_all_vs_all','motion_vs_stationary', 'vestibular', ...
    'motion_all_vs_all','motion_vs_stationary', 'vestibular', 'vestibular'};  % 'motion_all_vs_all', 'motion_vs_stationary' or 'vestibular'

% data location
formatted_dir = 'C:\Users\Lee\Documents\mvelez\data\formatted_data';
table_dir = 'C:\Users\Lee\Documents\mvelez\data\tables\stationary_vs_motion';

% location in which to save PDF output
plot_basedir = 'C:\Users\Lee\Desktop\Desktop\zoomed';
save_on = true;


for exp_i = 1 : length(experiment)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% CALCULATE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % get details
    [probe_fnames, prot_x, prot_y, replay_x, replay_y, label_x, label_y, title_str, vis_stim] = experiment_details(experiment{exp_i}, combination{exp_i});
    
    save_dir = fullfile(plot_basedir, 'unity_plots', experiment{exp_i}, combination{exp_i});
    
    if save_on
        if ~isfolder(save_dir)
            mkdir(save_dir)
        end
    end
    
    % load stationary vs motion tables
    T = gather_stationary_vs_motion_table(probe_fnames, table_dir);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% ALL POOLED %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    figure('position', [680, 30, 1015, 948])
    h_ax = cell(size(prot_x));
    % sp_i = 0;
    u = {};
    
    for i = 1 : size(prot_x, 1)
        for j = 1 : size(prot_x, 2)
            
            %         sp_i = sp_i + 1;
            
            if isempty(prot_x{i, j})
                continue
            end
            
            sp_i = (i-1)*6 + j;
            h_ax{i, j} = subplot(6, 6, sp_i);%size(prot_x, 1), size(prot_x, 2), sp_i);
            hold on;
            
            T2 = get_protocols_summary(T, prot_y{i, j}, prot_x{i, j}, replay_y{i, j}, replay_x{i, j}, vis_stim(i, j));
            idx_main = true(length(T2.p), 1);
            u{end+1} = unity_plot(T2, idx_main, h_ax{i, j});
            
            xlabel([label_x{i, j}, ' (Hz)']);
            ylabel([label_y{i, j}, ' (Hz)']);
            xlim([0, 10])
            ylim([0, 10])
        end
    end
    
    sync_unity_plots(u);
    set(gcf, 'paperposition', [0, 0, 20, 20], 'paperpositionmode','manual', 'papersize', [20, 20]);
    FigureTitle(gcf, ['pooled, ', experiment{exp_i}]);
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
        u = {};
        
        for i = 1 : size(prot_x, 1)
            for j = 1 : size(prot_x, 2)
                
                sp_i = sp_i + 1;
                
                if isempty(prot_x{i, j})
                    continue
                end
                
                sp_i = (i-1)*6 + j;
                h_ax{i, j} = subplot(6, 6, sp_i);%size(prot_x, 1), size(prot_x, 2), sp_i);
                hold on;
                
                T2 = get_protocols_summary(T, prot_y{i, j}, prot_x{i, j}, replay_y{i, j}, replay_x{i, j}, vis_stim(i, j));
                
                idx_main = strcmp(T2.probe_name, probe_fnames{probe_i});
                u{end+1} = unity_plot(T2, idx_main, h_ax{i, j});
                
                xlabel([label_x{i, j}, ' (Hz)']);
                ylabel([label_y{i, j}, ' (Hz)']);
                xlim([0, 10])
                ylim([0, 10])
            end
        end
        
        sync_unity_plots(u);
        set(gcf, 'paperposition', [0, 0, 20, 20], 'paperpositionmode','manual', 'papersize', [20, 20]);
        FigureTitle(gcf, probe_fnames{probe_i});
        if save_on
            save_fname = fullfile(save_dir, [probe_fnames{probe_i}, '.pdf']);
            print(save_fname, '-bestfit', '-dpdf');
        end
    end
    close all
end