function h_label = setup_labels(h_fig, labels)

h_label = cell(size(labels, 1), 1);

for i = 1 : size(labels, 1)
    
    h_label{i} = a4figure_text(labels{i, 1}, h_fig, labels{i, 2});
    set(h_label{i}, 'fontsize', 12, 'fontname', 'Arial', 'fontweight', 'bold', 'color', 'k');
end