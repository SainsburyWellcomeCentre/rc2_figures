clear all
close all

probe_fname = 'CAA-1110265_restricted';

ks_dir = fullfile('E:\mateoData_probe\janelia_pipeline', ...
                   probe_fname, ...
                   '\output\catgt_CAA-1110265_restricted_rec1_rec2_rec3_g0\CAA-1110265_restricted_rec1_rec2_rec3_g0_imec0\imec0_ks2');

rc_names = {
    'Z:\swc\margrie\mvelez\mateoData_rc2\CAA-1110265\CAA-1110265\CAA-1110265_rec1_001.bin', ...
    'Z:\swc\margrie\mvelez\mateoData_rc2\CAA-1110265\CAA-1110265\CAA-1110265_rec2_001.bin', ...
    'Z:\swc\margrie\mvelez\mateoData_rc2\CAA-1110265\CAA-1110265\CAA-1110265_rec3_001.bin'};

tic
clusters = format_clusters(ks_dir);
sessions = format_sessions(rc_names);
[t_sync, n_trig] = synchronize(ks_dir, rc_names);
toc

sessions = recording_specific_correction(sessions, probe_fname);

save(probe_fname, '-v7.3', 'clusters', 'sessions', 't_sync', 'n_trig')
