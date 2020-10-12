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
save_dir = 'C:\Users\Lee\Desktop\Desktop\unity_plots\visual_flow';
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

mot_x = [];
mot_y = [];
p_all = [];

n1 = 0;
n2 = 0;
n3 = 0;

replay_of = {'Coupled', 'EncoderOnly'};

for probe_i = 1 : length(probe_fname)
    
    this_rec = ismember(T.probe_name, probe_fname{probe_i});
    cluster_ids = unique(T.cluster_id(this_rec));
    
    for clust_i = 1 : length(cluster_ids)
        
        this_cluster = T.cluster_id == cluster_ids(clust_i);
        
        this_prot_y = ismember(T.protocol, 'StageOnly');
        this_prot_x = ismember(T.protocol, 'ReplayOnly');
        
        mot_rate_y = [];
        mot_rate_x = [];
        
        for rep_i = 1 : length(replay_of)
        
            this_replay = cellfun(@(x)(isequal(x, replay_of{rep_i})), T.replay_of);
            
            idx_y = this_rec & this_cluster & this_prot_y & this_replay;
            idx_x = this_rec & this_cluster & this_prot_x & this_replay;
            
            motion_rate_y = T.motion_firing_rate(idx_y);
            motion_rate_x = T.motion_firing_rate(idx_x);
        
            m = min(length(motion_rate_y), length(motion_rate_x));
            
            mot_rate_y = [mot_rate_y; motion_rate_y(1:m)];
            mot_rate_x = [mot_rate_x; motion_rate_x(1:m)];
        end
        
        p = signrank(mot_rate_x, mot_rate_y);
        
        if p < 0.05 && (nanmedian(mot_rate_x) < nanmedian(mot_rate_y))
            n1 = n1 + 1;
            col = 'r';
        elseif  p < 0.05 && (nanmedian(mot_rate_x) > nanmedian(mot_rate_y))
            n2 = n2 + 1;
            col = 'b';
        else
            n3 = n3 + 1;
            col = 'k';
        end
        
        mot_x(end+1) = nanmedian(mot_rate_x);
        mot_y(end+1) = nanmedian(mot_rate_y);
        p_all(end+1) = p;
        
        scatter(nanmedian(mot_rate_x), nanmedian(mot_rate_y), [], col, 'fill');
    end
end

xlabel('Visual Flow Only (Hz)')
ylabel('Vest + Visual Flow (Hz)')

% format
m = min([get(gca, 'xlim'), get(gca, 'ylim')]);
M = max([get(gca, 'xlim'), get(gca, 'ylim')]);

set(gca, 'xlim', [m, M], 'ylim', [m, M]);
line(gca, [m, M], [m, M], 'linestyle', '--', 'color', 'k');



mot_x_med = median(mot_x);
mot_y_med = median(mot_y);
mot_x_iqr = prctile(mot_x, [25, 75]);
mot_y_iqr = prctile(mot_y, [25, 75]);
p_median = signrank(mot_x, mot_y);

scatter(gca, mot_x_med, mot_y_med, [], 'g', 'fill');
line(gca, mot_x_iqr, mot_y_med([1, 1]), 'color', 'g');
line(gca, mot_x_med([1, 1]), mot_y_iqr, 'color', 'g');

txt_str = sprintf('p = %.2f \nred = %i \nblue = %i\nblack = %i', ...
    p_median, ...
    n1, ...
    n2, ...
    n3);
text(gca, M, m, txt_str, 'verticalalignment', 'bottom', 'horizontalalignment', 'right');


FigureTitle(gcf, 'All mice pooled. Vest + Visual Flow Motion vs. Visual Flow Only Motion');

% print the PDF
if save_on
    print(fullfile(save_dir, 'pooled_vestibular_vis_flow_motion_vs_vis_flow_only_motion.pdf'), '-bestfit', '-dpdf')
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% BY MOUSE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

replay_of = {'Coupled', 'EncoderOnly'};

for probe_i = 1 : length(probe_fname)
    
    this_rec = ismember(T.probe_name, probe_fname{probe_i});
    cluster_ids = unique(T.cluster_id(this_rec));
    
    figure('position', [680, 30, 1015, 948]);
    hold on;
    
    mot_x = [];
    mot_y = [];
    p_all = [];
    
    n1 = 0;
    n2 = 0;
    n3 = 0;
    
    for clust_i = 1 : length(cluster_ids)
        
        this_cluster = T.cluster_id == cluster_ids(clust_i);
        
        this_prot_y = ismember(T.protocol, 'StageOnly');
        this_prot_x = ismember(T.protocol, 'ReplayOnly');
        
        mot_rate_y = [];
        mot_rate_x = [];
        
        for rep_i = 1 : length(replay_of)
        
            this_replay = cellfun(@(x)(isequal(x, replay_of{rep_i})), T.replay_of);
            
            idx_y = this_rec & this_cluster & this_prot_y & this_replay;
            idx_x = this_rec & this_cluster & this_prot_x & this_replay;
            
            motion_rate_y = T.motion_firing_rate(idx_y);
            motion_rate_x = T.motion_firing_rate(idx_x);
        
            m = min(length(motion_rate_y), length(motion_rate_x));
            
            mot_rate_y = [mot_rate_y; motion_rate_y(1:m)];
            mot_rate_x = [mot_rate_x; motion_rate_x(1:m)];
        end
        
        p = signrank(mot_rate_x, mot_rate_y);
        
        if p < 0.05 && (nanmedian(mot_rate_x) < nanmedian(mot_rate_y))
            n1 = n1 + 1;
            col = 'r';
        elseif  p < 0.05 && (nanmedian(mot_rate_x) > nanmedian(mot_rate_y))
            n2 = n2 + 1;
            col = 'b';
        else
            n3 = n3 + 1;
            col = 'k';
        end
        
        mot_x(end+1) = nanmedian(mot_rate_x);
        mot_y(end+1) = nanmedian(mot_rate_y);
        p_all(end+1) = p;
        
        scatter(nanmedian(mot_rate_x), nanmedian(mot_rate_y), [], col, 'fill');
    end
    
    xlabel('Visual Flow Only (Hz)')
    ylabel('Vest + Visual Flow Motion (Hz)')
    
    % format
    m = min([get(gca, 'xlim'), get(gca, 'ylim')]);
    M = max([get(gca, 'xlim'), get(gca, 'ylim')]);
    
    set(gca, 'xlim', [m, M], 'ylim', [m, M]);
    line(gca, [m, M], [m, M], 'linestyle', '--', 'color', 'k');
    
    
    
    mot_x_med = median(mot_x);
    mot_y_med = median(mot_y);
    mot_x_iqr = prctile(mot_x, [25, 75]);
    mot_y_iqr = prctile(mot_y, [25, 75]);
    p_median = signrank(mot_x, mot_y);
    
    scatter(gca, mot_x_med, mot_y_med, [], 'g', 'fill');
    line(gca, mot_x_iqr, mot_y_med([1, 1]), 'color', 'g');
    line(gca, mot_x_med([1, 1]), mot_y_iqr, 'color', 'g');
    
    txt_str = sprintf('p = %.2f \nred = %i \nblue = %i\nblack = %i', ...
        p_median, ...
        n1, ...
        n2, ...
        n3);
    text(gca, M, m, txt_str, 'verticalalignment', 'bottom', 'horizontalalignment', 'right');
    
    
    FigureTitle(gcf, sprintf('%s, Vest + Visual Flow Motion vs. Visual Flow Only Motion', probe_fname{probe_i}));
    
    % print the PDF
    if save_on
        print(fullfile(save_dir, sprintf('%s_vestibular_vis_flow_motion_vs_vis_flow_only_motion.pdf', probe_fname{probe_i})), '-bestfit', '-dpdf')
    end
end
















