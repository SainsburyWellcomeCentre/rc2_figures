clear all
close all


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OPTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

experiment = {'visual_flow'};  % 'darkness', 'visual_flow', 'head_tilt', 'mismatch_nov20'
combination = {'protocols'};

formatted_data_dir  = 'C:\Users\Lee\Documents\mvelez\data\formatted_data';

% where to save figure
save_dir = 'C:\Users\Lee\Desktop\Desktop\mvelez\mismatch_nov20_response\running_bouts';
save_on = true;

% where relative to mismatch to show
window_t            = [-2, 2];

% need to change this
options = default_options();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CALCULATE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

warning('off', 'MATLAB:table:RowsAddedExistingVars');
T = table();
r = 0;

if save_on && ~isfolder(save_dir)
    mkdir(save_dir);
end

for exp_i = 1 : length(experiment)
    
    % get details of the experiment
    [probe_fnames, protocols, ~, replay_of, ~, ~, ~, title_str, vis_stim, gain_directions] = experiment_details(experiment{exp_i}, combination{exp_i});
    
    % number of protocols
    n_protocols = length(protocols);
    
    for probe_i = 1 : length(probe_fnames)
        
        if save_on
            % save the pdf and store the name
            pdf_count = 0;
            save_fnames = {};
        end
        
        % location of the formatted data and cluster ID list
        formatted_data_fname = fullfile(formatted_data_dir, [probe_fnames{probe_i}, '.mat']);
        
        % load the formatted data
        data = load_data(formatted_data_fname);
        
        % get mismatch trials
        if strcmp(probe_fnames{probe_i}, 'CAA-1112872_rec1_rec1b_rec2_rec3')
            trials = [data.sessions(1).trials, data.sessions(2).trials];
        else
            trials = [data.sessions(1).trials];
        end
        n_trials = length(trials);
        
        % count the bounts
        bout_count = 0;
        
        % get the start and end of the gain change for each trial
        protocol    = {};
        gain_dir    = {};
        
        % store the velocity around mismatch for each trial and the time
        % base for it
        base_t      = {};
        running     = {};
%         gain_teensy = {};
        stage       = {};
        
        % for each trial, get protocol type, gain direction, mismatch
        % start time, whether it is a botched trial, and the spike
        % convolution for each cluster
        for trial_i = 1 : n_trials
            
            % get bouts in this trial
            bouts = get_motion_bouts_by_trial(trials(trial_i), options.stationary);
            
            if isempty(bouts)
                continue
            end
            
            % 
            bouts = bouts([bouts(:).duration] > 2);
            
            % get mismatch time
%             mm_start_sample = find(diff(trials(trial_i).teensy_gain > 2.5) == 1) + 1;
%             mm_start_t = trials(trial_i).probe_t(mm_start_sample);
            
            % get traces for each bout
            for bout_i = 1 : length(bouts)
                
                s = bouts(bout_i).start_time + window_t(1);
                e = bouts(bout_i).end_time + window_t(2);
                
%                 if mm_start_t > s & mm_start_t < e
%                     continue
%                 end
                
                bout_count = bout_count + 1;
                
                % save protocol and gain direction
                protocol{bout_count} = trials(trial_i).protocol;
%                 gain_dir{bout_count} = trials(trial_i).config.gain_direction;
                
                idx = trials(trial_i).probe_t > s & ...
                    trials(trial_i).probe_t <= e;
                
                % time base for the running profile
                base_t{bout_count} = trials(trial_i).probe_t(idx) - bouts(bout_i).start_time;
                
                % 
                running{bout_count} = trials(trial_i).velocity(idx);
%                 gain_teensy{bout_count} = trials(trial_i).gain_teensy(idx);
                stage{bout_count} = trials(trial_i).stage(idx);
                
            end
        end
        
        % only take first two protocols
        
        for prot_i = 1 : 1%n_protocols
            
            % index of trials with this protocol and gain direction
            this_protocol_idx = find(strcmp(protocols{prot_i}, protocol));
            
            % store the max velocity across trials
            yL = -inf;
            
            % store all axes across trials
            h_ax = cell(length(this_protocol_idx), 1);
            axis_fig = nan(length(this_protocol_idx), 1);
            
            % the figures we are saving
            these_figs = [];
            
            % for trials in this protocol
            for idx_i = 1 : length(this_protocol_idx)
                
                % which figure and subplot to plot on
                fig_n = (prot_i-1)*20 + ceil(idx_i/10);
                sp_n = mod(idx_i-1, 10) + 1;
                
                % create figure
                figure(fig_n);
                set(fig_n, 'position', [141    78   754   896]);
                
                % create axis for this trial
                h_ax{idx_i} = subplot(5, 2, sp_n);
                axis_fig(idx_i) = fig_n;
                hold on;
                
                % do the plot
%                 plot(base_t{this_protocol_idx(idx_i)}, ...
%                      gain_teensy{this_protocol_idx(idx_i)}, ...
%                      'color', 'r', 'linewidth', 1.5);
                plot(base_t{this_protocol_idx(idx_i)}, ...
                     running{this_protocol_idx(idx_i)}, ...
                     'color', 'k', 'linewidth', 2);
                plot(base_t{this_protocol_idx(idx_i)}, ...
                     stage{this_protocol_idx(idx_i)}, ...
                     'color', [255,211,0]/255, 'linewidth', 2);
                
                % set axis
                set(gca, 'plotboxaspectratio', [3, 1, 1], ...
                        'box', 'off', ...
                        'clipping', 'off');
                
                % title
                title(sprintf('Bout ID %i', this_protocol_idx(idx_i)));
                
                if sp_n == 1
                    xlabel('(s)')
                    ylabel('(cm/s)')
                end
                
                
                if sp_n == 10 || idx_i == length(this_protocol_idx)
                    
                    FigureTitle(gcf, sprintf('%s, %s', probe_fnames{probe_i}, title_str{prot_i}));
                    these_figs(end+1) = fig_n;
                end
            end
            
            
            for idx_i = 1 : length(h_ax)
                yL = 50;
                set(h_ax{idx_i}, 'ylim', [0, yL]);
                line(h_ax{idx_i}, [0, 0], [0, yL], 'color', 'k', 'linewidth', 0.5, 'linestyle', '--');
                
            end
            
            if save_on
                for i = 1 : length(these_figs)
                    figure(these_figs(i));
                    % save the pdf and store the name
                    pdf_count = pdf_count + 1;
                    save_fnames{pdf_count} = fullfile(save_dir, sprintf('f_%03i.pdf', pdf_count));
                    print(save_fnames{pdf_count}, '-bestfit', '-dpdf')
                end
            end
            
        end
        
        if save_on
            % join the PDFs
            output_fname = fullfile(save_dir, sprintf('%s_running_traces.pdf', probe_fnames{probe_i}));
            join_pdfs(save_fnames, output_fname, true);
        end
        
        close all;
        
    end
end
