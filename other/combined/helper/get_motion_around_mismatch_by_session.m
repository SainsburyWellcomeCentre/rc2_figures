function bouts = get_motion_around_mismatch_by_session(session, options)

% append to bout array
bouts = MotionBout.empty();

% for each trial in the session
for trial_i = 1 : length(session.trials)
    
    % get this trial
    this_trial = session.trials(trial_i);
    
    % get and append bout info
    bouts = [bouts, get_motion_bouts_by_trial(this_trial, options)];
end