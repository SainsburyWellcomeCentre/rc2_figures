% plot rasters for an animal
probe_fname = 'CAA-1110262_rec1_rec2_rec3';

session_n = 1;
protocols = {'Coupled', 'EncoderOnly', 'StageOnly', 'StageOnly', 'ReplayOnly', 'ReplayOnly'};
replay_of = {'', '', 'Coupled', 'EncoderOnly', 'Coupled', 'EncoderOnly'};

% number of seconds before and after the bout to take
prepad = 3;
postpad = 0;
min_bout_duration = 2;

formatted_data_fname = fullfile('C:\Users\Lee\Documents\mvelez\data\formatted_data', [probe_fname, '.mat']);
load(formatted_data_fname);

% default options
options = default_options();

%% filter the clusters
f = default_cluster_filter();
% f.from_file = 'CAA-1110264_cluster_ids.txt';
clusters = filter_clusters(clusters, f);

% use the syn information to insert the time on the probe
session_obj = Session(sessions(session_n), t_sync{session_n});

% get start time of motion bouts
bouts = get_motion_bouts_by_session(session_obj, options.stationary);

% remove bouts below a certain duration
bouts = bouts([bouts(:).duration] > min_bout_duration);

% start times of the bouts
start_t = [bouts(:).start_time];
end_t = [bouts(:).start_time] + [bouts(:).duration];

% convert bouts to matrix of velocity traces
velocity_traces = bouts_to_traces(bouts, prepad, postpad);

% shift traces to common timebase
common_t = (-session_obj.fs*prepad + (0:size(velocity_traces, 1)-1))'/session_obj.fs;

% use bout timings to get raster data
[spike_rates, spike_times] = ...
    get_raster_data(clusters, start_t, common_t, session_obj.fs, options.spiking);

% gather the trials in which the bouts occurred
t = [bouts(:).trial];



%% plot
title_str = {'Loco + Vest + Vis. Flow', ...
             'Loco + Vis. Flow', ...
             'Vest + Vis. Flow (replay LocoVest)', ...
             'Vest + Vis. Flow (replay LocoOnly)', ...
             'Vis. Flow Only (replay LocoVest)', ...
             'Vis. Flow Only (replay LocoOnly)'};

for clust_i = 1 : length(clusters)
    
    r = RasterDisplayFigure(6);
    win = common_t > -3 & common_t < 5;
    M = -inf;
    
    for prot_i = 1 : length(protocols)
        
        idx = strcmp({t(:).protocol}, protocols{prot_i});
        
        if ~isempty(replay_of{prot_i}) 
            idx2 = strcmp({t(:).replay_of}, replay_of{prot_i});
            idx = idx & idx2;
        end
        
        x_i = mod(prot_i-1, 2) + 1;
        y_i = ceil(prot_i/2);
        
        v =  velocity_traces(:, idx);
        sr = spike_rates(:, idx, clust_i);
        assert(isequal(size(v), size(sr)));
        sr(isnan(v)) = nan;
        
        M = max([M, max(nanmean(sr(win, :), 2))]);
        
        r.fill_data(x_i, y_i, spike_times{clust_i}(idx), v, sr, common_t, title_str{prot_i})
        r.h_raster{x_i, y_i}.add_bars(end_t(idx) - start_t(idx), common_t(length(common_t)))
    end
    
    r.x_lim([-3, 5]);
    r.y_lim([0, 1.1*M], 3);
    r.sync_sections();
%     
    
    ft = FigureTitle(r.h_fig, sprintf('%s, Cluster %i', probe_fname, clusters(clust_i).id));
    ft.y_position = 1.18;
    
    print(sprintf('%s_cluster_%03i.pdf', probe_fname, clusters(clust_i).id), '-bestfit', '-dpdf')
    
end



%     h_fig = figure;
%     
%     h_ax1 = subplot(3, 1, 1);
%     h_raster = Raster(spike_times{clust_i}, h_ax1);
%     h_raster.add_bars(end_t - start_t, common_t(length(common_t)));
%     
%     h_ax2 = subplot(3, 1, 2);
%     h_motion = TracePlot(velocity_traces, common_t, h_ax2);
%     
%     h_ax3 = subplot(3, 1, 3);
%     h_rates = TracePlot(spike_rates(:, :, clust_i), common_t, h_ax3);
%     
%     % sync the plots
%     h_raster.ylabel('Bout #');
%     h_raster.xlabel('');
%     h_motion.add_traces();
%     h_motion.add_sd();
%     h_motion.ylim([0, nan]);
%     h_motion.ylabel('cm/s');
%     h_motion.xlabel('');
%     h_rates.mean_colour('k');
%     h_rates.ylabel('Hz');
%     
%     x = [h_raster.xlim; h_motion.xlim; h_rates.xlim];
%     new_xl = [min(x(:)), max(x(:))];
%     h_raster.xlim(new_xl);
%     h_motion.xlim(new_xl);
%     h_rates.xlim(new_xl);
%     
%     FigureTitle(h_fig, sprintf('Cluster %i', clusters(clust_i).id))