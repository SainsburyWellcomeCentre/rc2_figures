% plot histograms of velocities during locomotion for a set of recordings
% TODO: we may want to load directly from the .bin RC2 files.

% list of recordings to plot
probe_fname = {'CAA-1110262_rec1_rec2_rec3', ...
     'CAA-1110263_restricted_rec1_rec2_rec3', ...
     'CAA-1110264_rec1_rec2', ...
     'CAA-1110265_restricted_rec1_rec2_rec3'};

% for each recording
for probe_i = 1 : length(probe_fname)
    
    % location of the formatted data
    formatted_data_fname = fullfile('C:\Users\Lee\Documents\mvelez\data\formatted_data', [probe_fname{probe_i}, '.mat']);
    
    % load formatted data
    load(formatted_data_fname);
    
    % create session object for the running data
    session_obj = Session(sessions(1), t_sync{1});
    
    % split locovest and loco trials
    protocol_order = {'locovest', 'loco'};
    prot_trials{1} = session_obj.trials_by_protocol('Coupled');
    prot_trials{2} = session_obj.trials_by_protocol('EncoderOnly');
    n_prot = length(prot_trials);
    
    % gather all velocities during motion
    % for each protocol (loco and locovest)
    for prot_i = 1 : n_prot
        % for each of those trials
        for trial_i = length(prot_trials{prot_i}) : -1 : 1
            
            this_trial = prot_trials{prot_i}(trial_i);
            
            % append the motion velocities for this trial
            motion_velocities{prot_i}{trial_i} = motion_velocities_from_trial(this_trial);
        end
    end
    
    % create a figure for this recording
    figure
    % for each protocol
    for prot_i = 1 : n_prot
        
        % get all velocities in all trials
        all_velocities = cat(1, motion_velocities{prot_i}{:});
        
        % median velocity for this protocol
        median_velocity = median(all_velocities);
        
        % create an axis for this protocol
        subplot(1, n_prot, prot_i);
        
        % plot a histogram of velocity values
        histogram(all_velocities, 100);
        
        % show where the median is and the value
        line(median_velocity*[1,1], get(gca, 'ylim'), 'color', 'r');
        text(median_velocity, max(get(gca, 'ylim')), ...
            sprintf('%.2f cm/s', median_velocity), ...
            'verticalalignment', 'top', 'horizontalalignment', 'left');
        
        % small formatting changes
        box off;
        title(protocol_order{prot_i});
        xlabel('Velocity (cm/s)');
        ylabel('# sample points');
    end
    
    % give the figure a title
    FigureTitle(gcf, probe_fname{probe_i});
end