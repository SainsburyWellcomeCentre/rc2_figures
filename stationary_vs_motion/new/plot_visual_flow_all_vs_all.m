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
save_dir = 'C:\Users\Lee\Desktop\Desktop\unity_plots\visual_flow\motion_all_vs_all';
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


%% BY CLUSTER
for probe_i = 1 : length(probe_fname)
    
    % entries for this recording
    this_rec = ismember(T.probe_name, probe_fname{probe_i});
    
    % the clusters in this recording
    cluster_ids = unique(T.cluster_id(this_rec));
    
    h_unity = {};
    save_fnames = {};
    
    for clust_i = 1 : length(cluster_ids)
        
        this_cluster = T.cluster_id == cluster_ids(clust_i);
        this_region_str = unique(T.cluster_region(this_cluster));
        
        figure('position', [680          30        1015         948]);
        
        for prot_i = 1 : length(protocols)-1
            for prot_j = prot_i+1 : length(protocols)
                
                ri = find(cellfun(@(x)(isequal(x, [probe_i, clust_i, prot_i])), idx(:, 1)));
                rj = find(cellfun(@(x)(isequal(x, [probe_i, clust_i, prot_j])), idx(:, 1)));
                
                sp_i = (prot_i - 1)*length(protocols) + prot_j;
                
                h_ax = subplot(length(protocols), length(protocols), sp_i);
                
                motion_ratei = T.motion_firing_rate(idx{ri, 2});
                motion_ratej = T.motion_firing_rate(idx{rj, 2});
                
                M = min(length(motion_ratei), length(motion_ratej));
                
                p = signrank(motion_ratej(1:M), motion_ratei(1:M));
                
                % create a unity plot from the data
                h_unity{prot_i, prot_j} = ClusterUnityPlot(motion_ratej(1:M), motion_ratei(1:M), p, h_ax);
                
                % axis labels and title
                h_unity{prot_i, prot_j}.xlabel(sprintf('%s (Hz)', label{prot_j}))
                h_unity{prot_i, prot_j}.ylabel(sprintf('%s (Hz)', label{prot_i}))
            end
        end
        
        % make sure all axes have the same dimensions
        sync_axes([h_unity{:}])
        
        % overall figure title
        FigureTitle(gcf, sprintf('%s, Cluster %i, %s', probe_fname{probe_i}, cluster_ids(clust_i), this_region_str{1}));
        
        % make the page bigger to fit the graphs
        set(gcf, 'paperposition', [0, 0, 20, 20], 'paperpositionmode','manual', 'papersize', [20, 20]);
        
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




%% BY RECORDING
motioni_median = {};
motionj_median = {};
p = {};

for probe_i = 1 : length(probe_fname)
    
    figure('position', [680          30        1015         948]);
    
    % entries for this recording
    this_rec = ismember(T.probe_name, probe_fname{probe_i});
    
    % the clusters in this recording
    cluster_ids = unique(T.cluster_id(this_rec));
    
    h_ax = {};
    
    for prot_i = 1 : length(protocols)-1
        for prot_j = prot_i+1 : length(protocols)
            
            sp_i = (prot_i - 1)*length(protocols) + prot_j;
                
            h_ax{prot_i, prot_j} = subplot(length(protocols), length(protocols), sp_i);
            hold on;
            
            c = 0;
            for clust_i = 1 : length(cluster_ids)
                
                ri = find(cellfun(@(x)(isequal(x, [probe_i, clust_i, prot_i])), idx(:, 1)));
                rj = find(cellfun(@(x)(isequal(x, [probe_i, clust_i, prot_j])), idx(:, 1)));
                
                motion_ratei = T.motion_firing_rate(idx{ri, 2});
                motion_ratej = T.motion_firing_rate(idx{rj, 2});
                
                M = min(length(motion_ratei), length(motion_ratej));
                
                c = c + 1;
                motioni_median{probe_i}{prot_i, prot_j}(c) = median(motion_ratei(1:M));
                motionj_median{probe_i}{prot_i, prot_j}(c) = median(motion_ratej(1:M));
                
                p{probe_i}{prot_i, prot_j}(c) = signrank(motion_ratei(1:M), motion_ratej(1:M));
                
                if p{probe_i}{prot_i, prot_j}(c) < 0.05 && (motionj_median{probe_i}{prot_i, prot_j}(c) < motioni_median{probe_i}{prot_i, prot_j}(c))
                    scatter(motionj_median{probe_i}{prot_i, prot_j}(c), motioni_median{probe_i}{prot_i, prot_j}(c), [], 'r', 'fill');
                elseif p{probe_i}{prot_i, prot_j}(c) < 0.05 && (motionj_median{probe_i}{prot_i, prot_j}(c) > motioni_median{probe_i}{prot_i, prot_j}(c))
                    scatter(motionj_median{probe_i}{prot_i, prot_j}(c), motioni_median{probe_i}{prot_i, prot_j}(c), [], 'b', 'fill');
                else
                    scatter(motionj_median{probe_i}{prot_i, prot_j}(c), motioni_median{probe_i}{prot_i, prot_j}(c), [], 'k', 'fill');
                end
            end
            
            xlabel(label{prot_j});
            ylabel(label{prot_i});
        end
    end
    
    m = inf;
    M = -inf;
    for i = 1 : numel(h_ax)
        if isempty(h_ax{i}); continue; end
        m = min([m, get(h_ax{i}, 'xlim'), get(h_ax{i}, 'ylim')]);
        M = max([M, get(h_ax{i}, 'xlim'), get(h_ax{i}, 'ylim')]);
    end

    for i = 1 : numel(h_ax)
        if isempty(h_ax{i}); continue; end
        set(h_ax{i}, 'xlim', [m, M], 'ylim', [m, M]);
        line(h_ax{i}, [m, M], [m, M], 'linestyle', '--', 'color', 'k');
    end
    
    for i = 1 : numel(h_ax)
        
        if isempty(h_ax{i}); continue; end
        
        stationary_median_median = median(motionj_median{probe_i}{i});
        motion_median_median = median(motioni_median{probe_i}{i});
        stationary_median_iqr = prctile(motionj_median{probe_i}{i}, [25, 75]);
        motion_median_iqr = prctile(motioni_median{probe_i}{i}, [25, 75]);
        p_median = signrank(motionj_median{probe_i}{i}, motioni_median{probe_i}{i});
        
        scatter(h_ax{i}, stationary_median_median, motion_median_median, [], 'g', 'fill');
        line(h_ax{i}, stationary_median_iqr, motion_median_median([1, 1]), 'color', 'g');
        line(h_ax{i}, stationary_median_median([1, 1]), motion_median_iqr, 'color', 'g');
        
        txt_str = sprintf('p = %.2f \nred = %i \nblue = %i\nblack = %i', ...
            p_median, ...
            sum(p{probe_i}{i} < 0.05 & (motionj_median{probe_i}{i} < motioni_median{probe_i}{i})), ...
            sum(p{probe_i}{i} < 0.05 & (motionj_median{probe_i}{i} > motioni_median{probe_i}{i})), ...
            sum(p{probe_i}{i} > 0.05));
        text(h_ax{i}, M, m, txt_str, 'verticalalignment', 'bottom', 'horizontalalignment', 'right');
    end
    
    % overall figure title
    FigureTitle(gcf, probe_fname{probe_i});
    
    % make the page bigger to fit the graphs
    set(gcf, 'paperposition', [0, 0, 20, 20], 'paperpositionmode','manual', 'papersize', [20, 20]);
        
    
    % print the PDF
    if save_on
        save_fname = fullfile(save_dir, 'each_mouse', sprintf('%s.pdf', probe_fname{probe_i}));
        print(save_fname, '-bestfit', '-dpdf')
    end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ALL  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('position', [680, 30, 1015, 948]);

h_ax = cell(6, 6);

stat = cell(6, 6);
mot = cell(6, 6);
p_all = cell(6, 6);

n1 = zeros(6, 6);
n2 = zeros(6, 6);
n3 = zeros(6, 6);

for prot_i = 1 : length(protocols)-1
    for prot_j = prot_i+1 : length(protocols)
        
        sp_i = (prot_i - 1)*(length(protocols)) + prot_j;
        h_ax{prot_i, prot_j} = subplot(length(protocols), length(protocols), sp_i);
        hold on;
        
        for probe_i = 1 : length(probe_fname)
            
            this_rec = ismember(T.probe_name, probe_fname{probe_i});
            cluster_ids = unique(T.cluster_id(this_rec));
            
            for clust_i = 1 : length(cluster_ids)
                
                this_cluster = T.cluster_id == cluster_ids(clust_i);
                
                this_prot_y = ismember(T.protocol, protocols{prot_i});
                replay_of_y = cellfun(@(x)(isequal(x, replay_of{prot_i})), T.replay_of);
                
                this_prot_x = ismember(T.protocol, protocols{prot_j});
                replay_of_x = cellfun(@(x)(isequal(x, replay_of{prot_j})), T.replay_of);
                
                idx_x = this_rec & this_cluster & this_prot_x & replay_of_x;
                idx_y = this_rec & this_cluster & this_prot_y & replay_of_y;
                
                stationary_rate = T.motion_firing_rate(idx_x);
                motion_rate = T.motion_firing_rate(idx_y);
                
                M = min(length(stationary_rate), length(motion_rate));
                p = signrank(stationary_rate(1:M), motion_rate(1:M));
                
                if p < 0.05 && (nanmedian(stationary_rate(1:M)) < nanmedian(motion_rate(1:M)))
                    n1(prot_i, prot_j) = n1(prot_i, prot_j) + 1;
                    col = 'r';
                elseif  p < 0.05 && (nanmedian(stationary_rate(1:M)) > nanmedian(motion_rate(1:M)))
                    n2(prot_i, prot_j) = n2(prot_i, prot_j) + 1;
                    col = 'b';
                else
                    n3(prot_i, prot_j) = n3(prot_i, prot_j) + 1;
                    col = 'k';
                end
                
                stat{prot_i, prot_j}(end+1) = nanmedian(stationary_rate(1:M));
                mot{prot_i, prot_j}(end+1) = nanmedian(motion_rate(1:M));
                p_all{prot_i, prot_j}(end+1) = p;
                
                scatter(nanmedian(stationary_rate(1:M)), nanmedian(motion_rate(1:M)), [], col, 'fill');
            end
        end
        
        xlabel([label{prot_j}, ' (Hz)'])
        ylabel([label{prot_i}, ' (Hz)'])
    end
end

% format
m = inf;
M = -inf;
for i = 1 : numel(h_ax)
    if isempty(h_ax{i}); continue; end
    m = min([m, get(h_ax{i}, 'xlim'), get(h_ax{i}, 'ylim')]);
    M = max([M, get(h_ax{i}, 'xlim'), get(h_ax{i}, 'ylim')]);
end

for i = 1 : numel(h_ax)
    if isempty(h_ax{i}); continue; end
    set(h_ax{i}, 'xlim', [m, M], 'ylim', [m, M]);
    line(h_ax{i}, [m, M], [m, M], 'linestyle', '--', 'color', 'k');
end

for i = 1 : numel(h_ax)
    
    if isempty(h_ax{i}); continue; end
    
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

