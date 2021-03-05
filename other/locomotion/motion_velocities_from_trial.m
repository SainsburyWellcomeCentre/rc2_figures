function vel = motion_velocities_from_trial(trial)

sm = StationaryMask(trial.velocity, trial.fs);
aw = AnalysisWindow(trial);

vel = trial.velocity(~sm.mask & aw.mask);
