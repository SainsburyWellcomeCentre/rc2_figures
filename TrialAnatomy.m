classdef TrialAnatomy < handle
    
    properties
        
        
        
    end
    
    
    methods
        
        function obj = TrialAnatomy(trial)
            
            cols = lines(7);
            
            solenoid_col = cols(3, :);
            stat_col = cols(1, :);
            mot_col = cols(2, :);
            aw_col = cols(5, :);
            
            h = figure;
            set(h, 'position', [16, 80, 1440, 890], 'papersize', [15, 10], ...
                'renderer', 'painters');
            
            t = (0:length(trial.filtered_teensy)-1) * (1/trial.fs);
            idx = find(trial.analysis_window());
            trig_shift = 3;
            
            subplot(4, 1, 1);
            hold on;
            
            f = trial.filtered_teensy;
            plot(t, f, 'color', 'k');
            g = nan(size(f));
            g(idx) = f(idx);
            plot(t, g, 'color', aw_col);
            plot(t, 20*trial.motion_mask+trig_shift, 'color', mot_col);
            plot(t, 20*trial.stationary_mask+trig_shift, 'color', stat_col);
            plot(t, 5*trial.solenoid+trig_shift, 'color', solenoid_col);
            plot(t, 22.5*trial.analysis_window()+trig_shift, 'color', aw_col);
            
            if trial.is_replay
                title(sprintf('Trial %i, %s;   replay of Trial %i, %s', trial.id, trial.protocol, trial.replayed_trial_id, trial.replay_of));
            else
                title(sprintf('Trial %i, %s', trial.id, trial.protocol));
            end
            
            text(t(end), max(get(gca, 'ylim')), ...
                sprintf('Stationary time: %.2f s\nMotion time: %.2f s\nAnalysis window time: %.2f s', ...
                trial.stationary_time, trial.motion_time, trial.analysis_window_time), ...
                'horizontalalignment', 'right', 'verticalalignment', 'top');
            ylabel('M (cm/s)')
            set(gca, 'plotboxaspectratio', [10, 1, 1]);
            box off;
            
            
            subplot(4, 1, 2);
            hold on;
            
            if ~isempty(trial.multiplexer_output)
                f = trial.multiplexer_output;
                plot(t, f, 'color', 'k');
                g = nan(size(f));
                g(idx) = f(idx);
                plot(t, g, 'color', aw_col);
            else
                f = zeros(length(t), 1);
                plot(t, f, 'color', 'k');
                g = nan(size(f));
                g(idx) = f(idx);
                plot(t, g, 'color', aw_col);
            end
            
            plot(t, 20*trial.motion_mask+trig_shift, 'color', mot_col);
            plot(t, 20*trial.stationary_mask+trig_shift, 'color', stat_col);
            plot(t, 5*trial.solenoid+trig_shift, 'color', solenoid_col);
            plot(t, 22.5*trial.analysis_window()+trig_shift, 'color', aw_col);
            ylabel('V (cm/s)')
            set(gca, 'plotboxaspectratio', [10, 1, 1]);
            box off;
            legend({'Speed', 'Analysis window', 'In motion', 'Stationary', 'Solenoid'})
            
            subplot(4, 1, 3);
            hold on;
            f = trial.stage;
            plot(t, f, 'color', 'k');
            g = nan(size(f));
            g(idx) = f(idx);
            plot(t, g, 'color', aw_col);
            plot(t, 20*trial.motion_mask+trig_shift, 'color', mot_col);
            plot(t, 20*trial.stationary_mask+trig_shift, 'color', stat_col);
            plot(t, 5*trial.solenoid+trig_shift, 'color', solenoid_col);
            plot(t, 22.5*trial.analysis_window()+trig_shift, 'color', aw_col);
            ylabel('T (cm/s)')
            set(gca, 'plotboxaspectratio', [10, 1, 1]);
            box off;
            
            
            subplot(4, 1, 4);
            hold on;
            y = 20*(trial.camera1 - min(trial.camera1))/(max(trial.camera1) - min(trial.camera1));
            plot(t, y, 'color', 'k');
            g = nan(size(y));
            g(idx) = y(idx);
            plot(t, g, 'color', aw_col);
            plot(t, 20*trial.motion_mask+trig_shift, 'color', mot_col);
            plot(t, 20*trial.stationary_mask+trig_shift, 'color', stat_col);
            plot(t, 5*trial.solenoid+trig_shift, 'color', solenoid_col);
            plot(t, 22.5*trial.analysis_window()+trig_shift, 'color', aw_col);
            ylabel('Camera (a.u.)')
            xlabel('Time (s)');
            set(gca, 'plotboxaspectratio', [10, 1, 1]);
            box off;
            
        end
    end
end