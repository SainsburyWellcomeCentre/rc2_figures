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

formatted_dir = 'C:\Users\Lee\Documents\mvelez\data\formatted_data';
table_dir = 'C:\Users\Lee\Documents\mvelez\data\tables\stationary_vs_motion';

% location in which to save PDF output
save_dir = 'C:\Users\Lee\Desktop\Desktop\mi_vs_depth_plots\visual_flow\motion_all_vs_all';
save_on = true;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CALCULATE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
T = table();
boundaries = {};
regions = {};

% for each recording
for probe_i = 1 : length(probe_fname)
    
    table_fname = fullfile(table_dir, sprintf('%s_stationary_vs_motion_table.mat', probe_fname{probe_i}));
    temp = load(table_fname, 'T');
    T = [T; temp.T];
    
    load(fullfile(formatted_dir, probe_fname{probe_i}), 'anatomy', 'clusters');
    
    % store the boundaries of the layers
    boundaries{probe_i} = anatomy.region_boundaries;
    regions{probe_i} = anatomy.region_str;
    
    depth_in_region{probe_i} = get_region_relative_depth(anatomy, clusters);
end

% restrict table to cortical clusters
is_cortical = ismember(T.cluster_region, {'VISp1', 'VISp2/3', 'VISp4', 'VISp5', 'VISp6a', 'VISp6b', 'VISpX'});
T(~is_cortical, :) = [];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% AVERAGE BOUNDARIES ACROSS RECORDINGS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% average the boundary positions for these regions
layers = {'VISp1', 'VISp2/3', 'VISp4', 'VISp5', 'VISp6a', 'VISp6b'};

% preallocate
% matrix for layers of boundaries (+1 because there is one more boundary
% than number of layers)
avg_boundaries = nan(length(layers)+1, length(probe_fname));

% for each layer
for layer_i = 1 : length(layers)
    % for each recording
    for probe_i = 1 : length(probe_fname)
        
        % find the boundary for the layer
        r_i = find(strcmp(layers{layer_i}, regions{probe_i}));
        
        % on the first layer we need above and below, otherwise just below
        if layer_i == 1
            avg_boundaries(1, probe_i) = boundaries{probe_i}(r_i);
            avg_boundaries(2, probe_i) = boundaries{probe_i}(r_i+1);
        else
            avg_boundaries(layer_i+1, probe_i) = boundaries{probe_i}(r_i+1);
        end
    end
end

% average their distances from the probe tip
avg_boundaries = nanmean(avg_boundaries, 2);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PLOTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% which protocols to analyze
protocols           = {'Coupled', 'EncoderOnly', 'StageOnly', 'StageOnly', 'ReplayOnly', 'ReplayOnly'};
% which protocol is replayed
replay_of           = {'', '', 'Coupled', 'EncoderOnly', 'Coupled', 'EncoderOnly'};
% label to give to each protocol on the plots
label               = {'LVF', 'LF', 'V(LVF)', 'V(LF)', 'F(LVF)', 'F(LF)'};




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ALL  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('position', [680, 30, 1015, 948]);

h_ax = cell(6, 6);

mot_x = cell(6, 6);
mot_y = cell(6, 6);
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
                
                this_region = T.cluster_region(find(this_cluster, 1));
                
                this_prot_y = ismember(T.protocol, protocols{prot_i});
                replay_of_y = cellfun(@(x)(isequal(x, replay_of{prot_i})), T.replay_of);
                
                this_prot_x = ismember(T.protocol, protocols{prot_j});
                replay_of_x = cellfun(@(x)(isequal(x, replay_of{prot_j})), T.replay_of);
                
                idx_x = this_rec & this_cluster & this_prot_x & replay_of_x;
                idx_y = this_rec & this_cluster & this_prot_y & replay_of_y;
                
                motion_rate_x = T.motion_firing_rate(idx_x);
                motion_rate_y = T.motion_firing_rate(idx_y);
                
                M = min(length(motion_rate_x), length(motion_rate_y));
                p = signrank(motion_rate_x(1:M), motion_rate_y(1:M));
                
                if p < 0.05 && (nanmedian(motion_rate_x(1:M)) < nanmedian(motion_rate_y(1:M)))
                    n1(prot_i, prot_j) = n1(prot_i, prot_j) + 1;
                    sz = 30;
                    col = 'r';
                elseif  p < 0.05 && (nanmedian(motion_rate_x(1:M)) > nanmedian(motion_rate_y(1:M)))
                    n2(prot_i, prot_j) = n2(prot_i, prot_j) + 1;
                    sz = 30;
                    col = 'b';
                else
                    n3(prot_i, prot_j) = n3(prot_i, prot_j) + 1;
                    sz = 10;
                    col = 'k';
                end
                
                fr_x = nanmedian(motion_rate_x(1:M));
                fr_y = nanmedian(motion_rate_y(1:M));
                
                d = depth_in_region{probe_i}(clust_i);
                
                if strcmp(this_region, 'VISp4')
                    fprintf('%.2f/%.2f\n', fr_x, fr_y);
                end
                
                mi = (fr_y - fr_x) / (fr_y + fr_x);
                
                % get index of region in which cluster is
                r_i = find(strcmp(this_region, layers));
                
                % compute upper and lower boundaries of that region
                upper_b = avg_boundaries(r_i);
                width_b = avg_boundaries(r_i) - avg_boundaries(r_i + 1);
                
                % depth at which to plot this cluster
                plot_depth = upper_b - width_b * d;
                
                scatter(mi, plot_depth, sz, col, 'fill');
            end
        end
        
        
        % plot the layer boundaries
        for b_i = 1 : length(avg_boundaries)
            line([-1, 1],avg_boundaries(b_i)*[1, 1], 'color', 'k', 'linestyle', '--');
            if b_i > 1 && prot_i == 1 && prot_j == 6
                text(1, sum(avg_boundaries([b_i-1, b_i]))/2, layers{b_i-1}, ...
                    'horizontalalignment', 'left', 'verticalalignment', 'middle')
            end
        end
        
        % index of lower boundary for VISp6b
        l6b_i = find(strcmp('VISp6b', regions{probe_i}));
        
        % set the y-limits of axis to include bottom of VISp6b
        ylim([avg_boundaries(l6b_i+1) avg_boundaries(1)])
        
        set(gca, 'ytick', []);
        
        title(sprintf('%s vs. %s', label{prot_i}, label{prot_j}), 'interpreter', 'none');
        
        if prot_i == 1 && prot_j == 2
            xlabel('MI');
        end
    end
end

FigureTitle(gcf, 'pooled, visual flow')


% make the page bigger to fit the graphs
set(gcf, 'paperposition', [0, 0, 20, 20], 'paperpositionmode','manual', 'papersize', [20, 20]);

% print the PDF
if save_on
    print(fullfile(save_dir, 'pooled.pdf'), '-bestfit', '-dpdf')
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% BY MOUSE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for probe_i = 1 : length(probe_fname)
    
    this_rec = ismember(T.probe_name, probe_fname{probe_i});
    cluster_ids = unique(T.cluster_id(this_rec));
    
    figure('position', [680, 30, 1015, 948]);
    
    h_ax = cell(6, 6);
    
    mot_x = cell(6, 6);
    mot_y = cell(6, 6);
    p_all = cell(6, 6);
    
    n1 = zeros(6, 6);
    n2 = zeros(6, 6);
    n3 = zeros(6, 6);
    
    for prot_i = 1 : length(protocols)-1
        for prot_j = prot_i+1 : length(protocols)
            
            sp_i = (prot_i - 1)*(length(protocols)) + prot_j;
            h_ax{prot_i, prot_j} = subplot(length(protocols), length(protocols), sp_i);
            hold on;
            
            for clust_i = 1 : length(cluster_ids)
                
                this_cluster = T.cluster_id == cluster_ids(clust_i);
                
                this_region = T.cluster_region(find(this_cluster, 1));
                
                this_prot_y = ismember(T.protocol, protocols{prot_i});
                replay_of_y = cellfun(@(x)(isequal(x, replay_of{prot_i})), T.replay_of);
                
                this_prot_x = ismember(T.protocol, protocols{prot_j});
                replay_of_x = cellfun(@(x)(isequal(x, replay_of{prot_j})), T.replay_of);
                
                idx_x = this_rec & this_cluster & this_prot_x & replay_of_x;
                idx_y = this_rec & this_cluster & this_prot_y & replay_of_y;
                
                motion_rate_x = T.motion_firing_rate(idx_x);
                motion_rate_y = T.motion_firing_rate(idx_y);
                
                M = min(length(motion_rate_x), length(motion_rate_y));
                p = signrank(motion_rate_x(1:M), motion_rate_y(1:M));
                
                if p < 0.05 && (nanmedian(motion_rate_x(1:M)) < nanmedian(motion_rate_y(1:M)))
                    n1(prot_i, prot_j) = n1(prot_i, prot_j) + 1;
                    sz = 30;
                    col = 'r';
                elseif  p < 0.05 && (nanmedian(motion_rate_x(1:M)) > nanmedian(motion_rate_y(1:M)))
                    n2(prot_i, prot_j) = n2(prot_i, prot_j) + 1;
                    sz = 30;
                    col = 'b';
                else
                    n3(prot_i, prot_j) = n3(prot_i, prot_j) + 1;
                    sz = 10;
                    col = 'k';
                end
                
                fr_x = nanmedian(motion_rate_x(1:M));
                fr_y = nanmedian(motion_rate_y(1:M));
                
                d = depth_in_region{probe_i}(clust_i);
                
                if strcmp(this_region, 'VISp4')
                    fprintf('%.2f/%.2f\n', fr_x, fr_y);
                end
                
                mi = (fr_y - fr_x) / (fr_y + fr_x);
                
                % get index of region in which cluster is
                r_i = find(strcmp(this_region, regions{probe_i}));
                
                % compute upper and lower boundaries of that region
                upper_b = boundaries{probe_i}(r_i);
                width_b = boundaries{probe_i}(r_i) - boundaries{probe_i}(r_i + 1);
                
                % depth at which to plot this cluster
                plot_depth = upper_b - width_b * d;
                
                scatter(mi, plot_depth, sz, col, 'fill');
            end
            
            % plot the layer boundaries
            for b_i = 1 : length(boundaries{probe_i})
                line([-1, 1],boundaries{probe_i}(b_i)*[1, 1], 'color', 'k', 'linestyle', '--');
                if b_i > 1 && prot_i == 1 && prot_j == 6
                    if any(strcmp(regions{probe_i}{b_i-1}, layers))
                        text(1, sum(boundaries{probe_i}([b_i-1, b_i]))/2, regions{probe_i}{b_i-1}, ...
                            'horizontalalignment', 'left', 'verticalalignment', 'middle')
                    end
                end
            end
            
            % index of lower boundary for VISp6b
            l6b_i = find(strcmp('VISp6b', regions{probe_i}));
            
            % set the y-limits of axis to include bottom of VISp6b
            ylim([boundaries{probe_i}(l6b_i+1) boundaries{probe_i}(1)])
            
            set(gca, 'ytick', []);
            
            title(sprintf('%s vs. %s', label{prot_i}, label{prot_j}), 'interpreter', 'none');
            
            if prot_i == 1 && prot_j == 2
                xlabel('MI');
            end
        end
    end
    
    FigureTitle(gcf, probe_fname{probe_i})
    
    % make the page bigger to fit the graphs
    set(gcf, 'paperposition', [0, 0, 20, 20], 'paperpositionmode','manual', 'papersize', [20, 20]);
    
    % print the PDF
    if save_on
        save_fname = fullfile(save_dir, 'each_mouse', sprintf('%s.pdf', probe_fname{probe_i}));
        print(save_fname, '-bestfit', '-dpdf')
    end
end
