# mvelez_ms_figures
Code to replicate an older version of the figures in Velez-Fort, Cossell, Porta, Clopath, Margrie (2025). Code developed in MATLAB 2021a on Windows 10.

## Prerequisites
This code requires [`rc2_analysis`](https://github.com/SainsburyWellcomeCentre/rc2_analysis) to be on the MATLAB path, and the [formatted data](https://figshare.com/s/05f3b5b43d048834a35e?file=51218171). 

## Instructions
Open `all_figures.m` and change the options at the top of that file. Options are:

`save_enabled`: whether to save the outputted figures
`save_dir`: where to save the outputted figures
`load_data_at_start`: whether to load all the data before running the code to generate the figures.
Pre-loading the data makes processing much faster, but takes up more memory than the average machine has (on the order of 100GB).

Run:  
- setup_paths         (specify the paths in the [`path_config.m`](https://github.com/SainsburyWellcomeCentre/rc2_analysis/blob/master/path_config.m) file and run `setup_paths.m` in the `rc2_analysis` project)
- load_all_data       (in case load_data_at_start = false)
- all_figures

Running `all_figures.m` will generate all figures/figure panels and print statistics to the MATLAB command window.

For certain velocity and acceleration related plots, it will be necessary to re-create the tuning curve tables. You can do so via [`create_tables.m`](https://github.com/SainsburyWellcomeCentre/rc2_analysis/blob/master/scripts/preprocess/create_tables.m) and [`create_tables_acceleration.m`](https://github.com/SainsburyWellcomeCentre/rc2_analysis/blob/master/scripts/preprocess/create_tables_acceleration.m).
