classdef MismatchExperiment < MVTExperiment
    
    
    properties (Constant = true)
        
        protocol_ids = 1 : 4
        protocol_type = {'CoupledMismatch', 'CoupledMismatch', 'EncoderOnlyMismatch', 'EncoderOnlyMismatch'};
        protocol_gain = {'down', 'up', 'down', 'up'};
        protocol_label = {'MVT (gain down)', 'MVT (gain up)', 'MV (gain down)', 'MV (gain up)'};
    end
    
    
    
    methods
        
        function obj = MismatchExperiment(data_obj, config)
            
            obj = obj@MVTExperiment(data_obj, config);
            
            if strcmp(data_obj.data.probe_recording, 'CAA-1112872_rec1_rec1b_rec2_rec3')
                obj.trials =  [data_obj.data.sessions(1).trials, data_obj.data.sessions(2).trials];
                for i = 1 : length(obj.trials)
                    obj.trials(i).id = i;
                end
            else
                obj.trials =  data_obj.data.sessions(1).trials;
            end
            
            % remove trials in which mismatch didn't occur
            mm_onset_t = arrayfun(@(x)(x.mismatch_onset_t()), obj.trials);
            mm_offset_t = arrayfun(@(x)(x.mismatch_offset_t()), obj.trials);
            idx = mm_offset_t - mm_onset_t < 0.05;
            obj.trials(idx) = [];
            
        end
        
        
        
        function trials = trials_of_type(obj, trial_type)
            
            trials = trials_of_type@MVTExperiment(obj, trial_type);
            
            if ~isempty(trials)
                return
            end
            
            if trial_type == 1
                
                trials = obj.coupledmismatch_trials();
                c = [trials(:).config];
                idx = strcmp({c(:).gain_direction}, 'down');
                trials = trials(idx);
                
            elseif trial_type == 2
                
                trials = obj.coupledmismatch_trials();
                c = [trials(:).config];
                idx = strcmp({c(:).gain_direction}, 'up');
                trials = trials(idx);
                
            elseif trial_type == 3
                
                trials = obj.encoderonlymismatch_trials();
                c = [trials(:).config];
                idx = strcmp({c(:).gain_direction}, 'down');
                trials = trials(idx);                
                
            elseif trial_type == 4
                
                trials = obj.encoderonlymismatch_trials();
                c = [trials(:).config];
                idx = strcmp({c(:).gain_direction}, 'up');
                trials = trials(idx);
                
            end
        end
        
        
        function [baseline, response, response_ctl] = windowed_mm_responses(obj, cluster, prot_i)
            
            n_windows = 4;
            window_t = 0.1;
            
            cluster_fr = FiringRate(cluster.spike_times);
            trials = obj.trials_of_type(prot_i);
            
            baseline = nan(length(trials), n_windows);
            response = nan(length(trials), n_windows);
            response_ctl = nan(length(trials), n_windows);
            
            for ti = 1 : length(trials)
                
                mm_onset = trials(ti).mismatch_onset_t();
                mm_offset = trials(ti).mismatch_offset_t();
                
                if mm_offset - mm_onset < 0.05
                    continue
                end
                
                rc_lims = mm_onset - 2*n_windows*window_t + [(0:n_windows-1)', (1:n_windows)']*window_t;
                b_lims = mm_onset - n_windows*window_t + [(0:n_windows-1)', (1:n_windows)']*window_t;
                r_lims = mm_onset + [(0:n_windows-1)', (1:n_windows)']*window_t;
                
                for wi = 1 : n_windows
                    
                    response_ctl(ti, wi) = cluster_fr.get_fr_in_window(rc_lims(wi, :));
                    baseline(ti, wi) = cluster_fr.get_fr_in_window(b_lims(wi, :));
                    response(ti, wi) = cluster_fr.get_fr_in_window(r_lims(wi, :));
                end
            end
        end
        
        
        
        function [running, t] = running_around_mismatch(obj, prot_i, limits)
            
            trials = obj.trials_of_type(prot_i);
            
            n_trials = length(trials);
            n_samples = range(limits) * trials(1).fs;
            
            running = nan(n_samples, n_trials);
            
            for trial_i = 1 : n_trials
                
                mm_onset = trials(trial_i).mismatch_onset_t();
                start_idx = find(trials(trial_i).probe_t > mm_onset + limits(1), 1, 'first');
                full_idx = start_idx + (0:n_samples-1);
                running(:, trial_i) = trials(trial_i).velocity(full_idx);
            end
            
            t = limits(1) + (0:n_samples-1)*(1/trials(1).fs); 
        end
        
        
        
        function [spike_rate, t] = firing_around_mismatch(obj, cluster, prot_i, limits)
            
            cluster_fr = FiringRate(cluster.spike_times);
            trials = obj.trials_of_type(prot_i);
            
            n_trials = length(trials);
            n_samples = range(limits) * trials(1).fs;
            
            spike_rate = nan(n_samples, n_trials);
            
            common_t = limits(1) + (0:n_samples-1)*(1/trials(1).fs);
            
            for trial_i = 1 : n_trials
                
                mm_onset = trials(trial_i).mismatch_onset_t();
                t = common_t + mm_onset;
                
                spike_rate(:, trial_i) = cluster_fr.get_convolution(t);
            end
        end
    end
end
