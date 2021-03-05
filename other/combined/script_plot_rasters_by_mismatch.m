% plot rasters for an animal
clear all
close all

import helper.*

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OPTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

experiment = {'mismatch_nov20'};  % 'darkness', 'visual_flow', 'head_tilt', 'mismatch_nov20'
combination = {'protocols'};

% location in which to save PDF output
save_dir = 'C:\Users\Lee\Desktop\Desktop\rasters_around_mismatch_nov20';

% name of the probe recording to analyze
% probe_fname = 'CA_176_1_rec1_rec2_rec3';

% which session of the probe recording to analyze
% session_n = 1;

% which protocols to analyze
% protocols = {'Coupled', 'EncoderOnly', 'StageOnly'};

% if the protocol includes a replay, what is it replaying?
% replay_of = {'', '', ''};

% number of seconds before and after the bout to take
prepad              = 1;
postpad             = 1;

% minimum duration of a bout
% min_bout_duration   = 2;

% default options
options = default_options();




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CALCULATE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% create directory to save to
if ~isfolder(save_dir)
    mkdir(save_dir);
end

for exp_i = 1 : length(experiment)
    
    [probe_fnames, protocols, ~, replay_of, ~, ~, ~, title_str, vis_stim, gain_dir] = experiment_details(experiment{exp_i}, combination{exp_i});
    
    for probe_i = 2%1 : length(probe_fnames)
        
        % location of the formatted data and cluster ID list
        formatted_data_fname = fullfile('C:\Users\Lee\Documents\mvelez\data\formatted_data', [probe_fnames{probe_i}, '.mat']);
        
        % load the formatted data
        data = load_data(formatted_data_fname);
        
        % filter clusters according to the cluster ID list file
        clusters = get_selected_clusters(data);
        
        % get mismatch location
        if strcmp(probe_fnames{probe_i}, 'CAA-1112872_rec1_rec1b_rec2_rec3')
            t = [data.sessions(1).trials, data.sessions(2).trials];
        else
            t = [data.sessions(1).trials];
        end
        
        time_base = (-prepad*data.sessions(1).fs:postpad*data.sessions(1).fs);
        start_t = nan(length(t), 1);
        end_t = nan(length(t), 1);
        velocity_traces = nan(length(time_base), length(t));
        gain_teensy = nan(length(time_base), length(t));
        
        for trial_i = 1 : length(t)
            
            idx = find(diff(t(trial_i).teensy_gain > 2.5) == 1) + 1;
            assert(length(idx) == 1);
            start_t(trial_i) = t(trial_i).probe_t(idx);
            end_t(trial_i) = start_t(trial_i) + 5;
            
            velocity_traces(:, trial_i) = t(trial_i).velocity(idx + time_base);
            gain_teensy(:, trial_i) = t(trial_i).gain_teensy(idx + time_base);
        end
        
        % get start time of motion bouts
%         bouts = get_motion_bouts_by_session(data.sessions(1), options.stationary);
%         
%         % remove bouts below a certain duration
%         bouts = bouts([bouts(:).duration] > min_bout_duration);
%         
%         % start times of the bouts
%         start_t = [bouts(:).start_time];
%         end_t = [bouts(:).start_time] + [bouts(:).duration];
%         
%         % convert bouts to matrix of velocity traces
%         velocity_traces = bouts_to_traces(bouts, prepad, postpad);
        
        % shift traces to common timebase
        common_t = (-data.sessions(1).fs*prepad + (0:size(velocity_traces, 1)-1))'/data.sessions(1).fs;
        
        % use bout timings to get raster data
        [spike_rates, spike_times] = ...
            get_raster_data(clusters, start_t, common_t, data.sessions(1).fs, options.spiking);
        
        % gather the trials in which the bouts occurred
%         t = [bouts(:).trial];
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% PLOT RASTERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % start and end bounds for the display
        win_start = -1;
        win_end = 1;
        
        % store the save names to join the PDFs later
        save_fnames = cell(length(clusters), 1);
        
        %for each cluster
        for clust_i = 1 : length(clusters)
            
            if clusters(clust_i).id ~= 187
                continue
            end
            
            % create a raster display object
            r = RasterDisplayFigure(length(protocols));
            r.raster_marker_type = 'line';
            
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
                
                % if 
                if ~isnan(vis_stim(prot_i))
                    c = [t(:).config];
                    idx2 = strcmp({c(:).enable_vis_stim}, num2str(vis_stim(prot_i)));
                    idx = idx & idx2;
                end
                
                if ~isempty(gain_dir{prot_i})
                    c = [t(:).config];
                    idx2 = strcmp({c(:).gain_direction}, gain_dir{prot_i});
                    idx = idx & idx2;
                end
                
                % get the required velocity traces and spike rates
                v =  velocity_traces(:, idx);
                gt = gain_teensy(:, idx);
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
                
                plot(r.h_motion{x_i, y_i}.h_ax, common_t, mean(gt, 2), 'b', 'linewidth', 2);
                
                % set the limits and synchronize the axes of all the sections
%                 line(r.h_ax, [0.2, 0.2], get(r.h_ax{x_i, y_i}.ylim
            end
            
            
            r.x_lim([win_start, win_end]);
            r.y_lim([0, 1.1*M], 3);
            r.sync_sections();
            
            % manually do this... argh
            for prot_i = 1 : length(protocols)
                
                % which subsection to fill
                x_i = mod(prot_i-1, 2) + 1;
                y_i = ceil(prot_i/2);
                
                yl = get(r.h_raster{x_i, y_i}.h_ax, 'ylim');
                set(r.h_raster{x_i, y_i}.h_line, 'ydata', yl);
                line(r.h_raster{x_i, y_i}.h_ax, [0.2, 0.2], yl, 'linestyle', '--', 'color', 'k');
                
                set(r.h_motion{x_i, y_i}.h_ax, 'ylim', [0, 70]);
                yl = get(r.h_motion{x_i, y_i}.h_ax, 'ylim');
                set(r.h_motion{x_i, y_i}.h_line, 'ydata', yl);
                line(r.h_motion{x_i, y_i}.h_ax, [0.2, 0.2], yl, 'linestyle', '--', 'color', 'k');
                
                yl = get(r.h_rates{x_i, y_i}.h_ax, 'ylim');
                set(r.h_rates{x_i, y_i}.h_line, 'ydata', yl);
                line(r.h_rates{x_i, y_i}.h_ax, [0.2, 0.2], yl, 'linestyle', '--', 'color', 'k');
            end
            
            % give the page a title
            ft = FigureTitle(r.h_fig, sprintf('%s, Cluster %i, %s', probe_fnames{probe_i}, clusters(clust_i).id, clusters(clust_i).region_str));
            ft.y_position = 1.1;
            
            % create the save name
            save_fnames{clust_i} = fullfile(save_dir, sprintf('%s_cluster_%03i.pdf', probe_fnames{probe_i}, clusters(clust_i).id));
            
            set(r.h_fig, 'renderer', 'painters');
            
            % print the PDF
            print(save_fnames{clust_i}, '-bestfit', '-dpdf')
        end
        
        % join the PDFs
        output_fname = fullfile(save_dir, sprintf('%s_rasters.pdf', probe_fnames{probe_i}));
        join_pdfs(save_fnames, output_fname, true);
    end
    close all
end