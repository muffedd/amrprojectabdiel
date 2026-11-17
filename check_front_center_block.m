% check_front_center_block.m
clear; clc;
evalin('base', 'run(''AGV_DataFile.m'')');
load_system('AGV_Warehouse_Sim');

agv = 'AGV_Warehouse_Sim/AGV_STEP_1_RIGID';
blks = find_system(agv, 'SearchDepth', 1);
for i = 1:length(blks)
    bname = get_param(blks{i}, 'Name');
    if contains(lower(bname), 'front') || contains(lower(bname), 'center') || contains(lower(bname), 'sensor')
        fprintf('  %s\n', bname);
    end
end

close_system('AGV_Warehouse_Sim', 0);
