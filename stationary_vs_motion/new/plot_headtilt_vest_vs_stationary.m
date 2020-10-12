% compare responses between all conditions
input('sure?')
clear all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OPTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% name of the probe recordings to analyze
probe_fname = {'CAA-1112529_rec1_rec2_rec3', ...
               'CAA-1112530_rec1_rec2_rec3', ...
               'CAA-1112531_rec1_rec2_rec3', ...
               'CAA-1112532_rec1_rec2_rec3'};

table_dir = 'C:\Users\Lee\Documents\mvelez\data\tables\stationary_vs_motion';

% location in which to save PDF output
save_dir = 'C:\Users\Lee\Desktop\Desktop\unity_plots\head_tilt';
save_on = true;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CALCULATE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
T = table();

% for each recording
for probe_i = 1 : length(probe_fname)
    
    table_fname = fullfile(table_dir, sprintf('%s_stationary_vs_motion_table.mat', probe_fname{probe_i}));
    temp = load(table_fname, 'T');
    T = [T; temp.T];
end

% restrict table to cortical clusters
is_cortical = ismember(T.cluster_region, {'VISp1', 'VISp2/3', 'VISp4', 'VISp5', 'VISp6a', 'VISp6b', 'VISpX'});
T(~is_cortical, :) = [];





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DARKNESS  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
protocols = {'Dark', 'Light', 'VF_v_F'};


figure('position', [680, 30, 1015, 948]);
hold on;
h_ax = {};

p_median = zeros(length(protocols), 1);
n1 = zeros(length(protocols), 1);
n2 = zeros(length(protocols), 1);
n3 = zeros(length(protocols), 1);

for prot_i = 1 : length(protocols)
    
    h_ax{prot_i} = subplot(1, length(protocols), prot_i);
    hold on;
    
    rx = [];
    ry = [];
    p_all = [];
    
    for probe_i = 1 : length(probe_fname)
        
        this_rec = ismember(T.probe_name, probe_fname{probe_i});
        cluster_ids = unique(T.cluster_id(this_rec));
        
        for clust_i = 1 : length(cluster_ids)
            
            this_cluster = T.cluster_id == cluster_ids(clust_i);
            
            if strcmp(protocols{prot_i}, 'Dark')
                
                this_prot = ismember(T.protocol, 'StageOnly');
                is_dark = T.vis_stim == 0;
                idx = this_rec & this_cluster & this_prot & is_dark;
                
                rate_x = T.stationary_firing_rate(idx);
                rate_y = T.motion_firing_rate(idx);
                
            elseif strcmp(protocols{prot_i}, 'Light')
                
                this_prot = ismember(T.protocol, 'StageOnly');
                is_light = T.vis_stim == 1;
                idx = this_rec & this_cluster & this_prot & is_light;
                
                rate_x = T.stationary_firing_rate(idx);
                rate_y = T.motion_firing_rate(idx);
                
            elseif strcmp(protocols{prot_i}, 'VF_v_F')
                
                this_prot_x = ismember(T.protocol, 'ReplayOnly');
                this_prot_y = ismember(T.protocol, 'StageOnly');
                is_light = T.vis_stim == 1;
                
                idx_x = this_rec & this_cluster & this_prot_x;
                idx_y = this_rec & this_cluster & this_prot_y & is_light;
                
                rate_x = T.motion_firing_rate(idx_x);
                rate_y = T.motion_firing_rate(idx_y);
                
            end
            
            p = signrank(rate_x, rate_y);
            
            if p < 0.05 && (nanmedian(rate_x) < nanmedian(rate_y))
                n1(prot_i) = n1(prot_i) + 1;
                col = 'r';
            elseif  p < 0.05 && (nanmedian(rate_x) > nanmedian(rate_y))
                n2(prot_i) = n2(prot_i) + 1;
                col = 'b';
            else
                n3(prot_i) = n3(prot_i) + 1;
                col = 'k';
            end
            
            rx(end+1) = nanmedian(rate_x);
            ry(end+1) = nanmedian(rate_y);
            p_all(end+1) = p;
            
            scatter(nanmedian(rate_x), nanmedian(rate_y), [], col, 'fill');
        end
    end
    
    if strcmp(protocols{prot_i}, 'Dark')
        xlabel('Stationary (Hz)');
        ylabel('Vest Motion (Hz)');
        title(protocols{prot_i});
    elseif strcmp(protocols{prot_i}, 'Light')
        xlabel('Stationary (Hz)');
        ylabel('Vest + Visual Flow Motion (Hz)');
        title(protocols{prot_i});
    elseif strcmp(protocols{prot_i}, 'VF_v_F')
        xlabel('Visual Flow Only Motion (Hz)');
        ylabel('Vest + Visual Flow Motion(Hz)');
        title('Light (V+F vs. F)');
    end
    
    x_med = median(rx);
    y_med = median(ry);
    x_iqr = prctile(rx, [25, 75]);
    y_iqr = prctile(ry, [25, 75]);
    p_median(prot_i) = signrank(rx, ry);
    
    scatter(gca, x_med, y_med, [], 'g', 'fill');
    line(gca, x_iqr, y_med([1, 1]), 'color', 'g');
    line(gca, x_med([1, 1]), y_iqr, 'color', 'g');
end

% format
m = inf; M = -inf;
for prot_i = 1 : length(protocols)    
    m = min([m, get(h_ax{prot_i}, 'xlim'), get(h_ax{prot_i}, 'ylim')]);
    M = max([M, get(h_ax{prot_i}, 'xlim'), get(h_ax{prot_i}, 'ylim')]);
end

for prot_i = 1 : length(protocols)
    set(h_ax{prot_i}, 'xlim', [m, M], 'ylim', [m, M]);
    line(h_ax{prot_i}, [m, M], [m, M], 'linestyle', '--', 'color', 'k');
    
    txt_str = sprintf('p = %.2f \nred = %i \nblue = %i\nblack = %i', ...
        p_median(prot_i), ...
        n1(prot_i), ...
        n2(prot_i), ...
        n3(prot_i));
    text(h_ax{prot_i}, M, m, txt_str, 'verticalalignment', 'bottom', 'horizontalalignment', 'right');
    
end
% make the page bigger to fit the graphs
set(gcf, 'paperposition', [0, 0, 20, 20], 'paperpositionmode','manual', 'papersize', [20, 20]);

% print the PDF
if save_on
    print(fullfile(save_dir, 'headtilt_vestibular.pdf'), '-bestfit', '-dpdf')
end





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% BY ANIMAL  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
protocols = {'Dark', 'Light', 'VF_v_F'};


for probe_i = 1 : length(probe_fname)
    
    this_rec = ismember(T.probe_name, probe_fname{probe_i});
    cluster_ids = unique(T.cluster_id(this_rec));
    
    figure('position', [680, 30, 1015, 948]);
    hold on;
    h_ax = {};
    
    p_median = zeros(length(protocols), 1);
    n1 = zeros(length(protocols), 1);
    n2 = zeros(length(protocols), 1);
    n3 = zeros(length(protocols), 1);
    
    for prot_i = 1 : length(protocols)
        
        h_ax{prot_i} = subplot(1, length(protocols), prot_i);
        hold on;
        
        rx = [];
        ry = [];
        p_all = [];
        
        for clust_i = 1 : length(cluster_ids)
            
            this_cluster = T.cluster_id == cluster_ids(clust_i);
            
            if strcmp(protocols{prot_i}, 'Dark')
                
                this_prot = ismember(T.protocol, 'StageOnly');
                is_dark = T.vis_stim == 0;
                idx = this_rec & this_cluster & this_prot & is_dark;
                
                rate_x = T.stationary_firing_rate(idx);
                rate_y = T.motion_firing_rate(idx);
                
            elseif strcmp(protocols{prot_i}, 'Light')
                
                this_prot = ismember(T.protocol, 'StageOnly');
                is_light = T.vis_stim == 1;
                idx = this_rec & this_cluster & this_prot & is_light;
                
                rate_x = T.stationary_firing_rate(idx);
                rate_y = T.motion_firing_rate(idx);
                
            elseif strcmp(protocols{prot_i}, 'VF_v_F')
                
                this_prot_x = ismember(T.protocol, 'ReplayOnly');
                this_prot_y = ismember(T.protocol, 'StageOnly');
                is_light = T.vis_stim == 1;
                
                idx_x = this_rec & this_cluster & this_prot_x;
                idx_y = this_rec & this_cluster & this_prot_y & is_light;
                
                rate_x = T.motion_firing_rate(idx_x);
                rate_y = T.motion_firing_rate(idx_y);
                
            end
            
            p = signrank(rate_x, rate_y);
            
            if p < 0.05 && (nanmedian(rate_x) < nanmedian(rate_y))
                n1(prot_i) = n1(prot_i) + 1;
                col = 'r';
            elseif  p < 0.05 && (nanmedian(rate_x) > nanmedian(rate_y))
                n2(prot_i) = n2(prot_i) + 1;
                col = 'b';
            else
                n3(prot_i) = n3(prot_i) + 1;
                col = 'k';
            end
            
            rx(end+1) = nanmedian(rate_x);
            ry(end+1) = nanmedian(rate_y);
            p_all(end+1) = p;
            
            scatter(nanmedian(rate_x), nanmedian(rate_y), [], col, 'fill');
        end
        
        if strcmp(protocols{prot_i}, 'Dark')
            xlabel('Stationary (Hz)');
            ylabel('Vest Motion (Hz)');
            title(protocols{prot_i});
        elseif strcmp(protocols{prot_i}, 'Light')
            xlabel('Stationary (Hz)');
            ylabel('Vest + Visual Flow Motion (Hz)');
            title(protocols{prot_i});
        elseif strcmp(protocols{prot_i}, 'VF_v_F')
            xlabel('Visual Flow Only Motion (Hz)');
            ylabel('Vest + Visual Flow Motion(Hz)');
            title('Light (V+F vs. F)');
        end
        
        x_med = median(rx);
        y_med = median(ry);
        x_iqr = prctile(rx, [25, 75]);
        y_iqr = prctile(ry, [25, 75]);
        p_median(prot_i) = signrank(rx, ry);
        
        scatter(gca, x_med, y_med, [], 'g', 'fill');
        line(gca, x_iqr, y_med([1, 1]), 'color', 'g');
        line(gca, x_med([1, 1]), y_iqr, 'color', 'g');
        
    end
    
    % format
    m = inf; M = -inf;
    for prot_i = 1 : length(protocols)
        m = min([m, get(h_ax{prot_i}, 'xlim'), get(h_ax{prot_i}, 'ylim')]);
        M = max([M, get(h_ax{prot_i}, 'xlim'), get(h_ax{prot_i}, 'ylim')]);
    end
    
    for prot_i = 1 : length(protocols)
        set(h_ax{prot_i}, 'xlim', [m, M], 'ylim', [m, M]);
        line(h_ax{prot_i}, [m, M], [m, M], 'linestyle', '--', 'color', 'k');
        
        txt_str = sprintf('p = %.2f \nred = %i \nblue = %i\nblack = %i', ...
            p_median(prot_i), ...
            n1(prot_i), ...
            n2(prot_i), ...
            n3(prot_i));
        text(h_ax{prot_i}, M, m, txt_str, 'verticalalignment', 'bottom', 'horizontalalignment', 'right');
        
    end
    
    FigureTitle(gcf, probe_fname{probe_i})
    
    % make the page bigger to fit the graphs
    set(gcf, 'paperposition', [0, 0, 20, 20], 'paperpositionmode','manual', 'papersize', [20, 20]);
    
    % print the PDF
    if save_on
        print(fullfile(save_dir, sprintf('%s_headtilt_vestibular.pdf', probe_fname{probe_i})), '-bestfit', '-dpdf')
    end
    
end

