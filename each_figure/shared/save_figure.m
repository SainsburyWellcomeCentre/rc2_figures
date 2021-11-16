 function save_figure(save_dir, fname)

ctl = RC2Analysis();

lib_git = ctl.save.git.info;

% assume that top of work tree is two levels deep
figure_git = Git(fileparts(fileparts(fileparts(mfilename('fullpath')))));
figure_git = figure_git.info;

figure_fname = fullfile(save_dir, sprintf('%s.pdf', fname));
git_fname = fullfile(save_dir, sprintf('%s.cfg', fname));

if isfile(figure_fname)
    error('Figure file %s already exists, delete and then rerun', figure_fname);
end

% save to pdf
print(figure_fname, '-dpdf');

% save git config
fid = fopen(git_fname, 'w');

fprintf(fid, 'lib_git.git_dir = %s\n', lib_git.git_dir);
fprintf(fid, 'lib_git.sha1 = %s\n', lib_git.sha1);
fprintf(fid, 'lib_git.date = %s\n', lib_git.date);
fprintf(fid, 'lib_git.git_clean = %i\n', lib_git.git_clean);

fprintf(fid, 'figure_git.git_dir = %s\n', figure_git.git_dir);
fprintf(fid, 'figure_git.sha1 = %s\n', figure_git.sha1);
fprintf(fid, 'figure_git.date = %s\n', figure_git.date);
fprintf(fid, 'figure_git.git_clean = %i\n', figure_git.git_clean);

fclose(fid);
