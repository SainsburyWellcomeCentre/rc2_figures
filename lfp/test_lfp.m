clear all

% location of LFP recording
animal_id = {'CAA-1110262', 'CAA-1110263_restricted', 'CAA-1110264', 'CAA-1110265_restricted'};
probe_suffix = {'rec1_rec2_rec3', 'rec1_rec2_rec3', 'rec1_rec2', 'rec1_rec2_rec3'};

p = cell(length(animal_id), 1);
channel_list = cell(length(animal_id), 1);

for rec_i = 1 : length(animal_id)
    
    % Build filename for LFP data...
    lf_fname = fullfile('E:\mateoData_probe\janelia_pipeline', animal_id{rec_i}, ...
        sprintf('%s_%s_g0', animal_id{rec_i}, probe_suffix{rec_i}), ...
        sprintf('%s_%s_g0_imec0', animal_id{rec_i}, probe_suffix{rec_i}), ...
        sprintf('%s_%s_g0_t0.imec0.lf.bin', animal_id{rec_i}, probe_suffix{rec_i}));
    
    [~, p{rec_i}, channel_list{rec_i}] = get_lfp_power(lf_fname);
end


%%
reference_chans = [37, 76, 113, 152, 189];
bad_chans = 1:5;
nonref_chans = 1:201;
nonref_chans(union(bad_chans, reference_chans)) = nan;


%%
figure
for i = 1 : 4
    subplot(2, 2, i)
    plot(nonref_chans, p{i}(:, 1:6))
end


%%
figure
for i = 1 : 4
    subplot(2, 2, i)
    plot(nonref_chans(3:4:end), p{i}(3:4:end, 1:6))
end

%%
figure; hold on;
for i = 1 : 4
    plot(nonref_chans(2:4:end), median(p{i}(2:4:end, 1:14), 2))
end