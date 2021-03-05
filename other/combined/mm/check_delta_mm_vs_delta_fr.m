% plot rasters for an animal
clear all
close all

import helper.*

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OPTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

experiment = {'mismatch_nov20'};  % 'darkness', 'visual_flow', 'head_tilt', 'mismatch_nov20'
combination = {'protocols'};

formatted_data_dir = 'C:\Users\Lee\Documents\mvelez\data\formatted_data';
save_dir = 'C:\Users\Lee\Desktop\Desktop\mvelez\mismatch_nov20\check_trials';
save_on = true;

n_subplot = [5, 2];
n_trace_per_fig = prod(n_subplot);

for exp_i = 1 : length(experiment)
    
    [probe_fnames, protocols, ~, replay_of, ~, ~, ~, title_str, vis_stim, gain_dir] = experiment_details(experiment{exp_i}, combination{exp_i});
    
    for probe_i = 1 : length(probe_fnames)
        
        % location of the formatted data and cluster ID list
        formatted_data_fname = fullfile(formatted_data_dir, [probe_fnames{probe_i}, '.mat']);
        
        % load the formatted data
        data = load_data(formatted_data_fname);
        
        % get mismatch trials
        if strcmp(probe_fnames{probe_i}, 'CAA-1112872_rec1_rec1b_rec2_rec3')
            mismatch_trials = [data.sessions(1).trials, data.sessions(2).trials];
        else
            mismatch_trials = [data.sessions(1).trials];
        end
        
        save_fnames = {};
        
        for trial_i = 1 : length(mismatch_trials)
        
            fig_n = ceil(trial_i / n_trace_per_fig);
            figure(fig_n);
            set(gcf, 'position', [64    43   726   937]);
            
            sp = mod(trial_i - 1, n_trace_per_fig) + 1;
            
            subplot(n_subplot(1), n_subplot(2), sp);
            
            t = mismatch_trials(trial_i).probe_t;
            v = mismatch_trials(trial_i).velocity;
            p = mismatch_trials(trial_i).pump;
            idx_start = find(diff(mismatch_trials(trial_i).teensy_gain > 2.5) == 1) + 1;
            
            hold on;
            plot(t, v);
            plot(t, p);
            line(t(idx_start*[1,1]), get(gca, 'ylim'), 'color', 'k');
            box off
            set(gca, 'plotboxaspectratio', [3, 1, 1]);
            
            if sp == n_trace_per_fig || trial_i == length(mismatch_trials)
                
                xlabel('(s)');
                ylabel('(cm/s)');
                FigureTitle(gcf, probe_fnames{probe_i});
                if save_on
                    save_fnames{fig_n} = fullfile(save_dir, sprintf('%s_%03i.pdf', probe_fnames{probe_i}, fig_n));
                    print(save_fnames{fig_n}, '-bestfit', '-dpdf');
                end
            end
        end
        
        if save_on
            output_fname = fullfile(save_dir, sprintf('%s.pdf', probe_fnames{probe_i}));
            join_pdfs(save_fnames, output_fname, true, true);
        end
        
        close all
    end
end

