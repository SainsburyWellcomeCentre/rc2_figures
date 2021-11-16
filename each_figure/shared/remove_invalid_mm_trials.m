function trials = remove_invalid_mm_trials(trials)

mm_start_t              = cellfun(@(x)(x.mismatch_onset_t), trials);
mm_end_t                = cellfun(@(x)(x.mismatch_offset_t), trials);
invalid_trials          = mm_end_t - mm_start_t < 0.05;

if sum(invalid_trials)
    fprintf('%s, removing %i trials with mismatch periods which are too short\n', sum(invalid_trials));
    fprinff('       trial IDs:  ');
    disp(cellfun(@(x)(x.trial_id), trials(invalid_trials)));
end
