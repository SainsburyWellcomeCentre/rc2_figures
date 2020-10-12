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
save_dir = 'C:\Users\Lee\Desktop\Desktop\unity_plots\visual_flow\stationary_vs_motion';
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
%% PLOTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% which protocols to analyze
protocols           = {'Coupled', 'EncoderOnly', 'StageOnly', 'StageOnly', 'ReplayOnly', 'ReplayOnly'};
% which protocol is replayed
replay_of           = {'', '', 'Coupled', 'EncoderOnly', 'Coupled', 'EncoderOnly'};
% label to give to each protocol on the plots
label               = {'LVF', 'LF', 'V(LVF)', 'V(LF)', 'F(LVF)', 'F(LF)'};


r = 0;
idx = {};
for probe_i = 1 : length(probe_fname)
    
    % entries for this recording
    this_rec = ismember(T.probe_name, probe_fname{probe_i});
    
    % the clusters in this recording
    cluster_ids = unique(T.cluster_id(this_rec));
    
    for clust_i = 1 : length(cluster_ids)
        
        this_cluster = T.cluster_id == cluster_ids(clust_i);
        
        for prot_i = 1 : length(protocols)
            
            this_protocol = ismember(T.protocol, protocols{prot_i});
            
            this_replay = cellfun(@(x)(isequal(x, replay_of{prot_i})), T.replay_of);
            
            r = r + 1;
            idx{r, 1} = [probe_i, clust_i, prot_i];
            idx{r, 2} = this_rec & this_cluster & this_protocol & this_replay;
        end
    end
end


%% STATIONARY VS MOTION BY CLUSTER
idx_array = cat(1, idx{:, 1});

for probe_i = 1 : length(probe_fname)
    
    % entries for this recording
    this_rec = ismember(T.probe_name, probe_fname{probe_i});
    
    % the clusters in this recording
    cluster_ids = unique(T.cluster_id(this_rec));
    
    save_fnames = {};
    
    for clust_i = 1 : length(cluster_ids)
        
        this_cluster = T.cluster_id == cluster_ids(clust_i);
        this_region_str = unique(T.cluster_region(this_cluster));
        
        figure('position', [680, 30, 1015, 948]);
        
        for prot_i = 1 : length(protocols)
            
            r = find(cellfun(@(x)(isequal(x, [probe_i, clust_i, prot_i])), idx(:, 1)));
            
            h_ax = subplot(3, 2, prot_i);
            
            stationary_rate = T.stationary_firing_rate(idx{r, 2});
            motion_rate = T.motion_firing_rate(idx{r, 2});
            
            p = signrank(stationary_rate, motion_rate);
            
            % create a unity plot from the data
            h_unity{prot_i} = ClusterUnityPlot(stationary_rate, motion_rate, p, h_ax);
            
            % axis labels and title
            h_unity{prot_i}.xlabel('Stationary (Hz)')
            h_unity{prot_i}.ylabel('Motion (Hz)')
            h_unity{prot_i}.title(label{prot_i})
        end
        
        % make sure all axes have the same dimensions
        sync_axes([h_unity{:}])
        
        % overall figure title
        FigureTitle(gcf, sprintf('%s, Cluster %i, %s', probe_fname{probe_i}, cluster_ids(clust_i), this_region_str{1}));
        
        % generate name for PDF
        save_fnames{clust_i} = fullfile(save_dir, 'each_cluster', sprintf('%s_cluster_%03i.pdf', probe_fname{probe_i}, cluster_ids(clust_i)));
        
        % print the PDF
        if save_on
            print(save_fnames{clust_i}, '-bestfit', '-dpdf')
        end
    end
    
    if save_on
        % Join the PDFs with the following name
        output_fname = fullfile(save_dir, 'each_cluster', sprintf('%s.pdf', probe_fname{probe_i}));
        join_pdfs(save_fnames, output_fname, true);
    end
    
    close all
end




%% STATIONARY VS. MOTION BY RECORDING
stationary_median = {};
motion_median = {};
p = {};

for probe_i = 1 : length(probe_fname)
    
    figure('position', [680          30        1015         948]);
    
    % entries for this recording
    this_rec = ismember(T.probe_name, probe_fname{probe_i});
    
    % the clusters in this recording
    cluster_ids = unique(T.cluster_id(this_rec));
    
    h_ax = {};
    
    
    for prot_i = 1 : length(protocols)
        
        h_ax{prot_i} = subplot(3, 2, prot_i);
        hold on;
        
        c = 0;
        for clust_i = 1 : length(cluster_ids)
            
            r = find(cellfun(@(x)(isequal(x, [probe_i, clust_i, prot_i])), idx(:, 1)));
            
            stationary_rate = T.stationary_firing_rate(idx{r, 2});
            motion_rate = T.motion_firing_rate(idx{r, 2});
            
            c = c + 1;
            stationary_median{probe_i}{prot_i}(c) = median(stationary_rate);
            motion_median{probe_i}{prot_i}(c) = median(motion_rate);
            p{probe_i}{prot_i}(c) = signrank(stationary_rate, motion_rate);
            
            if p{probe_i}{prot_i}(c) < 0.05 && (stationary_median{probe_i}{prot_i}(c) < motion_median{probe_i}{prot_i}(c))
                scatter(stationary_median{probe_i}{prot_i}(c), motion_median{probe_i}{prot_i}(c), [], 'r', 'fill');
            elseif p{probe_i}{prot_i}(c) < 0.05 && (stationary_median{probe_i}{prot_i}(c) > motion_median{probe_i}{prot_i}(c))
                scatter(stationary_median{probe_i}{prot_i}(c), motion_median{probe_i}{prot_i}(c), [], 'b', 'fill');
            else
                scatter(stationary_median{probe_i}{prot_i}(c), motion_median{probe_i}{prot_i}(c), [], 'k', 'fill');
            end
        end
        
        xlabel('Stationary (Hz)');
        ylabel('Motion (Hz)');
        title(label{prot_i});
        
        
        
    end
    
    m = inf;
    M = -inf;
    for i = 1 : length(h_ax)
        m = min([m, get(h_ax{i}, 'xlim'), get(h_ax{i}, 'ylim')]);
        M = max([M, get(h_ax{i}, 'xlim'), get(h_ax{i}, 'ylim')]);
    end

    for i = 1 : length(h_ax)
        set(h_ax{i}, 'xlim', [m, M], 'ylim', [m, M]);
        line(h_ax{i}, [m, M], [m, M], 'linestyle', '--', 'color', 'k');
    end
    
    for i = 1 : length(h_ax)
        
        stationary_median_median = median(stationary_median{probe_i}{i});
        motion_median_median = median(motion_median{probe_i}{i});
        stationary_median_iqr = prctile(stationary_median{probe_i}{i}, [25, 75]);
        motion_median_iqr = prctile(motion_median{probe_i}{i}, [25, 75]);
        p_median = signrank(stationary_median{probe_i}{i}, motion_median{probe_i}{i});
        
        scatter(h_ax{i}, stationary_median_median, motion_median_median, [], 'g', 'fill');
        line(h_ax{i}, stationary_median_iqr, motion_median_median([1, 1]), 'color', 'g');
        line(h_ax{i}, stationary_median_median([1, 1]), motion_median_iqr, 'color', 'g');
        
        txt_str = sprintf('p = %.2f \nred = %i \nblue = %i\nblack = %i', ...
            p_median, ...
            sum(p{probe_i}{i} < 0.05 & (stationary_median{probe_i}{i} < motion_median{probe_i}{i})), ...
            sum(p{probe_i}{i} < 0.05 & (stationary_median{probe_i}{i} > motion_median{probe_i}{i})), ...
            sum(p{probe_i}{i} > 0.05));
        text(h_ax{i}, M, m, txt_str, 'verticalalignment', 'bottom', 'horizontalalignment', 'right');
    end
    
    % overall figure title
    FigureTitle(gcf, probe_fname{probe_i});
    
    % print the PDF
    if save_on
        save_fname = fullfile(save_dir, 'each_mouse', sprintf('%s.pdf', probe_fname{probe_i}));
        print(save_fname, '-bestfit', '-dpdf')
    end
end



%% STATIONARY VS. MOTION ALL
figure('position', [680, 30, 1015, 948]);
h_ax = {};
stat = {};
mot = {};
n1 = zeros(1, 6);
n2 = zeros(1, 6);
n3 = zeros(1, 6);
c = zeros(1, length(stationary_median));
for i = 1 : length(stationary_median)
    for j = 1 : length(stationary_median{1})
        
        h_ax{j} = subplot(3, 2, j); hold on;
        
        for k = 1 : length(stationary_median{i}{j})
            if p{i}{j}(k) < 0.05 && (stationary_median{i}{j}(k) < motion_median{i}{j}(k))
                n1(j) = n1(j) + 1;
                col = 'r';
            elseif p{i}{j}(k) < 0.05 && (stationary_median{i}{j}(k) > motion_median{i}{j}(k))
                n2(j) = n2(j) + 1;
                col = 'b';
            else
                n3(j) = n3(j) + 1;
                col = 'k';
            end
            c(i) = c(i) + 1;
            stat{j}(c(i)) = stationary_median{i}{j}(k);
            mot{j}(c(i)) = motion_median{i}{j}(k);
            p_all{j}(c(i)) = p{i}{j}(k);
            
            scatter(h_ax{j}, stat{j}(c(i)), mot{j}(c(i)), [], col, 'fill');
        end
        
        xlabel('Stationary (Hz)');
        ylabel('Motion (Hz)');
        title(label{j});
    end
end

% format
m = inf;
M = -inf;
for i = 1 : length(h_ax)
    m = min([m, get(h_ax{i}, 'xlim'), get(h_ax{i}, 'ylim')]);
    M = max([M, get(h_ax{i}, 'xlim'), get(h_ax{i}, 'ylim')]);
end

for i = 1 : length(h_ax)
    set(h_ax{i}, 'xlim', [m, M], 'ylim', [m, M]);
    line(h_ax{i}, [m, M], [m, M], 'linestyle', '--', 'color', 'k');
end

for i = 1 : length(h_ax)
    
    stat_med = median(stat{i});
    mot_med = median(mot{i});
    stat_iqr = prctile(stat{i}, [25, 75]);
    mot_iqr = prctile(mot{i}, [25, 75]);
    p_median = signrank(stat{i}, mot{i});
    
    scatter(h_ax{i}, stat_med, mot_med, [], 'g', 'fill');
    line(h_ax{i}, stat_iqr, mot_med([1, 1]), 'color', 'g');
    line(h_ax{i}, stat_med([1, 1]), mot_iqr, 'color', 'g');
    
    txt_str = sprintf('p = %.2f \nred = %i \nblue = %i\nblack = %i', ...
        p_median, ...
        n1(i), ...
        n2(i), ...
        n3(i));
    text(h_ax{i}, M, m, txt_str, 'verticalalignment', 'bottom', 'horizontalalignment', 'right');
end


FigureTitle(gcf, 'pooled, visual flow');

% make the page bigger to fit the graphs
set(gcf, 'paperposition', [0, 0, 20, 20], 'paperpositionmode','manual', 'papersize', [20, 20]);

% print the PDF
if save_on
    print(fullfile(save_dir, 'pooled.pdf'), '-bestfit', '-dpdf')
end
