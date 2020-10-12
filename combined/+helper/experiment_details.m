function [probe_fnames, prot_x, prot_y, replay_x, replay_y, label_x, label_y, title_str] = experiment_details(experiment, combination)

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
    
end


if strcmp(experiment, 'visual_flow') && strcmp(combination, 'motion_all_vs_all')
    
    protocols           = {'Coupled', 'EncoderOnly', 'StageOnly', 'StageOnly', 'ReplayOnly', 'ReplayOnly'};
    replay_of           = {'', '', 'Coupled', 'EncoderOnly', 'Coupled', 'EncoderOnly'};
    label               = {'L+V+F', 'L+F'; 'V+F(LVF)', 'V+F(LF)'; 'F(LVF)', 'F(LF)'};

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
            title_str = sprintf('%s vs. %s', label_y{i, j}, label_x{i, j});
        end
    end
    
elseif strcmp(experiment, 'visual_flow') && strcmp(combination, 'motion_vs_stationary')
    
    prot_y              = {'Coupled', 'EncoderOnly'; 'StageOnly', 'StageOnly'; 'ReplayOnly', 'ReplayOnly'};
    prot_x              = {'stationary', 'stationary'; 'stationary', 'stationary'; 'stationary', 'stationary'};
    replay_y            = {'', ''; 'Coupled', 'EncoderOnly'; 'Coupled', 'EncoderOnly'};
    replay_x            = {'', ''; '', ''; '', ''};
    label_y             = {'L+V+F', 'L+F'; 'V+F(LVF)', 'V+F(LF)'; 'F(LVF)', 'F(LF)'};
    label_x             = {'Stationary', 'Stationary'; 'Stationary', 'Stationary'; 'Stationary', 'Stationary'};
    title_str           = cellfun(@(x, y)([x, ' vs. ', y]), label_y, label_x, 'uniformoutput', false);
    
elseif strcmp(experiment, 'visual_flow') && strcmp(combination, 'vestibular')
    
    prot_y              = {'StageOnly', 'StageOnly'};
    replay_y            = {'', ''};
    prot_x              = {'stationary', 'ReplayOnly'};
    replay_x            = {'', ''};
    label_y             = {'V+F', 'V+F'};
    label_x             = {'Stationary', 'F'};
    title_str           = {'V+F vs. Stationary', 'V+F vs. F'};
    
elseif strcmp(experiment, 'darkness') && strcmp(combination, 'motion_all_vs_all')
    
    prot_y              = {[], 'Coupled', 'Coupled', 'Coupled'; [], [], 'EncoderOnly', 'EncoderOnly'; [], [], [], 'StageOnly'; [], [], [], []};
    prot_x              = {[], 'EncoderOnly', 'StageOnly', 'stationary'; [], [], 'StageOnly', 'stationary'; [], [], [] 'stationary'; [], [], [], []};
    replay_y            = {[], '', '', ''; [], [], '', ''; [], [], [] ''; [], [], [], []};
    replay_x            = {[], '', '', ''; [], [], '', ''; [], [], [] ''; [], [], [], []};
    label_y             = {[], 'L+V', 'L+V', 'L+V'; [], [], 'L', 'L'; [], [], [], 'V'; [], [], [], []};
    label_x             = {[], 'L', 'V', 'Stationary'; [], [], 'V', 'Stationary'; [], [], [] 'Stationary'; [], [], [], []};
    title_str           = {[], 'L+V vs. L', 'L+V vs. V', 'L+V vs. Stationary'; [], [], 'L vs. V', 'L vs. Stationary'; [], [], [], 'V vs. Stationary'; [], [], [], []};
    
elseif strcmp(experiment, 'darkness') && strcmp(combination, 'motion_vs_stationary')
    
    prot_y              = {'Coupled', 'EncoderOnly', 'StageOnly'};
    prot_x              = {'stationary', 'stationary', 'stationary'};
    replay_y            = {'', '', ''};
    replay_x            = {'', '', ''};
    label_y             = {'L+V', 'L', 'V'};
    label_x             = {'Stationary', 'Stationary', 'Stationary'};
    title_str           = {'L+V vs. Stationary', 'L vs. Stationary', 'V vs. Stationary'};

elseif strcmp(experiment, 'darkness') && strcmp(combination, 'vestibular')
    
    prot_y              = {'StageOnly'};
    replay_y            = {''};
    prot_x              = {'stationary'};
    replay_x            = {''};
    label_y             = {'V'};
    label_x             = {'Stationary'};
    title_str           = {'V vs. Stationary'};
    
end




   