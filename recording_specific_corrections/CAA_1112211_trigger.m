% There are extra triggers in the middle of sessions 1 and 2 in
%   CAA-1112151_rec12345 which are not associated with any RC2
%   recording.
% Here is the code from going from the probe file to the corrected trigger.

bin_fname = 'E:\mateoData_probe\janelia_pipeline\CAA_1112151\CAA-1112151_rec12345_g0\CAA-1112151_rec12345_g0_imec0\CAA-1112151_rec12345_g0_t0.imec0.ap.bin';
trigger_fname = 'CAA-1112151_rec12345_trigger.mat';

trigger = get_trigger_channel(bin_fname);

n_secs_to_reset_start = 700;
n_secs_to_reset_end = 900;
trigger(n_secs_to_reset_start*30e3:n_secs_to_reset_end*30e3) = -2;

save(trigger_fname, 'trigger');
