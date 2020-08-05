% directory of rc2 files
rc2_dir = 'Z:\swc\margrie\mvelez\mateoData_rc2\CA_176_3\CA_176_3';

rc2_fnames = dir(fullfile(rc2_dir, '*trn*.cfg'));
rc2_fnames = cellfun(@(x, y)(fullfile(x, y)), {rc2_fnames(:).folder}, {rc2_fnames(:).name}, 'uniformoutput', false);

for i = 1 : length(rc2_fnames)
    
    idx = contains(rc2_fnames, sprintf('trn%i_', i));
    config = read_rc2_config(rc2_fnames{idx});
    
    distance(i) = config.prot(1).start_pos - config.prot(1).forward_limit;
end

hold on, plot(distance)