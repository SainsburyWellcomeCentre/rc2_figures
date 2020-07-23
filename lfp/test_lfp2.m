probe_dir = {'E:\mateoData_probe\janelia_pipeline\CAA-1110262\CAA-1110262_rec1_rec2_rec3_g0\CAA-1110262_rec1_rec2_rec3_g0_imec0'; ...
              'E:\mateoData_probe\janelia_pipeline\CAA-1110263\CAA-1110263_rec1_rec2_rec3_g0\CAA-1110263_rec1_rec2_rec3_g0_imec0'; ...
              'E:\mateoData_probe\janelia_pipeline\CAA-1110264\CAA-1110264_rec1_rec2_g0\CAA-1110264_rec1_rec2_g0_imec0'; ...
              'E:\mateoData_probe\janelia_pipeline\CAA-1110265\CAA-1110265_rec1_rec2_rec3_g0\CAA-1110265_rec1_rec2_rec3_g0_imec0'};

for probe_i = 1 : length(probe_dir)
    lf(probe_i) = LFP(probe_dir{probe_i});
end


%%
offset = nan(202, 4);
stdev = nan(202, 4);
for probe_i = 1 : length(probe_dir)
    this_data = lf(probe_i).get_data_between_t(':', [0, 50], 'uv');
    offset(:, probe_i) = mean(this_data, 2);
    stdev(:, probe_i) = std(this_data, [], 2);
end


%% channel offsets for each experiment
figure; hold on;
plot(offset);


%% 
figure; hold on;
plot(offset(1:2:end, :), 'r');
plot(offset(2:2:end, :), 'b');


%% channel offset correlation across experiments
figure
for exp_i = 1 : 3
    for exp_j = exp_i+1:4
        subplot(4, 4, (exp_i-1)*4+exp_j); hold on;
        scatter(offset(1:end-1, exp_j), offset(1:end-1, exp_i));
        scatter(offset(lf(1).reference_channels, exp_j), ...
            offset(lf(1).reference_channels, exp_i), [], 'r');
        line([-2000, 0], [-2000, 0], 'linestyle', '--');
    end
end


%% standard deviations
figure; hold on;
plot(lf(1).channels, stdev(lf(1).channels, :))

%% channel offset correlation across experiments
figure
for exp_i = 1 : 3
    for exp_j = exp_i+1:4
        subplot(4, 4, (exp_i-1)*4+exp_j); hold on;
        scatter(stdev(lf(1).channels, exp_j), stdev(lf(1).channels, exp_i));
        scatter(stdev(lf(1).reference_channels, exp_j), ...
            stdev(lf(1).reference_channels, exp_i), [], 'r');
        line([0, 1000], [0, 1000], 'linestyle', '--');
    end
end


%% Bandpower
chans_to_process = 2 : 4 : lf(1).n_channels;
bad_channels = intersect(chans_to_process, [lf(1).reference_channels, lf(1).trigger_channel]);
good_channels = setdiff(chans_to_process, bad_channels);

full_mtx = lf(2).get_data_between_t(chans_to_process, [2460, 2580], 's');

pow = nan(size(full_mtx, 1), 1);
for chan_i = 1 : size(full_mtx, 1)
    
    trace = full_mtx(chan_i, :);
    if mod(lf(1).n_samples, 2) == 1
        trace = [trace, trace(end)];
    end
    
    pow(chan_i) = bandpower(trace, lf(1).fs, [500, min(lf(1).fs/2-1, 2500)]);
end

hold on, plot(chans_to_process, pow)
