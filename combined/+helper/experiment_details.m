function [probe_fnames, prot_x, prot_y, replay_x, replay_y, label_x, label_y, title_str, vis_stim] = ...
    experiment_details(experiment, combination)


% name of the probe recordings to analyze
if strcmp(experiment, 'darkness')
    
    probe_fnames = {'CA_176_1_rec1_rec2_rec3', ...
        'CA_176_3_rec1_rec2_rec3', ...
        'CAA-1112416_rec1_rec2_rec3', ...
        'CAA-1112417_rec1_rec2_rec3'};
    
elseif strcmp(experiment, 'visual_flow')
    
    probe_fnames = {'CAA-1110262_rec1_rec2_rec3', ...
        'CAA-1110264_rec1_rec2', ...
        'CAA-1110265_restricted_rec1_rec2_rec3', ...
        'CAA-1112224_rec1_rec2_rec3'};

elseif strcmp(experiment, 'head_tilt')
    
    probe_fnames = {'CAA-1112529_rec1_rec2_rec3', ...
        'CAA-1112530_rec1_rec2_rec3', ...
        'CAA-1112531_rec1_rec2_rec3', ...
        'CAA-1112532_rec1_rec2_rec3'};
    
end




if strcmp(experiment, 'visual_flow') && strcmp(combination, 'motion_all_vs_all')
    
    protocols           = {'Coupled', 'EncoderOnly', 'StageOnly', 'StageOnly', 'ReplayOnly', 'ReplayOnly'};
    replay_of           = {'', '', 'Coupled', 'EncoderOnly', 'Coupled', 'EncoderOnly'};
    label               = {'V+T+M', 'V+M', 'V+T(VTM)', 'V+T(VM)', 'V(VTM)', 'V(VM)'};

    prot_y = cell(6);
    prot_x = cell(6);
    replay_y = cell(6);
    replay_x = cell(6);
    label_y = cell(6);
    label_x = cell(6);
    title_str = cell(6);
    
    for i = 1 : length(protocols)-1
        for j = i+1 : length(protocols)
            
            prot_y{i, j} = protocols{i};
            prot_x{i, j} = protocols{j};
            
            replay_y{i, j} = replay_of{i};
            replay_x{i, j} = replay_of{j};
            
            label_y{i, j} = label{i};
            label_x{i, j} = label{j};
            title_str{i, j} = sprintf('%s vs. %s', label_y{i, j}, label_x{i, j});
        end
    end
    
    vis_stim = nan(6);
    
elseif strcmp(experiment, 'visual_flow') && strcmp(combination, 'motion_vs_stationary')
    
    prot_y              = {'Coupled', 'EncoderOnly'; 'StageOnly', 'StageOnly'; 'ReplayOnly', 'ReplayOnly'};
    prot_x              = {'stationary', 'stationary'; 'stationary', 'stationary'; 'stationary', 'stationary'};
    replay_y            = {'', ''; 'Coupled', 'EncoderOnly'; 'Coupled', 'EncoderOnly'};
    replay_x            = {'', ''; '', ''; '', ''};
    label_y             = {'V+T+M', 'V+M'; 'V+T(VTM)', 'V+T(VM)'; 'V(VTM)', 'V(VM)'};
    label_x             = {'Stationary', 'Stationary'; 'Stationary', 'Stationary'; 'Stationary', 'Stationary'};
    title_str           = cellfun(@(x, y)([x, ' vs. ', y]), label_y, label_x, 'uniformoutput', false);
    
    vis_stim            = nan(size(prot_x));
    
elseif strcmp(experiment, 'visual_flow') && strcmp(combination, 'vestibular')
    
    prot_y              = {'StageOnly', 'StageOnly'};
    replay_y            = {'', ''};
    prot_x              = {'stationary', 'ReplayOnly'};
    replay_x            = {'', ''};
    label_y             = {'V+T', 'V+T'};
    label_x             = {'Stationary', 'V'};
    title_str           = {'V+T vs. Stationary', 'V+T vs. V'};
    vis_stim            = nan(size(prot_x));
    
elseif strcmp(experiment, 'darkness') && strcmp(combination, 'motion_all_vs_all')
    
    prot_y              = {[], 'Coupled', 'Coupled', 'Coupled'; [], [], 'EncoderOnly', 'EncoderOnly'; [], [], [], 'StageOnly'; [], [], [], []};
    prot_x              = {[], 'EncoderOnly', 'StageOnly', 'stationary'; [], [], 'StageOnly', 'stationary'; [], [], [] 'stationary'; [], [], [], []};
    replay_y            = {[], '', '', ''; [], [], '', ''; [], [], [] ''; [], [], [], []};
    replay_x            = {[], '', '', ''; [], [], '', ''; [], [], [] ''; [], [], [], []};
    label_y             = {[], 'T+M', 'T+M', 'T+M'; [], [], 'M', 'M'; [], [], [], 'T'; [], [], [], []};
    label_x             = {[], 'M', 'T', 'Stationary'; [], [], 'T', 'Stationary'; [], [], [] 'Stationary'; [], [], [], []};
    title_str           = {[], 'T+M vs. M', 'T+M vs. T', 'T+M vs. Stationary'; [], [], 'M vs. T', 'M vs. Stationary'; [], [], [], 'T vs. Stationary'; [], [], [], []};
    vis_stim            = nan(size(prot_x));
    
elseif strcmp(experiment, 'darkness') && strcmp(combination, 'motion_vs_stationary')
    
    prot_y              = {'Coupled', 'EncoderOnly', 'StageOnly'};
    prot_x              = {'stationary', 'stationary', 'stationary'};
    replay_y            = {'', '', ''};
    replay_x            = {'', '', ''};
    label_y             = {'T+M', 'M', 'T'};
    label_x             = {'Stationary', 'Stationary', 'Stationary'};
    title_str           = {'T+M vs. Stationary', 'M vs. Stationary', 'T vs. Stationary'};
    vis_stim            = nan(size(prot_x));
    
elseif strcmp(experiment, 'darkness') && strcmp(combination, 'vestibular')
    
    prot_y              = {'StageOnly'};
    replay_y            = {''};
    prot_x              = {'stationary'};
    replay_x            = {''};
    label_y             = {'T'};
    label_x             = {'Stationary'};
    title_str           = {'T vs. Stationary'};
    vis_stim            = nan(size(prot_x));
    
elseif strcmp(experiment, 'head_tilt')
    
    prot_y              = {'StageOnly', 'StageOnly', 'StageOnly'};
    replay_y            = {'', '', ''};
    prot_x              = {'stationary', 'stationary', 'ReplayOnly'};
    replay_x            = {'', '', ''};
    label_y             = {'T', 'V+T', 'V+T'};
    label_x             = {'Stationary', 'Stationary', 'V'};
    title_str           = {'Dark', 'Light', 'Light'};
    vis_stim            = [0, 1, 1];
    
end




   