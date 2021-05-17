classdef DarknessExperiment < MVTExperiment
    
    
    properties (Constant = true)
        
        protocol_ids = 1 : 3
        protocol_type = {'Coupled', 'EncoderOnly', 'StageOnly'};
        protocol_replayed_type = {'', '', 'any'};
        protocol_label = {'MT', 'M', 'T (MT & M & Bank)'};    
    end
    
    
    methods
        
        function obj = DarknessExperiment(data_obj, config)
            
            obj = obj@MVTExperiment(data_obj, config);
            
            obj.trials = data_obj.data.sessions(1).trials;
        end
        
        
        
        function trials = trials_of_type(obj, trial_type)
            
            trials = trials_of_type@MVTExperiment(obj, trial_type);
            
            if ~isempty(trials)
                return
            end
            
            if trial_type == 1
                trials = obj.coupled_trials();
            elseif trial_type == 2
                trials = obj.encoderonly_trials();
            elseif trial_type == 3
                trials = obj.stageonly_trials();
            elseif trial_type == 4
                trials = obj.trials_of_type_replay_of_type('StageOnly', 'Coupled');
            elseif trial_type == 5
                trials = obj.trials_of_type_replay_of_type('StageOnly', 'EncoderOnly');
            elseif trial_type == 6
                trials = obj.trials_of_type_replay_of_type('StageOnly', 'Bank');
            end
            
        end
    end
end