
# mvelez_ms_figures

Code to replicate the figures in Velez-Fort, Cossell, Margrie (202x) *Title* Journal.  Code developed in MATLAB 2021a on Windows 10.


Prerequisites

This code requires `rc2_analysis` to be on the MATLAB path. See instructions in that directory for setting it up.


Instructions

Open `all_figures.m` and change the options at the top of that file. Options are:

`save_enabled`: whether to save the outputted figures
`save_dir`: where to save the outputted figures
`load_data_at_start`: whether to load all the data before running the code to generate the figures.
Pre-loading the data makes processing much faster, but takes up more memory than the average machine has (on the order of 100GB).

Run: 
setup_paths         (Make sure that the server where data is stored is mounted - e.g., winstor - and that Matlab paths are setup correctly)
load_all_data       (in case load_data_at_start = false)
all_figures


Running `all_figures.m` will generate all figures/figure panels and print statistics to the MATLAB command window.
