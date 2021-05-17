classdef PassiveExperiment < MVTExperiment
    
    
    properties (Constant = true)
        
        protocol_ids = 1 : 3
        protocol_type = {'StageOnly', 'ReplayOnly', 'StageOnly'};
        protocol_vis_stim = [1, 1, 0];
        protocol_label = {'VT', 'V', 'T'};    
    end
    
    
    methods
        
        function obj = PassiveExperiment(data_obj, config)
            
            obj = obj@MVTExperiment(data_obj, config);
            
            obj.trials = data_obj.data.sessions(1).trials;
        end
        
        
        
        function trials = trials_of_type(obj, trial_type)
            
            trials = trials_of_type@MVTExperiment(obj, trial_type);
            
            if ~isempty(trials)
                return
            end
            
            
            
            if trial_type == 1
                trials = obj.stageonly_trials();
                t = [trials(:).config];
                idx = [t(:).enable_vis_stim] == 1;
                trials = trials(idx);
            elseif trial_type == 2
                trials = obj.replayonly_trials();
                t = [trials(:).config];
                idx = [t(:).enable_vis_stim] == 1;
                trials = trials(idx);
            elseif trial_type == 3
                trials = obj.stageonly_trials();
                t = [trials(:).config];
                idx = [t(:).enable_vis_stim] == 0;
                trials = trials(idx);
            end
            
        end
        
        
        function idx = get_svm_table_index(obj, cluster_id, protocol_id)
        %% Overwrite MVTExperiment method as it does not work for the Passive protocol
        %   need better design upstream
        
            trial_type = obj.protocol_type{obj.protocol_ids == protocol_id};
            vis_stim = obj.protocol_vis_stim(obj.protocol_ids == protocol_id);
            
            idx = obj.svm_table.cluster_id == cluster_id & ...
                    strcmp(obj.svm_table.protocol, trial_type) & ...
                    obj.svm_table.vis_stim == vis_stim;
        end
    end
end