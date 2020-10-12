% Modulation index vs. depth for each protocol
clear all


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OPTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% location in which to save PDF output
save_dir = 'C:\Users\Lee\Desktop\Desktop\mi_vs_depth';
save_on = true;

% whether to use delta firing rate for the all v. all plots
use_delta_fr = false;

% name of the probe recordings to analyze
probe_fname = {'CAA-1110262_rec1_rec2_rec3', ...
     'CAA-1110263_restricted_rec1_rec2_rec3', ...
     'CAA-1110264_rec1_rec2', ...
     'CAA-1110265_restricted_rec1_rec2_rec3', ...
     'CAA-1112221_rec1_rec2_rec3', ...
     'CAA-1112222_rec1_rec2_rec3', ...
     'CAA-1112223_rec1_rec2_rec3', ...
     'CAA-1112224_rec1_rec2_rec3'};

% which session of the probe recording to analyze
session_n           = 1;

% which protocols to analyze
protocols           = {'Coupled', 'EncoderOnly', 'StageOnly', 'StageOnly', 'ReplayOnly', 'ReplayOnly'};

% if the protocol includes a replay, what is it replaying?
replay_of           = {'', '', 'Coupled', 'EncoderOnly', 'Coupled', 'EncoderOnly'};

% label to give to each protocol on the plots
label               = {'LVF', 'LF', 'VF(LVF)', 'VF(LF)', 'F(LVF)', 'F(LF)'};

% default options
options             = default_options();




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CALCULATE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% preallocate arrays. for each cluster of each recording, for each trial of each protocol we
% are going to compute the stationary and motion firing rates
rate_stationary     = cell(length(probe_fname), 1);
rate_motion         = cell(length(probe_fname), 1);

% store the cluster ID and the region in which it occurred and depth within
% that region
ids                 = cell(length(probe_fname), 1);
region_str          = cell(length(probe_fname), 1);
depth_in_region     = cell(length(probe_fname), 1);
boundaries          = cell(length(probe_fname), 1);
regions             = cell(length(probe_fname), 1);

% total number of protocols
n_prot              = length(protocols);

% for each recording
for probe_i = 1 : length(probe_fname)
    
    % print progress
    fprintf('Recording %s\n', probe_fname{probe_i});
    
    % location of the formatted data
    formatted_data_fname = fullfile('C:\Users\Lee\Documents\mvelez\data\formatted_data', [probe_fname{probe_i}, '.mat']);
    
    % location of a list of "good" manually selected cluster IDs
    cluster_id_fname = fullfile('C:\Users\Lee\Documents\mvelez\data\selected_clusters', [probe_fname{probe_i}, '_cluster_ids.txt']);
    
    % load the formatted data
    load(formatted_data_fname);
    
    % use the sync information to insert the time on the probe
    session_obj = Session(sessions(session_n), t_sync{session_n});
    
    % preallocate cell arrays for stationary and motion firing rates
    rate_stationary{probe_i} = cell(n_prot, 1);
    rate_motion{probe_i} = cell(n_prot, 1);
        
    % filter clusters according to the cluster ID list file
    f = create_cluster_filter();
    f.from_file = cluster_id_fname;
    clusters = filter_clusters(clusters, f);
    
    % store cluster IDs and regions in which clusters occur
    ids{probe_i} = [clusters(:).id];
    region_str{probe_i} = {clusters(:).region_str};
    
    % compute the depth in each layer (0-1) where 0 is the top of the
    % layer, 1 is the bottom
    depth_in_region{probe_i} = get_region_relative_depth(anatomy, clusters);
    
    % store the boundaries of the layers
    boundaries{probe_i} = anatomy.region_boundaries;
    regions{probe_i} = anatomy.region_str;
    
    % for each protocols
    for prot_i = 1 : n_prot
        
        % print progress
        fprintf('Protocol %s\n', protocols{prot_i});
        
        % get trials associated with the specified protocol
        trials = session_obj.trials_by_protocol(protocols{prot_i});
        
        % if the trial is a replay, get which kind of replay it is
        if ~isempty(replay_of{prot_i})
            idx = strcmp({trials(:).replay_of}, replay_of{prot_i});
        else
            idx = true(length(trials), 1);
        end
        
        % restrict the trials if required
        trials = trials(idx);
        
        % preallocate
        rate_stationary{probe_i}{prot_i} = nan(length(trials), length(clusters));
        rate_motion{probe_i}{prot_i} = nan(length(trials), length(clusters));
        
        % for each trial
        for trial_i = 1 : length(trials)
            
            % for each cluster
            for cluster_i = 1 : length(clusters)
                
                % update progress
                cmd = sprintf('Trial %i/%i, cluster %i/%i\n', trial_i, length(trials), cluster_i, length(clusters));
                fprintf(cmd);
                
                % get the firing rates during stationary and motion
                [rate_stationary{probe_i}{prot_i}(trial_i, cluster_i), rate_motion{probe_i}{prot_i}(trial_i, cluster_i)] = ...
                    get_stationary_and_motion_rate(trials(trial_i), clusters(cluster_i), options.spiking);
                
                % remove the message
                fprintf(repmat('\b', 1, length(cmd)));
            end
        end
    end
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PROTOCOL VS. PROTOCOL MODULATION INDEX %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

modulation_index = cell(length(probe_fname), 1);

for probe_i = 1 : length(probe_fname)
    
    modulation_index{probe_i} = cell(n_prot);
    
    for prot_i = 1 : n_prot-1
        for prot_j = prot_i+1:n_prot
            
            fr_i = nanmean(rate_motion{probe_i}{prot_i} - rate_stationary{probe_i}{prot_i}, 1);
            fr_j = nanmean(rate_motion{probe_i}{prot_j} - rate_stationary{probe_i}{prot_j}, 1);
            
            modulation_index{probe_i}{prot_i, prot_j} = (fr_i - fr_j)./(abs(fr_i) + abs(fr_j));
        end
    end
end




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
%% PLOT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Four plots:
%   1. Modulation index 
%       (FR_motion - FR_stationary)/(FR_motion + FR_stationary)
%       for each cluster, plotted against depth.
%   2. Pooled across recordings







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1. MI for each protocol vs. depth %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% the following will be appended to the filename of the pdf output 
% for each recording
save_ext = 'mi_vs_depth_each_protocol';

% we append to these variables to plot the pooled data
clust_n     = 0;
mi          = [];
prot_idx    = [];
d           = [];
r_i         = [];
sz          = {};
col         = {};

% for each recording
for probe_i = 1 : length(probe_fname)
    
    % create figure for each recording
    figure('position', [90, 220, 1200, 1100]);
    
    % number of clusters in this recording
    n_clusters = size(rate_stationary{probe_i}{1}, 2);
    
    % for each protocol
    for prot_i = 1 : n_prot
        
        % create an axis
        h_ax = subplot(3, 2, prot_i); hold on;
        
        % for each cluster
        for clust_i = 1 : n_clusters
            
            % ignore it if it is not in cortex
            if ~ismember(region_str{probe_i}{clust_i}, {'VISp1', 'VISp2/3', 'VISp4', 'VISp5', 'VISp6a', 'VISp6b'})
                continue
            end
            
            % append to the clusters
            clust_n = clust_n + 1;
            
            % keep track of which protocol this is (for pooled)
            prot_idx(clust_n) = prot_i;
            
            % firing rates during motion and stationary for each trials
            fr_motion_trials = rate_motion{probe_i}{prot_i}(:, clust_i);
            fr_stationary_trials = rate_stationary{probe_i}{prot_i}(:, clust_i);
            
            % calculate firing rate during motion across trials
            fr_motion = nanmean(fr_motion_trials);
            fr_stationary = nanmean(fr_stationary_trials);
            
            % compute the modulation index
            mi(clust_n) = (fr_motion - fr_stationary) / (fr_motion + fr_stationary);
            
            % do a signrank on motion vs. stationary
            p = signrank(fr_motion_trials, fr_stationary_trials);
            
            d(clust_n) = depth_in_region{probe_i}(clust_i);
            
            % get index of region in which cluster is
            r_i(clust_n) = find(strcmp(region_str{probe_i}(clust_i), regions{probe_i}));
            
            % compute upper and lower boundaries of that region
            upper_b = boundaries{probe_i}(r_i(clust_n));
            width_b = boundaries{probe_i}(r_i(clust_n)) ...
                - boundaries{probe_i}(r_i(clust_n) + 1);
            
            % depth at which to plot this cluster
            plot_depth = upper_b - width_b*d(clust_n);
            
            % size and color of dot depends on statistics
            if p < 0.05 && nanmedian(fr_motion) < nanmedian(fr_stationary)
                sz{clust_n} = [];
                col{clust_n} = 'b';
            elseif p < 0.05 && nanmedian(fr_motion) > nanmedian(fr_stationary)
                sz{clust_n} = [];
                col{clust_n} = 'r';
            else
                sz{clust_n} = 20;
                col{clust_n} = [0.6, 0.6, 0.6];
            end
            
            % put the cluster on the axis
            scatter(mi(clust_n), plot_depth, sz{clust_n}, col{clust_n}, 'fill');
        end
        
        % plot the layer boundaries
        for b_i = 1 : length(boundaries{probe_i})
            line([-1, 1], boundaries{probe_i}(b_i)*[1, 1], 'color', 'k', 'linestyle', '--');
        end
        
        % index of lower boundary for VISp6b
        l6b_i = find(strcmp('VISp6b', regions{probe_i}));
        
        % set the y-limits of axis to include bottom of VISp6b
        ylim([boundaries{probe_i}(l6b_i+1) boundaries{probe_i}(1)])
        
        % title of protocol
        title(label{prot_i}, 'interpreter', 'none');
    end
    
    xlabel('Modulation index')
    ylabel('Distance from probe tip (\mum)')
    
    % add a title for the figure overall
    FigureTitle(gcf, probe_fname{probe_i});
    
    % make the page bigger to fit the graphs
    set(gcf, 'paperposition', [0, 0, 20, 20], 'paperpositionmode','manual', 'papersize', [20, 20]);
    
    % create the filename to save
    save_fname_full = fullfile(save_dir, sprintf('%s_%s.pdf', probe_fname{probe_i}, save_ext));
    
    % save the pdf
    if save_on
        print(save_fname_full, '-bestfit', '-dpdf')
    end
end





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2. MI for each protocol vs. depth POOLED %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% the pdf output will have this name
save_fname = 'pooled_mi_vs_depth_each_protocol.pdf';

% create just one figure
figure('position', [90, 220, 1200, 1100]);

% for each protocol
for prot_i = 1 : n_prot
    
    % create an axis
    h_ax = subplot(3, 2, prot_i); hold on;
    
    % in the pooled array we created which clusters go on this plot
    these_clust = find(prot_idx == prot_i);
    
    % for each cluster
    for clust_i = 1 : length(these_clust)
        
        % index of this cluster in the pooled array
        ii = these_clust(clust_i);
        
        % compute upper and lower boundaries of that region
        upper_b = avg_boundaries(r_i(ii));
        width_b = avg_boundaries(r_i(ii)) ...
            - avg_boundaries(r_i(ii) + 1);
        
        % depth at which to plot this cluster
        plot_depth = upper_b - width_b * d(ii);
        
        % put the cluster on the axis
        scatter(mi(ii), plot_depth, sz{ii}, col{ii}, 'fill');
    end
    
    % plot the layer boundaries
    for b_i = 1 : length(avg_boundaries)
        line([-1, 1], avg_boundaries(b_i)*[1, 1], 'color', 'k', 'linestyle', '--');
    end
    
    % index of boundary for VISp6b
    l6b_i = find(strcmp('VISp6b', regions{1}));
    
    % set the y-limits of axis to include bottom of VISp6b
    ylim([avg_boundaries(l6b_i+1), avg_boundaries(1)])
    
    % title of protocol
    title(label{prot_i}, 'interpreter', 'none');
end


xlabel('Modulation index')
ylabel('Distance from probe tip (\mum)')

% give it a title
FigureTitle(gcf, 'Pooled');

% make the page bigger to fit the graphs
set(gcf, 'paperposition', [0, 0, 20, 20], 'paperpositionmode','manual', 'papersize', [20, 20]);

% create the filename to save
save_fname_full = fullfile(save_dir, save_fname);

% save the pdf
if save_on
    print(save_fname_full, '-bestfit', '-dpdf')
end





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 3. MI for each protocol against all other protocols vs. depth %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% the following will be appended to the filename of the pdf output 
% for each recording
save_ext = 'mi_vs_depth_all_v_all';

% we append to these variables to plot the pooled data
clust_n     = 0;
mi          = [];
prot_idx_i  = [];
prot_idx_j  = [];
d           = [];
r_i         = [];
sz          = {};
col         = {};

% for each recording
for probe_i = 1 : length(probe_fname)
    
    % create figure for each recording
    figure('position', [90, 220, 1200, 1100]);
    
    % number of clusters in this recording
    n_clusters = size(rate_stationary{probe_i}{1}, 2);
    
    % for all protocols but the last
    for prot_i = 1 : n_prot-1
        % take all other protocols
        for prot_j = prot_i+1 : n_prot
            
            % get an index for the axis
            sp_i = (prot_i - 1)*n_prot + prot_j;
            
            % create an axis
            h_ax = subplot(n_prot, n_prot, sp_i); hold on;
            
            % for each cluster
            for clust_i = 1 : n_clusters
                
                % ignore it if it is not in cortex
                if ~ismember(region_str{probe_i}{clust_i}, {'VISp1', 'VISp2/3', 'VISp4', 'VISp5', 'VISp6a', 'VISp6b'})
                    continue
                end
                
                % append to the clusters
                clust_n = clust_n + 1;
                
                % keep track of which protocol this is (for pooled)
                prot_idx_i(clust_n) = prot_i;
                prot_idx_j(clust_n) = prot_j;    
                
                if use_delta_fr
                    % change in firing rate between stationary and motion for
                    % protocol j
                    delta_1 = rate_motion{probe_i}{prot_i}(:, clust_i) - ...
                        rate_stationary{probe_i}{prot_i}(:, clust_i);
                    % change in firing rate between stationary and motion for
                    % protocol i
                    delta_2 = rate_motion{probe_i}{prot_j}(:, clust_i) - ...
                        rate_stationary{probe_i}{prot_j}(:, clust_i);
                    
                else
                    % otherwise just take the firing rate during motion
                    delta_1 = rate_motion{probe_i}{prot_i}(:, clust_i);
                    delta_2 = rate_motion{probe_i}{prot_j}(:, clust_i);
                end
                
                % is the difference significant?
                % we assume here that the trials are paired in some way,
                % but they don't necessarily have to be
                p = signrank(delta_1, delta_2);
                
                d(clust_n) = depth_in_region{probe_i}(clust_i);
                
                % get the index of region in which cluster is
                r_i(clust_n) = find(strcmp(region_str{probe_i}(clust_i), regions{probe_i}));
                
                % compute upper and lower boundaries of that region
                upper_b = boundaries{probe_i}(r_i(clust_n));
                width_b = boundaries{probe_i}(r_i(clust_n)) ...
                    - boundaries{probe_i}(r_i(clust_n) + 1);
                
                % depth at which to plot this cluster
                plot_depth = upper_b - width_b*d(clust_n);
                
                if use_delta_fr
                    % get modulation index as calculated above
                    mi(clust_n) = modulation_index{probe_i}{prot_i, prot_j}(clust_i);
                else
                    mi(clust_n) = (nanmean(delta_1) - nanmean(delta_2)) / (nanmean(delta_1) + nanmean(delta_2));
                end
                
                
                if p < 0.05 && nanmedian(delta_1) < nanmedian(delta_2)
                    sz{clust_n} = [];
                    col{clust_n} = 'b';
                elseif p < 0.05 && nanmedian(delta_1) > nanmedian(delta_2)
                    sz{clust_n} = [];
                    col{clust_n} = 'r';
                else
                    sz{clust_n} = 20;
                    col{clust_n} = [0.6, 0.6, 0.6];
                end
                
                % put the cluster on the axis
                scatter(mi(clust_n), plot_depth, sz{clust_n}, col{clust_n}, 'fill');
            end
            
            
            % plot the layer boundaries
            for b_i = 1 : length(boundaries{probe_i})
                line([-1, 1], boundaries{probe_i}(b_i)*[1, 1], 'color', 'k', 'linestyle', '--');
            end
            
            % index of lower boundary for VISp6b
            l6b_i = find(strcmp('VISp6b', regions{probe_i}));
            
            % set the y-limits of axis to include bottom of VISp6b
            ylim([boundaries{probe_i}(l6b_i+1) boundaries{probe_i}(1)])
            
            % title of the two protocols
            title(sprintf('%s v. %s', label{prot_i}, label{prot_j}), ...
                'interpreter', 'none', 'fontweight', 'normal');
            
        end
    end
    
    % give it a title
    FigureTitle(gcf, probe_fname{probe_i});
    
    % make the page bigger to fit the graphs
    set(gcf, 'paperposition', [0, 0, 20, 20], 'paperpositionmode','manual', 'papersize', [20, 20]);
    
    % create the filename to save
    save_fname_full = fullfile(save_dir, sprintf('%s_%s.pdf', probe_fname{probe_i}, save_ext));
    
    % save the pdf
    if save_on
        print(save_fname_full, '-bestfit', '-dpdf')
    end
end






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% POOLED
%% 4. MI for each protocol against all other protocols vs. depth %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% the pdf output will have this name
save_fname = 'pooled_mi_vs_depth_all_v_all.pdf';

% create just one figure
figure('position', [90, 220, 1200, 1100]);

% for all protocols but the last
for prot_i = 1 : n_prot-1
    % take all other protocols
    for prot_j = prot_i+1 : n_prot
        
        % identify which axis to fill
        sp_i = (prot_i - 1)*n_prot + prot_j;
        
        % create an axis
        h_ax = subplot(n_prot, n_prot, sp_i); hold on;
        
        % in the pooled array we created which clusters go on this plot
        these_clust = find(prot_idx_i == prot_i & prot_idx_j == prot_j);
        
        % for each cluster
        for clust_i = 1 : length(these_clust)
            
            % index of this cluster in the pooled array
            ii = these_clust(clust_i);
            
            % compute upper and lower boundaries of that region
            upper_b = avg_boundaries(r_i(ii));
            width_b = avg_boundaries(r_i(ii)) ...
                - avg_boundaries(r_i(ii) + 1);
            
            % depth at which to plot this cluster
            plot_depth = upper_b - width_b * d(ii);
            
            % put the cluster on the axis
            scatter(mi(ii), plot_depth, sz{ii}, col{ii}, 'fill');
        end
        
        % plot the layer boundaries
        for b_i = 1 : length(avg_boundaries)
            line([-1, 1], avg_boundaries(b_i)*[1, 1], 'color', 'k', 'linestyle', '--');
        end
        
        % index of boundary for VISp6b
        l6b_i = find(strcmp('VISp6b', regions{1}));
        
        % set the y-limits of axis to include bottom of VISp6b
        ylim([avg_boundaries(l6b_i+1), avg_boundaries(1)])
        
        % title of the axis
        title(sprintf('%s v. %s', label{prot_i}, label{prot_j}), ...
            'interpreter', 'none', 'fontweight', 'normal');
    end
end

% give the page a title
FigureTitle(gcf, 'Pooled');

% make the page bigger to fit the graphs
set(gcf, 'paperposition', [0, 0, 20, 20], 'paperpositionmode','manual', 'papersize', [20, 20]);

% pdf filename to save to
save_fname_full = fullfile(save_dir, save_fname);

% print the pdf
if save_on
    print(save_fname_full, '-bestfit', '-dpdf')
end
