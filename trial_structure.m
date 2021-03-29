experiment          = 'darkness';

config              = RC2AnalysisConfig();

figs                = RC2Figures(config);
figs.save_on        = true;
figs.set_figure_subdir(experiment, 'trial_structure');

probe_fnames        = experiment_details(experiment, 'protocols');

for probe_i = 1 : length(probe_fnames)
    
    data = config.load_formatted_data(probe_fnames{probe_i});
    
    switch experiment
        case 'visual_flow'
            exp_obj = VisualFlowExperiment(data, config);
        case 'darkness'
            exp_obj = DarknessExperiment(data, config);
    end
    
    for trial_i = 1 : length(exp_obj.trials)
        
        this_trial = exp_obj.trials(trial_i);
        
        if this_trial.is_replay && ~strcmp(this_trial.replay_of, 'Bank')
            replayed_trial = exp_obj.get_replayed_trial(this_trial);
            offset = exp_obj.get_offset(replayed_trial, this_trial);
            this_trial = AlignedTrial(this_trial, replayed_trial, offset);
        end
        
        TrialStructure(this_trial);
        
        figs.save_fig_to_join();
    end
    
    fname = sprintf('%s.pdf', probe_fnames{probe_i});
    figs.join_figs(fname);
    figs.clear_figs();
end
