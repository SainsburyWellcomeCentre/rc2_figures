probe_dir = {'E:\mateoData_probe\janelia_pipeline\CAA-1110262\CAA-1110262_rec1_rec2_rec3_g0\CAA-1110262_rec1_rec2_rec3_g0_imec0'; ...
              'E:\mateoData_probe\janelia_pipeline\CAA-1110263\CAA-1110263_rec1_rec2_rec3_g0\CAA-1110263_rec1_rec2_rec3_g0_imec0'; ...
              'E:\mateoData_probe\janelia_pipeline\CAA-1110264\CAA-1110264_rec1_rec2_g0\CAA-1110264_rec1_rec2_g0_imec0'; ...
              'E:\mateoData_probe\janelia_pipeline\CAA-1110265\CAA-1110265_rec1_rec2_rec3_g0\CAA-1110265_rec1_rec2_rec3_g0_imec0'};

for probe_i = 1 : length(probe_dir)
    lf(probe_i) = LFP(probe_dir{probe_i});
    ap(probe_i) = AP(probe_dir{probe_i});
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
rec_i = 1;

start_t = 100;

for t_i = 1 : length(start_t)
    
    figure
    
    for start_chan = 1 : 4
        
        chans_to_process = start_chan : 4 : lf(rec_i).n_channels;
        bad_channels = intersect(chans_to_process, [lf(rec_i).reference_channels, lf(rec_i).trigger_channel]);
        good_channels = setdiff(chans_to_process, bad_channels);
        
        full_mtx = lf(rec_i).get_data_between_t(good_channels, start_t(t_i) + [0, 1000], 's');%100, 220], 's'); % [2460, 2580]
        
        pow = nan(size(full_mtx, 1), 1);
        
        for chan_i = 1 : size(full_mtx, 1)
            chan_i
            trace = full_mtx(chan_i, :);
            if mod(lf(1).n_samples, 2) == 1
                trace = [trace, trace(end)];
            end
            pow(chan_i) = bandpower(trace, lf(rec_i).fs, [500, min(lf(rec_i).fs/2-1, 5000)]);
        end
        
        hold on, plot(get_channel_distance_from_tip(good_channels-1), pow)
    end
    
    title(sprintf('[%i, %i]', start_t(t_i), start_t(t_i)+120))
end
