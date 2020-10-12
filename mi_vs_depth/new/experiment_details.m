function experiment_details(experiment)

% name of the probe recordings to analyze
if strcmp(experiment, 'darkness')
    probe_fnames = {'CA_176_1_rec1_rec2_rec3', ...
        'CA_176_3_rec1_rec2_rec3', ...
        'CAA-1112416_rec1_rec2_rec3', ...
        'CAA-1112417_rec1_rec2_rec3'};
elseif strcmp(experiment, 'light')
    probe_fname = {'CAA-1110262_rec1_rec2_rec3', ...
        'CAA-1110264_rec1_rec2', ...
        'CAA-1110265_restricted_rec1_rec2_rec3', ...
        'CAA-1112224_rec1_rec2_rec3'};
end

if strcmp(experiment, 'light') & strcmp(plot_type, 'motion_all_v_all')
    
    protocols           = {'Coupled', 'EncoderOnly', 'StageOnly', 'StageOnly', 'ReplayOnly', 'ReplayOnly'};
    protocols_x          = repmat(protocols, 6, 1);
    protocols_y          = repmat(protocols', 1, 6);
    
    replay_of           = {'', '', 'Coupled', 'EncoderOnly', 'Coupled', 'EncoderOnly'};
    replay_of_x             = repmat(replay_of, 6, 1);
    replay_of_y             = repmat(replay_of', 1, 6);
    
    idx                 = find(triu(ones(6), 1));
    
    prot_x              = protocols_x(idx);
    prot_y              = protocols_y(idx);
    replay_x            = replay_of_x(idx);
    replay_y            = replay_of_y(idx);
    
elseif strcmp(experiment, 'light') & strcmp(plot_type, 'motion_vs_stationary')
    
    prot_y           = {'Coupled', 'EncoderOnly', 'StageOnly', 'StageOnly', 'ReplayOnly', 'ReplayOnly'};
    replay_y           = {'', '', 'Coupled', 'EncoderOnly', 'Coupled', 'EncoderOnly'};
    prot_x           = {'stationary', 'stationary', 'stationary', 'stationary', 'stationary', 'stationary'};
    replay_x           = {'', '', '', '', '', ''};
    
elseif strcmp(experiment, 'darkness') & strcmp(plot_type, 'motion_all_v_all')
    
    protocols           = {'Coupled', 'EncoderOnly', 'StageOnly', 'StageOnly', 'ReplayOnly', 'ReplayOnly'};
    protocols_x          = repmat(protocols, 6, 1);
    protocols_y          = repmat(protocols', 1, 6);
    
    replay_of           = {'', '', 'Coupled', 'EncoderOnly', 'Coupled', 'EncoderOnly'};
    replay_of_x             = repmat(replay_of, 6, 1);
    replay_of_y             = repmat(replay_of', 1, 6);
    
    idx                 = find(triu(ones(6), 1));
    
    prot_x              = protocols_x(idx);
    prot_y              = protocols_y(idx);
    replay_x            = replay_of_x(idx);
    replay_y            = replay_of_y(idx);
    
    
end
    



