clear all


probe_fname = {'CAA-1110262_rec1_rec2_rec3', ...
    'CAA-1110263_restricted_rec1_rec2_rec3', ...
    'CAA-1110264_rec1_rec2', ...
    'CAA-1110265_restricted_rec1_rec2_rec3'};

session_n = 1;
protocols = {'ReplayOnly', 'StageOnly'};

rate_stationary = cell(length(probe_fname), 1);
rate_motion = cell(length(probe_fname), 1);


for probe_i = 1 : length(probe_fname)
    
    formatted_data_fname = fullfile('C:\Users\Lee\Documents\mvelez\data\formatted_data', [probe_fname{probe_i}, '.mat']);
    cluster_id_fname = fullfile('C:\Users\Lee\Documents\mvelez\data\selected_clusters', [probe_fname{probe_i}, '_cluster_ids.txt']);
    
    load(formatted_data_fname);
    
    % use the sync information to insert the time on the probe
    session_obj = Session(sessions(session_n), t_sync{session_n});
    
    rate_stationary{probe_i} = cell(length(protocols), 1);
    rate_motion{probe_i} = cell(length(protocols), 1);
    
    for prot_i = 1 : length(protocols)
        
        % get trials of the specified protocol
        trials = session_obj.trials_by_protocol(protocols{prot_i});
        
        % filter clusters
        f = default_cluster_filter();
        f.from_file = cluster_id_fname;
        clusters = filter_clusters(clusters, f);
        
        % default options
        options = default_options();
        
        % preallocate
        rate_stationary{probe_i}{prot_i} = nan(length(trials), length(clusters));
        rate_motion{probe_i}{prot_i} = nan(length(trials), length(clusters));
        
        for trial_i = 1 : length(trials)
            
            for cluster_i = 1 : length(clusters)
                
                cmd = sprintf('Trial %i/%i, cluster %i/%i\n', trial_i, length(trials), cluster_i, length(clusters));
                fprintf(cmd);
                
                [rate_stationary{probe_i}{prot_i}(trial_i, cluster_i), rate_motion{probe_i}{prot_i}(trial_i, cluster_i)] = ...
                    get_stationary_and_motion_rate(trials(trial_i), clusters(cluster_i), options.spiking);
                
                fprintf(repmat('\b', 1, length(cmd)));
            end
        end
    end
end



%% plot each recording
for probe_i = 1 : length(probe_fname)
    
    figure('position', [90, 220, 1200, 1100]);
    h_ax1 = subplot(1, 3, 1);
    u = UnityPlot(rate_stationary{probe_i}{1}, rate_motion{probe_i}{1}, h_ax1);
    
    h_ax2 = subplot(1, 3, 2);
    u2 = UnityPlot(rate_stationary{probe_i}{2}, rate_motion{probe_i}{2}, h_ax2);
    sync_axes([u, u2])
    
    h_ax3 = subplot(1, 3, 3);
    u3 = UnityPlot(rate_motion{probe_i}{1}-rate_stationary{probe_i}{1}, rate_motion{probe_i}{2}-rate_stationary{probe_i}{2}, h_ax3);
    
    u.xlabel('Stationary (Hz)')
    u.ylabel('Motion (Hz)')
    u.title('Vis. Flow Only Replay')
    u2.xlabel('Stationary (Hz)')
    u2.ylabel('Motion (Hz)')
    u2.title('Vest + Vis. Flow Replay')
    u3.xlabel('Vis. Flow Only (\Delta Hz)')
    u3.ylabel('Vest. + Vis. Flow (\Delta Hz)')
    u3.title('Vest + Vis. Flow vs. Vis. Flow Only')
    
    FigureTitle(gcf, probe_fname{probe_i});
    
    print(sprintf('%s_unity_replay.pdf', probe_fname{probe_i}), '-bestfit', '-dpdf');
end


%% pool data
for prot_i = 1 : length(protocols)
    max_n_trials = max(cellfun(@(x)(size(x{prot_i}, 1)), rate_stationary));
    total_n_clust = sum(cellfun(@(x)(size(x{prot_i}, 2)), rate_stationary));

    rate_stationary_pooled{prot_i} = nan(max_n_trials, total_n_clust);
    rate_motion_pooled{prot_i} = nan(max_n_trials, total_n_clust);
end

n_clust_so_far = 0;

for probe_i = 1 : length(probe_fname)
    n_clust = size(rate_stationary{probe_i}{prot_i}, 2);
    
    clust_idx = n_clust_so_far + (1:n_clust);
    n_clust_so_far = n_clust_so_far + n_clust;
    for prot_i = 1 : length(protocols)
        
        n_trials = size(rate_stationary{probe_i}{prot_i}, 1);
        
        rate_stationary_pooled{prot_i}(1:n_trials, clust_idx) = rate_stationary{probe_i}{prot_i};
        rate_motion_pooled{prot_i}(1:n_trials, clust_idx) = rate_motion{probe_i}{prot_i};
    end
end


figure('position', [90, 220, 1200, 1100]);
h_ax1 = subplot(1, 3, 1);
up = UnityPlot(rate_stationary_pooled{1}, rate_motion_pooled{1}, h_ax1);

h_ax2 = subplot(1, 3, 2);
up2 = UnityPlot(rate_stationary_pooled{2}, rate_motion_pooled{2}, h_ax2);
sync_axes([up, up2])


up.xlabel('Stationary (Hz)')
up.ylabel('Motion (Hz)')
up.title('Vis. Flow Only Replay')
up2.xlabel('Stationary (Hz)')
up2.ylabel('Motion (Hz)')
up2.title('Vest + Vis. Flow Replay')



h_ax3 = subplot(1, 3, 3);
up3 = UnityPlot(rate_motion_pooled{1}-rate_stationary_pooled{1}, rate_motion_pooled{2}-rate_stationary_pooled{2}, h_ax3);
up3.xlabel('Vis. Flow Only (\Delta Hz)')
up3.ylabel('Vest. + Vis. Flow (\Delta Hz)')
up3.title('Vest + Vis. Flow vs. Vis. Flow Only')

FigureTitle(gcf, 'Pooled');

print('pooled_unity_replay.pdf', '-bestfit', '-dpdf');
