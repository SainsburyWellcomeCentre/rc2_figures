% compare responses between all conditions
input('sure?')
clear all

import helper.*

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OPTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% name of the probe recordings to analyze
probe_fname = {
    'CAA-1110262_rec1_rec2_rec3', ...
    'CAA-1110264_rec1_rec2', ...
    'CAA-1110265_restricted_rec1_rec2_rec3', ...
    'CAA-1112224_rec1_rec2_rec3', ...
    'CA_176_1_rec1_rec2_rec3', ...
    'CA_176_3_rec1_rec2_rec3', ...
    'CAA-1112416_rec1_rec2_rec3', ...
    'CAA-1112417_rec1_rec2_rec3'};

formatted_dir = 'C:\Users\Lee\Documents\mvelez\data\formatted_data';

% location to save the table of stationary/motion values
save_dir = 'C:\Users\Lee\Documents\mvelez\data\tables\stationary_vs_motion';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CALCULATE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% for printing progress
pp = PrintProgress();

% for each recording
for probe_i = 1 : length(probe_fname)
    
    % print progress
    pp.print('Recording', probe_i, length(probe_fname));
    
    % load data for this mouse
    formatted_fname = fullfile(formatted_dir, [probe_fname{probe_i}, '.mat']);
    
    % compute the table of stationary/motion values
    T = stationary_vs_motion_table(formatted_fname);
    
    % save
    save_fname = sprintf('%s_stationary_vs_motion_table.mat', probe_fname{probe_i});
    save_fname = fullfile(save_dir, save_fname);
    save(save_fname, 'T');
end
