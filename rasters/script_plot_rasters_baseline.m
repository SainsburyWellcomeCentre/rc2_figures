% plot rasters for an animal
clear all
close all


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OPTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% location in which to save PDF output
save_dir = 'C:\Users\Lee\Desktop\Desktop\rasters_baseline';
save_on = true;

% name of the probe recording to analyze
probe_fname = 'CAA-1110264_rec1_rec2';

% which session of the probe recording to analyze
session_n = 1;

% which protocols to analyze
protocols = {'Coupled', 'EncoderOnly', 'StageOnly', 'StageOnly', 'ReplayOnly', 'ReplayOnly'};

% if the protocol includes a replay, what is it replaying?
replay_of = {'', '', 'Coupled', 'EncoderOnly', 'Coupled', 'EncoderOnly'};

% number of seconds before and after the bout to take
prepad              = 10;
postpad             = 0;

% minimum duration of a bout
min_bout_duration   = 2;

% default options
options = default_options();




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CALCULATE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% location of the formatted data and cluster ID list
formatted_data_fname = fullfile('C:\Users\Lee\Documents\mvelez\data\formatted_data', [probe_fname, '.mat']);
cluster_id_fname = fullfile('C:\Users\Lee\Documents\mvelez\data\selected_clusters', [probe_fname, '_cluster_ids.txt']);

% load the formatted data
load(formatted_data_fname);

% filter clusters according to the cluster ID list file
f = create_cluster_filter();
f.from_file = cluster_id_fname;
clusters = filter_clusters(clusters, f);

% use the sync information to insert the time on the probe
session_obj = Session(sessions(session_n), t_sync{session_n});

% get baseline periods
start_t = [];
end_t = [];
for trial_i = 1 : length(session_obj.trials)
    
    baseline_start_samp = find(session_obj.trials(trial_i).baseline_window, 1);
    
    start_t(trial_i) = session_obj.trials(trial_i).probe_t(baseline_start_samp);
    end_t(trial_i) = start_t(trial_i) + 3;
    
    idx = baseline_start_samp - prepad*session_obj.fs : baseline_start_samp + 10*session_obj.fs;
    
    sess_idx = session_obj.trials(trial_i).start_idx + idx;
                
    
    velocity_traces(:, trial_i)     = session_obj.filtered_teensy(sess_idx);
    solenoid(:, trial_i)            = session_obj.solenoid(sess_idx);
    stage(:, trial_i)               = session_obj.stage(sess_idx);
    vis_flow(:, trial_i)            = session_obj.multiplexer_output(sess_idx);
    pump(:, trial_i)                = session_obj.pump(sess_idx);
end


% shift traces to common timebase
common_t = (-session_obj.fs*prepad + (0:size(velocity_traces, 1)-1))'/session_obj.fs;

% use bout timings to get raster data
[spike_rates, spike_times] = ...
    get_raster_data(clusters, start_t, common_t, session_obj.fs, options.spiking);




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PLOT RASTERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% title for each axis
title_str = {'Loco + Vest + Vis. Flow', ...
             'Loco + Vis. Flow', ...
             'Vest + Vis. Flow (replay LocoVest)', ...
             'Vest + Vis. Flow (replay LocoOnly)', ...
             'Vis. Flow Only (replay LocoVest)', ...
             'Vis. Flow Only (replay LocoOnly)'};

% start and end bounds for the display
win_start = -10;
win_end = 10;
         
% store the save names to join the PDFs later
save_fnames = cell(length(clusters), 1);

%for each cluster
for clust_i = length(clusters)-1:length(clusters)
    
    % create a raster display object
    r = RasterDisplayFigure(6);
    
    % restrict timebase to display window
    win = common_t > win_start & common_t < win_end;
    
    % get the largest spike rate across the protocols
    M = -inf;
    
    % for each protocol
    for prot_i = 1 : length(protocols)
        
        % find the bouts belonging to the protocol
        idx = strcmp({session_obj.trials(:).protocol}, protocols{prot_i});
        
        % if protocol is a replay, get the protocols which replay the
        % desired protocol
        if ~isempty(replay_of{prot_i}) 
            idx2 = strcmp({session_obj.trials(:).replay_of}, replay_of{prot_i});
            idx = idx & idx2;
        end
        
        % get the required velocity traces and spike rates
        v =  velocity_traces(:, idx);
        sr = spike_rates(:, idx, clust_i);
        
        % take the nana in velocity traces and put them in the spike rate
        % traces
        sr(isnan(v)) = nan;
        
        % make sure they are the same size
        assert(isequal(size(v), size(sr)));
        
        % update the maximum spike rate seen
        M = max([M, max(nanmean(sr(win, :), 2))]);
        
        % which subsection to fill
        x_i = mod(prot_i-1, 2) + 1;
        y_i = ceil(prot_i/2);
        
        % fill the section with the required data
        r.fill_data(x_i, y_i, spike_times{clust_i}(idx), v, sr, common_t, title_str{prot_i})
        
        plot(r.h_motion{x_i, y_i}.h_ax, common_t, 3*solenoid(:, idx), 'g');
        
        % separate plots for pre and post baseline 0
        t_idx = common_t < 0;
        plot(r.h_motion{x_i, y_i}.h_ax, common_t(t_idx), stage(t_idx, idx), 'k');
        plot(r.h_motion{x_i, y_i}.h_ax, common_t(~t_idx), mean(stage(~t_idx, idx), 2), 'k');
        
        plot(r.h_motion{x_i, y_i}.h_ax, common_t, mean(vis_flow(:, idx), 2), 'm');
        plot(r.h_motion{x_i, y_i}.h_ax, common_t, 4*pump(:, idx), 'b');
        
        
        r.h_raster{x_i, y_i}.ylabel('Trial #');
        r.h_motion{x_i, y_i}.ylim([-25, nan])
        % add grey bars to the end of the rasters
%         r.h_raster{x_i, y_i}.add_bars(end_t(idx) - start_t(idx), common_t(length(common_t)))
    end
    
    % set the limits and synchronize the axes of all the sections
    r.x_lim([win_start, win_end]);
    r.y_lim([0, 1.1*M], 3);
    r.sync_sections();
    
    % give the page a title
    ft = FigureTitle(r.h_fig, sprintf('%s, Cluster %i, %s', probe_fname, clusters(clust_i).id, clusters(clust_i).region_str));
    ft.y_position = 1.18;
    
    % create the save name
    save_fnames{clust_i} = fullfile(save_dir, sprintf('%s_cluster_%03i.pdf', probe_fname, clusters(clust_i).id));
    
    % print the PDF
    if save_on
        print(save_fnames{clust_i}, '-bestfit', '-dpdf')
    end
end

% join the PDFs
output_fname = fullfile(save_dir, sprintf('%s_rasters_baseline.pdf', probe_fname));
if save_on
    join_pdfs(save_fnames, output_fname, true);
end
