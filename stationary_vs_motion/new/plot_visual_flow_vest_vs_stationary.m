% compare responses between all conditions
input('sure?')
clear all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OPTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% name of the probe recordings to analyze
probe_fname = {'CAA-1110262_rec1_rec2_rec3', ...
    'CAA-1110264_rec1_rec2', ...
    'CAA-1110265_restricted_rec1_rec2_rec3', ...
    'CAA-1112224_rec1_rec2_rec3'};

table_dir = 'C:\Users\Lee\Documents\mvelez\data\tables\stationary_vs_motion';

% location in which to save PDF output
save_dir = 'C:\Users\Lee\Desktop\Desktop\unity_plots\visual_flow\vestibular';
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
%% ALL  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('position', [680, 30, 1015, 948]);
hold on;

stat = [];
mot = [];
p_all = [];

n1 = 0;
n2 = 0;
n3 = 0;

for probe_i = 1 : length(probe_fname)
    
    this_rec = ismember(T.probe_name, probe_fname{probe_i});
    cluster_ids = unique(T.cluster_id(this_rec));
    
    for clust_i = 1 : length(cluster_ids)
        
        this_cluster = T.cluster_id == cluster_ids(clust_i);
        
        this_prot = ismember(T.protocol, 'StageOnly');
        
        idx = this_rec & this_cluster & this_prot;
        
        stationary_rate = T.stationary_firing_rate(idx);
        motion_rate = T.motion_firing_rate(idx);
        
        p = signrank(stationary_rate, motion_rate);
        
        if p < 0.05 && (nanmedian(stationary_rate) < nanmedian(motion_rate))
            n1 = n1 + 1;
            col = 'r';
        elseif  p < 0.05 && (nanmedian(stationary_rate) > nanmedian(motion_rate))
            n2 = n2 + 1;
            col = 'b';
        else
            n3 = n3 + 1;
            col = 'k';
        end
        
        stat(end+1) = nanmedian(stationary_rate);
        mot(end+1) = nanmedian(motion_rate);
        p_all(end+1) = p;
        
        scatter(nanmedian(stationary_rate), nanmedian(motion_rate), [], col, 'fill');
    end
end

xlabel('Stationary (Hz)')
ylabel('Vest + Visual Flow Motion (Hz)')

% format
m = min([get(gca, 'xlim'), get(gca, 'ylim')]);
M = max([get(gca, 'xlim'), get(gca, 'ylim')]);

set(gca, 'xlim', [m, M], 'ylim', [m, M]);
line(gca, [m, M], [m, M], 'linestyle', '--', 'color', 'k');



stat_med = median(stat);
mot_med = median(mot);
stat_iqr = prctile(stat, [25, 75]);
mot_iqr = prctile(mot, [25, 75]);
p_median = signrank(stat, mot);

scatter(gca, stat_med, mot_med, [], 'g', 'fill');
line(gca, stat_iqr, mot_med([1, 1]), 'color', 'g');
line(gca, stat_med([1, 1]), mot_iqr, 'color', 'g');

txt_str = sprintf('p = %.2f \nred = %i \nblue = %i\nblack = %i', ...
    p_median, ...
    n1, ...
    n2, ...
    n3);
text(gca, M, m, txt_str, 'verticalalignment', 'bottom', 'horizontalalignment', 'right');


FigureTitle(gcf, 'All mice pooled. Vest + Visual Flow. Motion vs. Stationary. Light');

% print the PDF
if save_on
    print(fullfile(save_dir, 'pooled_vestibular_vis_flow_motion_vs_stationary.pdf'), '-bestfit', '-dpdf')
end





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% BY MOUSE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


for probe_i = 1 : length(probe_fname)
    
    this_rec = ismember(T.probe_name, probe_fname{probe_i});
    cluster_ids = unique(T.cluster_id(this_rec));
    
    figure('position', [680, 30, 1015, 948]);
    hold on;
    
    stat = [];
    mot = [];
    p_all = [];
    
    n1 = 0;
    n2 = 0;
    n3 = 0;
    
    for clust_i = 1 : length(cluster_ids)
        
        this_cluster = T.cluster_id == cluster_ids(clust_i);
        
        this_prot = ismember(T.protocol, 'StageOnly');
        
        idx = this_rec & this_cluster & this_prot;
        
        stationary_rate = T.stationary_firing_rate(idx);
        motion_rate = T.motion_firing_rate(idx);
        
        p = signrank(stationary_rate, motion_rate);
        
        if p < 0.05 && (nanmedian(stationary_rate) < nanmedian(motion_rate))
            n1 = n1 + 1;
            col = 'r';
        elseif  p < 0.05 && (nanmedian(stationary_rate) > nanmedian(motion_rate))
            n2 = n2 + 1;
            col = 'b';
        else
            n3 = n3 + 1;
            col = 'k';
        end
        
        stat(end+1) = nanmedian(stationary_rate);
        mot(end+1) = nanmedian(motion_rate);
        p_all(end+1) = p;
        
        scatter(nanmedian(stationary_rate), nanmedian(motion_rate), [], col, 'fill');
    end
    
    xlabel('Stationary (Hz)')
    ylabel('Vest + Visual Flow Motion (Hz)')
    
    % format
    m = min([get(gca, 'xlim'), get(gca, 'ylim')]);
    M = max([get(gca, 'xlim'), get(gca, 'ylim')]);
    
    set(gca, 'xlim', [m, M], 'ylim', [m, M]);
    line(gca, [m, M], [m, M], 'linestyle', '--', 'color', 'k');
    
    
    stat_med = median(stat);
    mot_med = median(mot);
    stat_iqr = prctile(stat, [25, 75]);
    mot_iqr = prctile(mot, [25, 75]);
    p_median = signrank(stat, mot);
    
    scatter(gca, stat_med, mot_med, [], 'g', 'fill');
    line(gca, stat_iqr, mot_med([1, 1]), 'color', 'g');
    line(gca, stat_med([1, 1]), mot_iqr, 'color', 'g');
    
    txt_str = sprintf('p = %.2f \nred = %i \nblue = %i\nblack = %i', ...
        p_median, ...
        n1, ...
        n2, ...
        n3);
    text(gca, M, m, txt_str, 'verticalalignment', 'bottom', 'horizontalalignment', 'right');
    
    
    FigureTitle(gcf, sprintf('%s, Vest + Visual Flow. Motion vs. Stationary. Light', probe_fname{probe_i}));
    
    % print the PDF
    if save_on
        print(fullfile(save_dir, sprintf('%s_vestibular_vis_flow_motion_vs_stationary.pdf', probe_fname{probe_i})), '-bestfit', '-dpdf')
    end
end



















