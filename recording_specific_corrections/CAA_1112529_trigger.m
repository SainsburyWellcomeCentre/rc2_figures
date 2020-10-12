% There are extra triggers in the middle of sessions 2 and 3 in 
%   CAA-1112529_rec1_rec2_rec3 which are not associated with any RC2
%   recording.
% Here is the code from going from the probe file to the corrected trigger.

bin_fname = 'E:\mateoData_probe\janelia_pipeline\CAA-1112529\CAA-1112529_rec1_rec2_rec3_g0\CAA-1112529_rec1_rec2_rec3_g0_imec0\CAA-1112529_rec1_rec2_rec3_g0_t0.imec0.ap.bin';
trigger_fname = 'CAA-1112529_rec1_rec2_rec3_trigger.mat';

trigger = get_trigger_channel(bin_fname);

n_secs_to_reset_start = 3230;
n_secs_to_reset_end = 3280;

trigger(n_secs_to_reset_start*30e3:n_secs_to_reset_end*30e3) = -2;

save(trigger_fname, 'trigger');
