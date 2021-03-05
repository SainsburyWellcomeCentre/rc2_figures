clear all
close all


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OPTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

experiment = {'mismatch_nov20'};  % 'darkness', 'visual_flow', 'head_tilt', 'mismatch_nov20'
combination = {'protocols'};

formatted_data_dir  = 'C:\Users\Lee\Documents\mvelez\data\formatted_data';

% where to save figure
save_dir = 'C:\Users\Lee\Desktop\Desktop\mvelez\mismatch_nov20_response\running_around_mismatch';
save_on = true;

% where relative to mismatch to show
window_t            = [-2, 2];


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
        
        % get the start and end of the gain change for each trial
        protocol    = cell(n_trials, 1);
        gain_dir    = cell(n_trials, 1);
        
        % store whether to reject the trial (by default accept)
        accept_trial = true(n_trials, 1);
        
        % store the mismatch onset time for each trial (in probe time)
        mm_start_t  = nan(n_trials, 1);
        mm_end_t    = nan(n_trials, 1);
        
        % store the velocity around mismatch for each trial and the time
        % base for it
        base_t      = cell(n_trials, 1);
        running     = cell(n_trials, 1);
        gain_teensy = cell(n_trials, 1);
        
        % for each trial, get protocol type, gain direction, mismatch
        % start time, whether it is a botched trial, and the spike
        % convolution for each cluster
        for trial_i = 1 : n_trials
            
            % save protocol and gain direction
            protocol{trial_i} = trials(trial_i).protocol;
            gain_dir{trial_i} = trials(trial_i).config.gain_direction;
            
            % start of and end of mismatch window
            mm_start_sample = find(diff(trials(trial_i).teensy_gain > 2.5) == 1) + 1;
            mm_end_sample = find(diff(trials(trial_i).teensy_gain > 2.5) == -1) + 1;
            mm_start_t(trial_i) = trials(trial_i).probe_t(mm_start_sample);
            mm_end_t(trial_i) = trials(trial_i).probe_t(mm_end_sample);
            
            % reject trials in which the mismatch window is < 50ms
            if mm_end_t(trial_i) - mm_start_t(trial_i) < 0.05
                accept_trial(trial_i) = false;
            end
            
            % start and end of baseline period
            window = mm_start_t(trial_i) + window_t;
            
            % sample points around mismatch
            idx = trials(trial_i).probe_t > window(1) & ...
                trials(trial_i).probe_t <= window(2);
            
            % time base for the running profile
            base_t{trial_i} = trials(trial_i).probe_t(idx) - mm_start_t(trial_i);
            
            % velocity around mismatch
            running{trial_i} = trials(trial_i).velocity(idx);
            gain_teensy{trial_i} = trials(trial_i).gain_teensy(idx);
        end
        
        % loop over protocols and get the peak response time for each
        % cluster
        for prot_i = 1 : n_protocols
            
            % index of trials with this protocol and gain direction
            this_protocol_idx = find(strcmp(protocols{prot_i}, protocol) & ...
                strcmp(gain_directions{prot_i}, gain_dir) & ...
                accept_trial);
            
            % store the max velocity across trials
            yL = -inf;
            % store all axes across trials
            h_ax = cell(length(this_protocol_idx), 1);
            axis_fig = nan(length(this_protocol_idx), 1);
            
            % the figures we are saving
            these_figs = [];
            
            % for trials in this protocol
            for idx_i = 1 : length(this_protocol_idx)
                
                tpi = this_protocol_idx(idx_i);
                
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
                plot(base_t{tpi}, ...
                     gain_teensy{tpi}, ...
                     'color', 'r', 'linewidth', 1.5);
                
                plot(base_t{tpi}, ...
                     running{tpi}, ...
                     'color', 'k', 'linewidth', 2);
                
                gain_scale = ones(size(base_t{tpi}));
                idx1 = base_t{tpi} > 0 & base_t{tpi} < 0.05;
                end_t = mm_end_t(tpi) - mm_start_t(tpi);
                idx2 = base_t{tpi} >= 0.05 & base_t{tpi} < end_t;
                idx3 = base_t{tpi} >= end_t & base_t{tpi} < end_t+0.05;
                
                if ismember(prot_i, [2, 4])
                    gain_scale(idx1) = linspace(1, 2, sum(idx1));
                    gain_scale(idx2) = 2;
                    gain_scale(idx3) = linspace(2, 1, sum(idx3));
                else
                    gain_scale(idx1) = linspace(1, 0, sum(idx1));
                    gain_scale(idx2) = 0;
                    gain_scale(idx3) = linspace(0, 1, sum(idx3));
                end
                
                plot(base_t{tpi}, ...
                     10*gain_scale, ...
                     'color', 'm', 'linewidth', 2);
                
                
                % set axis
                set(gca, 'plotboxaspectratio', [3, 1, 1], ...
                        'box', 'off', ...
                        'clipping', 'off');
                
                % title
                title(sprintf('Trial ID %i (/%i)', tpi, n_trials));
                
                if sp_n == 1
                    xlabel('(s)')
                    ylabel('(cm/s)')
                end
                
                % get the largest y-limit
%                 yL = max(yL, max(get(h_ax{idx_i}, 'ylim')));
                
                if sp_n == 10 || idx_i == length(this_protocol_idx)
                    
                    FigureTitle(gcf, sprintf('%s, %s', probe_fnames{probe_i}, title_str{prot_i}));
                    these_figs(end+1) = fig_n;
                end
            end
            
            
            for idx_i = 1 : length(h_ax)
                yL = 50;
                set(h_ax{idx_i}, 'ylim', [0, yL]);
                line(h_ax{idx_i}, [0, 0], [0, yL], 'color', 'k', 'linewidth', 0.5, 'linestyle', '--');
                
                end_t = mm_end_t(this_protocol_idx(idx_i)) - mm_start_t(this_protocol_idx(idx_i));
                line(h_ax{idx_i}, [end_t, end_t], [0, yL], 'color', 'k', 'linewidth', 0.5, 'linestyle', '--');
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
