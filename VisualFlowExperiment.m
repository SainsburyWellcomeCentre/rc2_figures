classdef VisualFlowExperiment < MVTExperiment
    
    properties (Constant = true)
        
        protocol_ids = 1 : 6
        protocol_type = {'Coupled', 'EncoderOnly', 'StageOnly', 'StageOnly', 'ReplayOnly', 'ReplayOnly'};
        protocol_replayed_type = {'', '', 'Coupled', 'EncoderOnly', 'Coupled', 'EncoderOnly'};
        protocol_label = {'MVT', 'MV', 'VT (MVT)', 'VT (MV)', 'V (MVT)', 'V (MV)'};
        
    end
    
    
    methods
        
        function obj = VisualFlowExperiment(data_obj, config)
            
            obj = obj@MVTExperiment(data_obj, config);
            
            obj.trials = data_obj.data.sessions(1).trials;
        end
        
        
        function trials = trials_of_type(obj, trial_type)
            
            if strcmp(trial_type, 'Coupled')
                trials = obj.coupled_trials();
            elseif strcmp(trial_type, 'EncoderOnly')
                trials = obj.encoderonly_trials();
            elseif strcmp(trial_type, 'ReplayOnly')
                trials = obj.replayonly_trials();
            elseif strcmp(trial_type, 'StageOnly')
                trials = obj.stageonly_trials();
            end
        end
        
        
        
        function out_trial = to_aligned(obj, in_trial)
            
            replayed = obj.get_replayed_trial(in_trial);
            
            if ~isempty(replayed)
                offset = obj.get_offset(replayed, in_trial);
                out_trial = AlignedTrial(in_trial, replayed, offset);
            else
                out_trial = AlignedTrial(in_trial, in_trial, 1);
            end
        end
        
        
        
        
        function trials = trials_of_type_replay_of_type(obj, trial_type, replayed_type)
            
            if strcmp(trial_type, 'Coupled')
                trials = obj.coupled_trials();
                return
            elseif strcmp(trial_type, 'EncoderOnly')
                trials = obj.encoderonly_trials();
                return
            elseif strcmp(trial_type, 'ReplayOnly')
                trials = obj.replayonly_trials();
                if isempty(replayed_type)
                    return
                end
            elseif strcmp(trial_type, 'StageOnly')
                trials = obj.stageonly_trials();
                if isempty(replayed_type)
                    return
                end
            end
            
            idx = strcmp({trials(:).replay_of}, replayed_type);
            trials = trials(idx);
            
        end
        
        function trials = coupled_trials(obj)
            
            idx = strcmp(obj.list_protocols() , 'Coupled');
            trials = obj.trials(idx);
        end
         
        function trials = encoderonly_trials(obj)
            
            idx = strcmp(obj.list_protocols() , 'EncoderOnly');
            trials = obj.trials(idx);
        end
        
        
        function trials = replayonly_trials(obj)
            
            idx = strcmp(obj.list_protocols() , 'ReplayOnly');
            trials = obj.trials(idx);
        end
        
        
        function trials = stageonly_trials(obj)
            
            idx = strcmp(obj.list_protocols() , 'StageOnly');
            trials = obj.trials(idx);
        end
        
        
        function replay_trials = get_replay_of(obj, trial_in, trial_type)
            
            VariableDefault('trial_type', []);
            
            replay_trials = [];
            
            if any(strcmp(trial_in.config.log_fname, {'---', ''}))
                warning('No replay for this trial.');
                return
            end
            
            wave_fnames = obj.list_wave_fnames();
            idx = strcmp(wave_fnames, trial_in.config.log_fname);
            
            if isempty(idx)
                warning('No replay for this trial.');
                return
            else
                replay_trials = obj.trials(idx);
            end
            
            if ~isempty(trial_type)
                
                idx = strcmp({replay_trials(:).protocol}, trial_type);
                
                if sum(idx) == 0
                    replay_trials = [];
                    warning('No replay for this trial and trial type.');
                    return
                end
                
                replay_trials = replay_trials(idx);
                
            end
            
        end
        
        
        function replayed_trial = get_replayed_trial(obj, trial_in)
            
            replayed_trial = [];
            
            if any(strcmp(trial_in.config.wave_fname, {'---', ''}))
                warning('This trial is not a replay.');
                return
            end
            
            log_fnames = obj.list_log_fnames();
            idx = strcmp(log_fnames, trial_in.config.wave_fname);
            
            if isempty(idx)
                warning('Trial is from bank?');
                return
            else
                if sum(idx) > 1
                    warning('More than one match for replayed trial?');
                    return
                end
                replayed_trial = obj.trials(idx);
            end
            
        end
        
        
        function protocol_list = list_protocols(obj)
            protocol_list = arrayfun(@(x)(x.protocol), obj.trials, 'uniformoutput', false);
        end
        
        
        function log_fnames = list_log_fnames(obj)
             log_fnames = arrayfun(@(x)(x.config.log_fname), obj.trials, 'uniformoutput', false);
        end
        
        
        function wave_fnames = list_wave_fnames(obj)
             wave_fnames = arrayfun(@(x)(x.config.wave_fname), obj.trials, 'uniformoutput', false);
        end
        
        
        function offset = match_replay_to_original(obj, trial_ori, trial_replay)
            
            ori_trace = trial_ori.multiplexer_output;
            rep_trace = trial_replay.multiplexer_output;
            
            n_ori_samples = length(ori_trace);
            n_rep_samples = length(rep_trace);
            
            start_idx = 1 : 1000 : max(n_ori_samples, n_rep_samples);
            
            r = nan(1, length(start_idx));
            
            for i = 1 : length(start_idx)
                
                if n_ori_samples < n_rep_samples
                    m = min(n_ori_samples, n_rep_samples - start_idx(i) + 1);
                    o = ori_trace(1:m);
                    O = rep_trace(start_idx(i) + (0:m-1));
                else
                    m = max(1, n_rep_samples - start_idx(i) + 1);
                    M = min(n_rep_samples, start_idx(i));
                    o = ori_trace(1:m);
                    O = rep_trace(M:end);
                end
                
                r(i) = corr(o, O);
                
            end
            
            [~, max_corr_idx] = max(r);
            
            offset_correction = start_idx(max_corr_idx) - 500;
            start_idx = start_idx(max_corr_idx) + (-500:499);
            start_idx(start_idx<1) = [];
            start_idx(start_idx>max(n_ori_samples, n_rep_samples)) = [];
            
            r = nan(1, length(start_idx));
            for i = 1 : length(start_idx)
                
                if n_ori_samples < n_rep_samples
                    m = min(n_ori_samples, n_rep_samples - start_idx(i) + 1);
                    o = ori_trace(1:m);
                    O = rep_trace(start_idx(i) + (0:m-1));
                else
                    m = n_rep_samples - start_idx(i) + 1;
                    o = ori_trace(1:m);
                    O = rep_trace(start_idx(i):end);
                end
                    
                r(i) = corr(o, O);
            end
            
            [~, offset] = max(r);
            offset = offset_correction + offset - 1;
        end
        
        
        function load_replay_offsets(obj)
            
            csv_fname = fullfile(obj.config.summary_data, 'match_visual_flow_trials', sprintf('%s_trial_offset_match.csv', obj.probe_fname));
            if exist(csv_fname, 'file')
                obj.offset_table = readtable(csv_fname);
            end
            
        end
        
        
        function offset = get_offset(obj, ori_trial, rep_trial)
            
            ori_id = ori_trial.id;
            rep_id = rep_trial.id;
            
            idx = obj.offset_table.trial_id == ori_id & ...
                  obj.offset_table.replay_trial_id == rep_id;
            
            offset = obj.offset_table.offset(idx);
            
        end
        
        
        function load_stationary_vs_motion_table(obj)
            
            csv_fname = fullfile(obj.config.summary_data, 'stationary_vs_motion_fr', sprintf('%s.csv', obj.probe_fname));
            if exist(csv_fname, 'file')
                obj.svm_table = readtable(csv_fname);
            end
        end
        
        
        function fr = trial_stationary_fr(obj, cluster_id, protocol_id)
            
            trial_type = obj.protocol_type{obj.protocol_ids == protocol_id};
            replayed_type = obj.protocol_replayed_type{obj.protocol_ids == protocol_id};
            idx = obj.svm_table.cluster_id == cluster_id & ...
                strcmp(obj.svm_table.protocol, trial_type) & ...
                strcmp(obj.svm_table.replay_of, replayed_type);
            fr = obj.svm_table.stationary_firing_rate(idx);
            
        end
        
        
        function fr = trial_motion_fr(obj, cluster_id, protocol_id)
            
            trial_type = obj.protocol_type{obj.protocol_ids == protocol_id};
            replayed_type = obj.protocol_replayed_type{obj.protocol_ids == protocol_id};
            idx = obj.svm_table.cluster_id == cluster_id & ...
                strcmp(obj.svm_table.protocol, trial_type) & ...
                strcmp(obj.svm_table.replay_of, replayed_type);
            fr = obj.svm_table.motion_firing_rate(idx);
            
        end
        
    end
end