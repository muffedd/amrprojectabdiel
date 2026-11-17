% find_front_center.m
clear; clc;
evalin('base', 'run(''AGV_DataFile.m'')');
load_system('AGV_Warehouse_Sim');

% Let's check the solids inside AGV_STEP_1_RIGID or inspect the Front Casing
% In AGV_Aligned_Plant / AGV_Warehouse_Sim, the solids are File Solid or Solid
% Let's see the position of Front Casing or SICK 3000 Sensor
blks = find_system('AGV_Warehouse_Sim/AGV_STEP_1_RIGID', 'SearchDepth', 1);
for i = 1:length(blks)
    name = get_param(blks{i}, 'Name');
    if contains(name, 'Front') || contains(name, 'SICK') || contains(name, 'Bottom')
        disp(name);
    end
end

close_system('AGV_Warehouse_Sim', 0);
