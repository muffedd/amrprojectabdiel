% list_root_blocks.m
clear; clc;
load_system('AGV_Warehouse_Sim');

blks = find_system('AGV_Warehouse_Sim', 'SearchDepth', 1);
for i = 1:length(blks)
    fprintf('  %s\n', blks{i});
end

close_system('AGV_Warehouse_Sim', 0);
