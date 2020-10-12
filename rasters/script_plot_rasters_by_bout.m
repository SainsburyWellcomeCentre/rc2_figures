% plot rasters for an animal
clear all
close all


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OPTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% location in which to save PDF output
save_dir = 'C:\Users\Lee\Desktop\Desktop\rasters_around_motion_onset';

% name of the probe recording to analyze
probe_fname = 'CA_176_1_rec1_rec2_rec3';

% which session of the probe recording to analyze
session_n = 1;

% which protocols to analyze
protocols = {'Coupled', 'EncoderOnly', 'StageOnly'};

% if the protocol includes a replay, what is it replaying?
replay_of = {'', '', 'Coupled', 'EncoderOnly'};

% number of seconds before and after the bout to take
prepad              = 3;
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

% load the formatted data
data = load_data(formatted_data_fname);

% filter clusters according to the cluster ID list file
clusters = data.clusters;
idx = ismember([data.clusters(:).id], data.selected_clusters);
clusters(~idx) = [];

% get start time of motion bouts
bouts = get_motion_bouts_by_session(data.sessions(1), options.stationary);

% remove bouts below a certain duration
bouts = bouts([bouts(:).duration] > min_bout_duration);

% start times of the bouts
start_t = [bouts(:).start_time];
end_t = [bouts(:).start_time] + [bouts(:).duration];

% convert bouts to matrix of velocity traces
velocity_traces = bouts_to_traces(bouts, prepad, postpad);

% shift traces to common timebase
common_t = (-data.sessions(1).fs*prepad + (0:size(velocity_traces, 1)-1))'/data.sessions(1).fs;

% use bout timings to get raster data
[spike_rates, spike_times] = ...
    get_raster_data(clusters, start_t, common_t, data.sessions(1).fs, options.spiking);

% gather the trials in which the bouts occurred
t = [bouts(:).trial];



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

title_str = {'Loco + Vest', ...
             'Loco', ...
             'Vest'};
         
% start and end bounds for the display
win_start = -3;
win_end = 5;
         
% store the save names to join the PDFs later
save_fnames = cell(length(clusters), 1);

%for each cluster
for clust_i = 1 : length(clusters)
    
    % create a raster display object
    r = RasterDisplayFigure(6);
    
    % restrict timebase to display window
    win = common_t > win_start & common_t < win_end;
    
    % get the largest spike rate across the protocols
    M = -inf;
    
    % for each protocol
    for prot_i = 1 : length(protocols)
        
        % find the bouts belonging to the protocol
        idx = strcmp({t(:).protocol}, protocols{prot_i});
        
        % if protocol is a replay, get the protocols which replay the
        % desired protocol
        if ~isempty(replay_of{prot_i}) 
            idx2 = strcmp({t(:).replay_of}, replay_of{prot_i});
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
        
        % add grey bars to the end of the rasters
        r.h_raster{x_i, y_i}.add_bars(end_t(idx) - start_t(idx), common_t(length(common_t)))
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
    print(save_fnames{clust_i}, '-bestfit', '-dpdf')    
end

% join the PDFs
output_fname = fullfile(save_dir, sprintf('%s_rasters.pdf', probe_fname));
join_pdfs(save_fnames, output_fname, true);
