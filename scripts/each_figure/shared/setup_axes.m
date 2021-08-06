function h_ax = setup_axes(h_fig, axes_positions)

h_ax = containers.Map('KeyType', 'char', 'ValueType', 'any');

for i = 1 : size(axes_positions, 1)
    
    h_ax(axes_positions{i, 1}) = a4axis(h_fig, axes_positions{i, 2});
end
