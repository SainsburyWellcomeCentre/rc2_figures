% compare responses between all conditions
input('sure?')
clear all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OPTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% name of the probe recordings to analyze
probe_fname = {'CA_176_1_rec1_rec2_rec3', ...
               'CA_176_3_rec1_rec2_rec3', ...
               'CAA-1112414_restricted_rec1_rec2_rec3', ...
               'CAA-1112416_rec1_rec2_rec3', ...
               'CAA-1112417_rec1_rec2_rec3'};

table_dir = 'C:\Users\Lee\Documents\mvelez\data\tables\stationary_vs_motion';

% location in which to save PDF output
save_dir = 'C:\Users\Lee\Desktop\Desktop\unity_plots\darkness\motion_all_vs_all';
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
protocols           = {'Coupled', 'EncoderOnly', 'StageOnly'};
% label to give to each protocol on the plots
label               = {'LV', 'L', 'V', 'S'};



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
            
            r = r + 1;
            idx{r, 1} = [probe_i, clust_i, prot_i];
            idx{r, 2} = this_rec & this_cluster & this_protocol;
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
        
        for prot_i = 1 : length(protocols)
            for prot_j = prot_i+1 : length(protocols)+1
                
                ri = find(cellfun(@(x)(isequal(x, [probe_i, clust_i, prot_i])), idx(:, 1)));
                if prot_j <= length(protocols)
                    rj = find(cellfun(@(x)(isequal(x, [probe_i, clust_i, prot_j])), idx(:, 1)));
                end
                
                sp_i = (prot_i - 1)*(length(protocols)+1) + prot_j;
                
                h_ax = subplot(length(protocols)+1, length(protocols)+1, sp_i);
                
                if prot_j <= length(protocols)
                    motion_rate_x = T.motion_firing_rate(idx{rj, 2});
                    motion_rate_y = T.motion_firing_rate(idx{ri, 2});
                else
                    motion_rate_x = T.stationary_firing_rate(idx{ri, 2});
                    motion_rate_y = T.motion_firing_rate(idx{ri, 2});
                end
                
                M = min(length(motion_rate_x), length(motion_rate_y));
                
                p = signrank(motion_rate_x(1:M), motion_rate_y(1:M));
                
                % create a unity plot from the data
                h_unity{prot_i, prot_j} = ClusterUnityPlot(motion_rate_x(1:M), motion_rate_y(1:M), p, h_ax);
                
                % axis labels and title
                if prot_j <= length(protocols)
                    h_unity{prot_i, prot_j}.xlabel(sprintf('%s (Hz)', label{prot_j}))
                    h_unity{prot_i, prot_j}.ylabel(sprintf('%s (Hz)', label{prot_i}))
                else
                    h_unity{prot_i, prot_j}.xlabel(sprintf('%s (Hz)', 'Stationary'))
                    h_unity{prot_i, prot_j}.ylabel(sprintf('%s (Hz)', label{prot_i}))
                end
            end
        end
        
        % make sure all axes have the same dimensions
        sync_axes([h_unity{:}])
        
        % overall figure title
        FigureTitle(gcf, sprintf('%s, Cluster %i, %s', probe_fname{probe_i}, cluster_ids(clust_i), this_region_str{1}));
        
        % make the page bigger to fit the graphs
        set(gcf, 'paperposition', [0, 0, 20, 20], 'paperpositionmode','manual', 'papersize', [20, 20]);
        
        % generate name for PDF
        save_fnames{clust_i} = fullfile(save_dir, 'pairwise_each_cluster', sprintf('%s_cluster_%03i.pdf', probe_fname{probe_i}, cluster_ids(clust_i)));
        
        % print the PDF
        if save_on
            print(save_fnames{clust_i}, '-bestfit', '-dpdf')
        end
        
    end
    
    if save_on
        % Join the PDFs with the following name
        output_fname = fullfile(save_dir, 'pairwise_each_cluster', sprintf('%s.pdf', probe_fname{probe_i}));
        join_pdfs(save_fnames, output_fname, true);
    end
    
    close all
end




%% BY RECORDING
for probe_i = 1 : length(probe_fname)
    
    this_rec = ismember(T.probe_name, probe_fname{probe_i});
    cluster_ids = unique(T.cluster_id(this_rec));
    
    figure('position', [680, 30, 1015, 948]);
    h_ax = cell(4, 4);
    
    mot_x = cell(4, 4);
    mot_y = cell(4, 4);
    p_all = cell(4, 4);
    
    n1 = zeros(4, 4);
    n2 = zeros(4, 4);
    n3 = zeros(4, 4);
    
    for prot_i = 1 : length(protocols)
        for prot_j = prot_i+1 : length(protocols)+1
            
            sp_i = (prot_i - 1)*(length(protocols)+1) + prot_j;
            h_ax{prot_i, prot_j} = subplot(length(protocols)+1, length(protocols)+1, sp_i);
            hold on;
            
            for clust_i = 1 : length(cluster_ids)
                
                this_cluster = T.cluster_id == cluster_ids(clust_i);
                this_prot_y = ismember(T.protocol, protocols{prot_i});
                if prot_j <= length(protocols)
                    this_prot_x = ismember(T.protocol, protocols{prot_j});
                end
                
                if prot_j <= length(protocols)
                    idx_x = this_rec & this_cluster & this_prot_x;
                    idx_y = this_rec & this_cluster & this_prot_y;
                else
                    idx_x = this_rec & this_cluster & this_prot_y;
                    idx_y = this_rec & this_cluster & this_prot_y;
                end
                
                if prot_j <= length(protocols)
                    motion_rate_x = T.motion_firing_rate(idx_x);
                    motion_rate_y = T.motion_firing_rate(idx_y);
                else
                    motion_rate_x = T.stationary_firing_rate(idx_x);
                    motion_rate_y = T.motion_firing_rate(idx_x);
                end
                
                M = min(length(motion_rate_x), length(motion_rate_y));
                p = signrank(motion_rate_x(1:M), motion_rate_y(1:M));
                
                if p < 0.05 && (nanmedian(motion_rate_x(1:M)) < nanmedian(motion_rate_y(1:M)))
                    n1(prot_i, prot_j) = n1(prot_i, prot_j) + 1;
                    col = 'r';
                elseif  p < 0.05 && (nanmedian(motion_rate_x(1:M)) > nanmedian(motion_rate_y(1:M)))
                    n2(prot_i, prot_j) = n2(prot_i, prot_j) + 1;
                    col = 'b';
                else
                    n3(prot_i, prot_j) = n3(prot_i, prot_j) + 1;
                    col = 'k';
                end
                
                mot_x{prot_i, prot_j}(end+1) = nanmedian(motion_rate_x(1:M));
                mot_y{prot_i, prot_j}(end+1) = nanmedian(motion_rate_y(1:M));
                p_all{prot_i, prot_j}(end+1) = p;
                
                scatter(nanmedian(motion_rate_x(1:M)), nanmedian(motion_rate_y(1:M)), [], col, 'fill');
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
        
        mot_x_med = median(mot_x{i});
        mot_y_med = median(mot_y{i});
        mot_x_iqr = prctile(mot_x{i}, [25, 75]);
        mot_y_iqr = prctile(mot_y{i}, [25, 75]);
        p_median = signrank(mot_x{i}, mot_y{i});
        
        scatter(h_ax{i}, mot_x_med, mot_y_med, [], 'g', 'fill');
        line(h_ax{i}, mot_x_iqr, mot_y_med([1, 1]), 'color', 'g');
        line(h_ax{i}, mot_x_med([1, 1]), mot_y_iqr, 'color', 'g');
        
        txt_str = sprintf('p = %.2f \nred = %i \nblue = %i\nblack = %i', ...
            p_median, ...
            n1(i), ...
            n2(i), ...
            n3(i));
        text(h_ax{i}, M, m, txt_str, 'verticalalignment', 'bottom', 'horizontalalignment', 'right');
    end
    
    FigureTitle(gcf, probe_fname{probe_i});
    
    % make the page bigger to fit the graphs
    set(gcf, 'paperposition', [0, 0, 20, 20], 'paperpositionmode','manual', 'papersize', [20, 20]);
    
    % print the PDF
    if save_on
        save_fname = fullfile(save_dir, 'pairwise_each_mouse', sprintf('%s.pdf', probe_fname{probe_i}));
        print(save_fname, '-bestfit', '-dpdf')
    end
end


















%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ALL  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('position', [680, 30, 1015, 948]);

h_ax = cell(4, 4);

mot_x = cell(4, 4);
mot_y = cell(4, 4);
p_all = cell(4, 4);

n1 = zeros(4, 4);
n2 = zeros(4, 4);
n3 = zeros(4, 4);

for prot_i = 1 : length(protocols)
    for prot_j = prot_i+1 : length(protocols)+1
        
        sp_i = (prot_i - 1)*(length(protocols)+1) + prot_j;
        h_ax{prot_i, prot_j} = subplot(length(protocols)+1, length(protocols)+1, sp_i);
        hold on;
        
        for probe_i = 1 : length(probe_fname)
            
            this_rec = ismember(T.probe_name, probe_fname{probe_i});
            cluster_ids = unique(T.cluster_id(this_rec));
            
            for clust_i = 1 : length(cluster_ids)
                
                this_cluster = T.cluster_id == cluster_ids(clust_i);
                this_prot_y = ismember(T.protocol, protocols{prot_i});
                if prot_j <= length(protocols)
                    this_prot_x = ismember(T.protocol, protocols{prot_j});
                end
                
                if prot_j <= length(protocols)
                    idx_x = this_rec & this_cluster & this_prot_x;
                    idx_y = this_rec & this_cluster & this_prot_y;
                else
                    idx_x = this_rec & this_cluster & this_prot_y;
                    idx_y = this_rec & this_cluster & this_prot_y;
                end
                
                if prot_j <= length(protocols)
                    motion_rate_x = T.motion_firing_rate(idx_x);
                    motion_rate_y = T.motion_firing_rate(idx_y);
                else
                    motion_rate_x = T.stationary_firing_rate(idx_x);
                    motion_rate_y = T.motion_firing_rate(idx_x);
                end
                
                M = min(length(motion_rate_x), length(motion_rate_y));
                p = signrank(motion_rate_x(1:M), motion_rate_y(1:M));
                
                if p < 0.05 && (nanmedian(motion_rate_x(1:M)) < nanmedian(motion_rate_y(1:M)))
                    n1(prot_i, prot_j) = n1(prot_i, prot_j) + 1;
                    col = 'r';
                elseif  p < 0.05 && (nanmedian(motion_rate_x(1:M)) > nanmedian(motion_rate_y(1:M)))
                    n2(prot_i, prot_j) = n2(prot_i, prot_j) + 1;
                    col = 'b';
                else
                    n3(prot_i, prot_j) = n3(prot_i, prot_j) + 1;
                    col = 'k';
                end
                
                mot_x{prot_i, prot_j}(end+1) = nanmedian(motion_rate_x(1:M));
                mot_y{prot_i, prot_j}(end+1) = nanmedian(motion_rate_y(1:M));
                p_all{prot_i, prot_j}(end+1) = p;
                
                scatter(nanmedian(motion_rate_x(1:M)), nanmedian(motion_rate_y(1:M)), [], col, 'fill');
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
    
    mot_x_med = median(mot_x{i});
    mot_y_med = median(mot_y{i});
    mot_x_iqr = prctile(mot_x{i}, [25, 75]);
    mot_y_iqr = prctile(mot_y{i}, [25, 75]);
    p_median = signrank(mot_x{i}, mot_y{i});
    
    scatter(h_ax{i}, mot_x_med, mot_y_med, [], 'g', 'fill');
    line(h_ax{i}, mot_x_iqr, mot_y_med([1, 1]), 'color', 'g');
    line(h_ax{i}, mot_x_med([1, 1]), mot_y_iqr, 'color', 'g');
    
    txt_str = sprintf('p = %.2f \nred = %i \nblue = %i\nblack = %i', ...
        p_median, ...
        n1(i), ...
        n2(i), ...
        n3(i));
    text(h_ax{i}, M, m, txt_str, 'verticalalignment', 'bottom', 'horizontalalignment', 'right');
end


FigureTitle(gcf, 'pooled, darkness');

% make the page bigger to fit the graphs
set(gcf, 'paperposition', [0, 0, 20, 20], 'paperpositionmode','manual', 'papersize', [20, 20]);

% print the PDF
if save_on
    print(fullfile(save_dir, 'pooled.pdf'), '-bestfit', '-dpdf')
end
















