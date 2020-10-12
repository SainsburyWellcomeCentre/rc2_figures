% compare responses between all conditions
input('sure?')
clear all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OPTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% wehter to restrict the calculation of firing rate for motion to "high"
% velocities (>75th percentile across all motion in Locovest and Loco).
restrict_to_high_velocity = false;

% whether to use delta firing rate for the all v. all plots
use_delta_fr = false;

% location in which to save PDF output
save_dir = 'C:\Users\Lee\Desktop\Desktop\unity_plots';
save_on = true;

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
rate_baseline       = cell(length(probe_fname), 1);

% store the cluster ID and the region in which it occurred 
ids                 = cell(length(probe_fname), 1);
region_str          = cell(length(probe_fname), 1);

% total number of protocols
n_prot              = length(protocols);

%% for each recording
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
    
    % if we are restricting to high velocities, we first need to get a
    % threshold velocity for each recording
    if restrict_to_high_velocity
        
        % protocols to use for the assessment of high velocity threshold
        prots_to_use = {'Coupled', 'EncoderOnly'};
        
        % we will append velocities from all trials for these protocols
        motion_velocities = [];
        
        % gather all velocities during locovest and loco
        for prot_i = 1 : length(prots_to_use)
            
            % trials for this protocol
            prot_trials = session_obj.trials_by_protocol(prots_to_use{prot_i});
            
            % for each trial
            for trial_i = 1 : length(prot_trials)
                
                % gather and append samples with velocities in motion
                this_trial = prot_trials(trial_i);
                motion_velocities = [motion_velocities; motion_velocities_from_trial(this_trial)];
            end
        end
        
        % compute the velocity above which there is 25%
        top_25_threshold = prctile(motion_velocities, 75);
    end
    
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
    
    % for each protocols
    for prot_i = 1 : n_prot
        
        % print progress
        fprintf('Protocol %s\n', protocols{prot_i});
        
        % get trials of the specified protocol
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
                if restrict_to_high_velocity
                    [rate_stationary{probe_i}{prot_i}(trial_i, cluster_i), rate_motion{probe_i}{prot_i}(trial_i, cluster_i)] = ...
                        get_stationary_and_motion_rate(trials(trial_i), clusters(cluster_i), options.spiking, top_25_threshold);
                else
                    [rate_stationary{probe_i}{prot_i}(trial_i, cluster_i), rate_motion{probe_i}{prot_i}(trial_i, cluster_i)] = ...
                        get_stationary_and_motion_rate(trials(trial_i), clusters(cluster_i), options.spiking);
                end
                
                rate_baseline{probe_i}{prot_i}(trial_i, cluster_i) = get_baseline_rate(trials(trial_i), clusters(cluster_i), options.spiking);
                
                % remove progress info
                fprintf(repmat('\b', 1, length(cmd)));
            end
        end
    end
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PLOT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1. plot stationary v motion for each cluster, for each protocol %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% the following will be appended to the filename of the pdf output 
% for each recording
save_ext = 'unity_stat_v_mot';

% for each recording
for probe_i = 1 : length(probe_fname)
    
    % number of clusters in this recording
    n_clusters = size(rate_stationary{probe_i}{1}, 2);
    
    % preallocate array to store filenames to eventually join
    save_fnames = cell(n_clusters, 1);
    
    % for each cluster
    for clust_i = 1 : n_clusters
        
        % create figure for each cluster
        figure('position', [90, 220, 1200, 1100]);
        
        % array to store the ClusterUnityPlot handles
        h_unity = cell(n_prot);
        
        % for each protocol
        for prot_i = 1 : n_prot
            
            % create axis
            h_ax = subplot(3, 2, prot_i);
            
            % create a unity plot from the data
            h_unity{prot_i} = ClusterUnityPlot(rate_stationary{probe_i}{prot_i}(:, clust_i), rate_motion{probe_i}{prot_i}(:, clust_i), h_ax);
            
            % axis labels and title
            h_unity{prot_i}.xlabel('Stationary (Hz)')
            h_unity{prot_i}.ylabel('Motion (Hz)')
            h_unity{prot_i}.title(label{prot_i})
        end
        
        % make sure all axes have the same dimensions
        sync_axes([h_unity{:}])
        
        % overall figure title
        FigureTitle(gcf, sprintf('%s, Cluster %i, %s', probe_fname{probe_i}, ids{probe_i}(clust_i), region_str{probe_i}{clust_i}));
        
        % generate name for PDF
        save_fnames{clust_i} = fullfile(save_dir, sprintf('%s_cluster_%03i.pdf', probe_fname{probe_i}, ids{probe_i}(clust_i)));
        
        % print the PDF
        if save_on
            print(save_fnames{clust_i}, '-bestfit', '-dpdf')
        end
    end
    
    % Join the PDFs with the following name
    output_fname = fullfile(save_dir, sprintf('%s_%s.pdf', probe_fname{probe_i}, save_ext));
    
    if save_on
        join_pdfs(save_fnames, output_fname, true);
    end
    
    close all
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1. plot stationary v motion for each cluster, for each protocol %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% the following will be appended to the filename of the pdf output 
% for each recording
save_ext = 'unity_stat_v_mot_pooled';

% for each recording
for probe_i = 1 : length(probe_fname)
    
    % number of clusters in this recording
    n_clusters = size(rate_stationary{probe_i}{1}, 2);
    
    % which of the clusters resides in a cortical layer
    cortical_idx = ismember(region_str{probe_i}, {'VISp1', 'VISp2/3', 'VISp4', 'VISp5', 'VISp6a', 'VISp6b'});
    
    % create a figure for each recording
    figure('position', [90, 220, 1200, 1100]);
    
    % array to store the UnityPlot handles
    h_unity = cell(n_prot);
    
    
    for prot_i = 1 : n_prot
        
        new_rate_mot = rate_motion{probe_i}{prot_i}(:, cortical_idx);
        new_rate_stat = rate_stationary{probe_i}{prot_i}(:, cortical_idx);
        
        
        h_ax = subplot(3, 2, prot_i);
        
        h_unity{prot_i} = UnityPlot(new_rate_stat, new_rate_mot, h_ax, 'signrank');
        
        h_unity{prot_i}.xlabel('Stationary (Hz)')
        h_unity{prot_i}.ylabel('Motion (Hz)')
        
    end
    
    % make sure all axes have the same dimensions
    sync_axes([h_unity{:}])
        
    % overall figure title
    FigureTitle(gcf, sprintf('%s', probe_fname{probe_i}));
        
    % generate name for PDF
    save_fname = fullfile(save_dir, sprintf('%s_%s.pdf', probe_fname{probe_i}, save_ext));
    
    % print the PDF
    if save_on
        print(save_fname, '-bestfit', '-dpdf')
    end
end





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2. plot for each cluster, every protocol against every other protocol (BY TRIAL) %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% the following will be appended to the filename of the pdf output 
% for each recording
if use_delta_fr
    save_ext = 'unity_all_v_all_each_cluster';
else
    save_ext = 'unity_all_v_all_each_cluster_no_delta';
end

% for each recording
for probe_i = 1 : length(probe_fname)
    
    % number of clusters in this recording
    n_clusters = size(rate_stationary{probe_i}{1}, 2);
    
    % preallocate array to store filenames to eventually join 
    save_fnames = cell(n_clusters, 1);
    
    % for each cluster
    for clust_i = 1 : n_clusters
        
        % create figure for each cluster
        figure('position', [90, 220, 1200, 1100]);
        
        % array to store the ClusterUnityPlot handles
        h_unity = cell(n_prot);
        
        % for each protocol except the last
        for prot_i = 1 : n_prot-1
            % for all other protocols
            for prot_j = prot_i+1 : n_prot
                
                % get the position of the axis to plot
                sp_i = (prot_i - 1)*n_prot + prot_j;
                
                % generate the axis
                h_ax = subplot(n_prot, n_prot, sp_i);
                
                if use_delta_fr
                    % compute a delta firing rate for each trial of each
                    % protocol
                    delta_1 = rate_motion{probe_i}{prot_j}(:, clust_i)-rate_stationary{probe_i}{prot_j}(:, clust_i);
                    delta_2 = rate_motion{probe_i}{prot_i}(:, clust_i)-rate_stationary{probe_i}{prot_i}(:, clust_i);
                else
                    delta_1 = rate_motion{probe_i}{prot_j}(:, clust_i);
                    delta_2 = rate_motion{probe_i}{prot_i}(:, clust_i);
                end
                
                % unity plot for this recording, for these two protocols
                h_unity{prot_i, prot_j} = ClusterUnityPlot(delta_1, delta_2, h_ax, 'signrank');
                
                % axis labels and title
                if use_delta_fr
                    h_unity{prot_i, prot_j}.xlabel(sprintf('%s (\\Delta Hz)', label{prot_j}))
                    h_unity{prot_i, prot_j}.ylabel(sprintf('%s (\\Delta Hz)', label{prot_i}))
                else
                    h_unity{prot_i, prot_j}.xlabel(sprintf('%s (\\Hz)', label{prot_j}))
                    h_unity{prot_i, prot_j}.ylabel(sprintf('%s (\\Hz)', label{prot_i}))
                end
            end
        end
        
        % make sure all axes have the same dimensions
        sync_axes([h_unity{:}])
        
        % overall figure title
        FigureTitle(gcf, sprintf('%s, Cluster %i, %s', probe_fname{probe_i}, ids{probe_i}(clust_i), region_str{probe_i}{clust_i}));
        
        % make the page bigger to fit the graphs
        set(gcf, 'paperposition', [0, 0, 20, 20], 'paperpositionmode','manual', 'papersize', [20, 20]);
        
        % generate name for PDF
        save_fnames{clust_i} = fullfile(save_dir, sprintf('%s_cluster_%03i.pdf', probe_fname{probe_i}, ids{probe_i}(clust_i)));
        
        % print the PDF
        print(save_fnames{clust_i}, '-bestfit', '-dpdf')
    end
    
    % Join the PDFs with the following name
    output_fname = fullfile(save_dir, sprintf('%s_%s.pdf', probe_fname{probe_i}, save_ext));
    join_pdfs(save_fnames, output_fname, true);
    
    close all
end







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 3. plot for each recording, every protocol against every other protocol %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% the following will be appended to the filename of the pdf output 
% for each recording
if use_delta_fr
    save_ext = 'unity_all_v_all';
else
    save_ext = 'unity_all_v_all_no_delta';
end

% preallocate storage which we will use for pooled data
p_count = 0;
delta_1 = {};
delta_2 = {};
pooling_info = [];

% for each recording
for probe_i = 1 : length(probe_fname)
    
    % create a figure for each recording
    figure('position', [90, 220, 1200, 1100]);
    
    % array to store the UnityPlot handles
    h_unity = cell(n_prot);
    h_dhist= cell(n_prot);
    
    % which of the clusters resides in a cortical layer
    cortical_idx = ismember(region_str{probe_i}, {'VISp1', 'VISp2/3', 'VISp4', 'VISp5', 'VISp6a', 'VISp6b'});
    
    % for each protocol but the last
    for prot_i = 1 : n_prot-1
        % for each other protocol
        for prot_j = prot_i+1 : n_prot
            
            % get the position of the axis to plot
            sp_i = (prot_i - 1)*n_prot + prot_j;
            
            % generate the axis
            h_ax = subplot(n_prot, n_prot, sp_i);
            
            % iterate through
            p_count = p_count + 1;
            
            % store info to recover deltas in pooling plots
            pooling_info(p_count, :) = [probe_i, prot_i, prot_j];
            
            % if we are using delta (motion - stationary)
            if use_delta_fr
                % compute a delta firing rate for each trial of each
                % protocol
                delta_1{p_count} = rate_motion{probe_i}{prot_j}(:, cortical_idx) - ...
                    rate_stationary{probe_i}{prot_j}(:, cortical_idx);
                delta_2{p_count} = rate_motion{probe_i}{prot_i}(:, cortical_idx) - ...
                    rate_stationary{probe_i}{prot_i}(:, cortical_idx);
            else
                % take delta as just the firing rate during motion
                delta_1{p_count} = rate_motion{probe_i}{prot_j}(:, cortical_idx);
                delta_2{p_count} = rate_motion{probe_i}{prot_i}(:, cortical_idx);
            end
            
            % unity plot for this recording, for these two protocols for
            % these clusters
            h_unity{prot_i, prot_j} = UnityPlot(delta_1{p_count}, delta_2{p_count}, h_ax, 'signrank');
            
            if use_delta_fr
                h_unity{prot_i, prot_j}.xlabel(sprintf('%s (\\Delta Hz)', label{prot_j}))
                h_unity{prot_i, prot_j}.ylabel(sprintf('%s (\\Delta Hz)', label{prot_i}))
            else
                h_unity{prot_i, prot_j}.xlabel(sprintf('%s (motion, Hz)', label{prot_j}))
                h_unity{prot_i, prot_j}.ylabel(sprintf('%s (motion, Hz)', label{prot_i}))
            end
            h_unity{prot_i, prot_j}.xlim([-5, 20])
            h_unity{prot_i, prot_j}.ylim([-5, 20])
        end
    end
    
    % make sure all axes have the same dimensions
    sync_axes([h_unity{:}])
    
%     % for each protocol but the last
%     for prot_i = 1 : n_prot-1
%         % for each other protocol
%         for prot_j = prot_i+1 : n_prot
%             h_dhist{prot_i, prot_j} = DiagonalHistogram(h_unity{prot_i, prot_j});
%         end
%     end
    
    % overall figure title
    FigureTitle(gcf, probe_fname{probe_i});
    
    % make the page bigger to fit the graphs
    set(gcf, 'paperposition', [0, 0, 20, 20], 'paperpositionmode','manual', 'papersize', [20, 20]);
    
    % generate name for PDF
    save_fname = fullfile(save_dir, sprintf('%s_%s.pdf', probe_fname{probe_i}, save_ext));
    
    % print the PDF
    if save_on
        print(save_fname, '-bestfit', '-dpdf')
    end
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 4. POOLED: every protocol against every other protocol %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% for prot_i = 1 : n_prot
%     
%     max_n_trials = -inf;
%     total_n_clust = 0;
%     for probe_i = 1 : length(probe_fname)
%         max_n_trials = max(max_n_trials, size(rate_stationary{probe_i}{prot_i}, 1));
%         
%         % select for cortical cells
%         cortical_idx = ismember(region_str{probe_i}, {'VISp1', 'VISp2/3', 'VISp4', 'VISp5', 'VISp6a', 'VISp6b'});
%         total_n_clust = total_n_clust + sum(cortical_idx);
%     end
%     
%     rate_stationary_pooled{prot_i} = nan(max_n_trials, total_n_clust);
%     rate_motion_pooled{prot_i} = nan(max_n_trials, total_n_clust);
% end


% 
% % POOL ALL CLUSTERS
% % we will insert clusters iteratively into a large matrix
% n_clust_so_far = 0;
% 
% % for each recording
% for probe_i = 1 : length(probe_fname)
%     
%     % select for cortical cells
%     cortical_idx = ismember(region_str{probe_i}, {'VISp1', 'VISp2/3', 'VISp4', 'VISp5', 'VISp6a', 'VISp6b'});
%     
%     % number of clusters in this recording (just choose first protocol)
%     n_clust = sum(cortical_idx);
%     
%     % which index of the large matrix to insert the firing rates
%     clust_idx = n_clust_so_far + (1:n_clust);
%     
%     % keep track of the number of clusters we have inserted
%     n_clust_so_far = n_clust_so_far + n_clust;
%     
%     % for each protocol
%     for prot_i = 1 : n_prot
%         
%         % number of trials for this protocol
%         n_trials = size(rate_stationary{probe_i}{prot_i}, 1);
%         
%         % insert the firing rates for each trial
%         rate_stationary_pooled{prot_i}(1:n_trials, clust_idx) = rate_stationary{probe_i}{prot_i}(:, cortical_idx);
%         rate_motion_pooled{prot_i}(1:n_trials, clust_idx) = rate_motion{probe_i}{prot_i}(:, cortical_idx);
%     end
% end

% maximum number of trials in any prot v prot comparison
max_n_trials = max(cellfun(@(x)(size(x, 1)), delta_1));

% create one figure
figure('position', [90, 220, 1200, 1100]);

% array to store handles to UnityPlot objects
h_unity = cell(n_prot);

% for each protocol except the last
for prot_i = 1 : n_prot-1
    % for each other protocol
    for prot_j = prot_i+1 : n_prot
        
        % find which compairsons to include for this prot v prot plot
        idx = find(pooling_info(:, 2) == prot_i & pooling_info(:, 3) == prot_j);
        
        % we need to build the array
        this_delta_1 = [];
        this_delta_2 = [];
        
        % for each comparison (one per recording)
        for ii = 1 : length(idx)
            
            d1 = delta_1{idx(ii)};
            
            n_clusters = size(d1, 2);
            n_missing_trials = max_n_trials - size(d1, 1);
            
            pad_delta_1 = [d1; nan(n_missing_trials, n_clusters)];
            pad_delta_2 = [delta_2{idx(ii)}; nan(n_missing_trials, n_clusters)];
            
            this_delta_1 = [this_delta_1, pad_delta_1];
            this_delta_2 = [this_delta_2, pad_delta_2];
        end
        
        sp_i = (prot_i - 1)*n_prot + prot_j;
        
        h_ax = subplot(n_prot, n_prot, sp_i);
        
%         h_unity{prot_i, prot_j} = UnityPlot(rate_motion_pooled{prot_j}-rate_stationary_pooled{prot_j}, rate_motion_pooled{prot_i}-rate_stationary_pooled{prot_i}, h_ax, 'signrank');
        h_unity{prot_i, prot_j} = UnityPlot(this_delta_1, this_delta_2, h_ax, 'signrank');
        
        % axes labels and limits
        if use_delta_fr
            h_unity{prot_i, prot_j}.xlabel(sprintf('%s (\\Delta Hz)', label{prot_j}))
            h_unity{prot_i, prot_j}.ylabel(sprintf('%s (\\Delta Hz)', label{prot_i}))
        else
            h_unity{prot_i, prot_j}.xlabel(sprintf('%s (motion, Hz)', label{prot_j}))
            h_unity{prot_i, prot_j}.ylabel(sprintf('%s (motion, Hz)', label{prot_i}))
        end
        h_unity{prot_i, prot_j}.xlim([-5, 20])
        h_unity{prot_i, prot_j}.ylim([-5, 20])
    end
end

FigureTitle(gcf, 'Pooled');

% make the page bigger to fit the graphs
set(gcf, 'paperposition', [0, 0, 20, 20], 'paperpositionmode','manual', 'papersize', [20, 20]);

save_fname = fullfile(save_dir, 'pooled_unity_all_v_all_scaled.pdf');

if save_on
    print(save_fname, '-bestfit', '-dpdf')
end
