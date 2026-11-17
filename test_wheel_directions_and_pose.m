% test_wheel_directions_and_pose.m
clear; clc;
evalin('base', 'run(''AGV_DataFile.m'')');
load_system('AGV_Warehouse_Sim');

% Let's inspect the world positions of the 4 wheels and the chassis
% In AGV_Aligned_Plant / AGV_Warehouse_Sim:
% Top transform has RotationMethod = ArbitraryAxis, [1 0 0], pi/2.
% Let's inspect the transforms leading to each wheel.

% DWA 1 & 2:
% rt_idx = [40, 47, 26, 57]
% Let's look at the CAD translations for each wheel:
for k = 1:4
    rt = smiData.RigidTransform(k); % let's check wheel_rt_idx
end
wheel_rt_idx = [40, 47, 26, 57];
for k = 1:4
    idx = wheel_rt_idx(k);
    rt = smiData.RigidTransform(idx);
    fprintf('Wheel %d (RT %d): trans = %s\n', k, idx, mat2str(rt.translation, 4));
end

close_system('AGV_Warehouse_Sim', 0);
