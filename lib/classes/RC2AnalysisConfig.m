classdef RC2AnalysisConfig < handle
    
    properties
        
        figure_dir = 'C:\Users\Lee\Documents\mvelez\figures'
        formatted_data_dir  = 'C:\Users\Lee\Documents\mvelez\data\formatted_data'
        summary_data = 'C:\Users\Lee\Documents\mvelez\data\summary_data'
        
    end
    
    methods
        
        function obj = RC2AnalysisConfig()
        end
        
        
        
        function data = load_formatted_data(obj, probe_recording)
            
            formatted_data_fname = fullfile(obj.formatted_data_dir, [probe_recording, '.mat']);
            data = load_data(formatted_data_fname);
            data.probe_recording = probe_recording;
            data = DataController(data, obj);
        end
        
    end
end