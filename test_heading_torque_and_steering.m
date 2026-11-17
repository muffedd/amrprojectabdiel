% test_heading_torque_and_steering.m
clear; clc;
evalin('base', 'run(''AGV_DataFile.m'')');
load_system('AGV_Warehouse_Sim');

% 1. Inspect Spherical target parameters of Joint_6DOF
j6 = 'AGV_Warehouse_Sim/Joint_6DOF';
dp = get_param(j6, 'DialogParameters');
f = fieldnames(dp);
disp('Joint_6DOF SphPosition parameters:');
disp(f(contains(f, 'SphPositionTarget')));

% 2. Check Warehouse_Floor dimensions
wf = 'AGV_Warehouse_Sim/Warehouse_Floor';
fprintf('Current Warehouse_Floor BrickDimensions: %s\n', get_param(wf, 'BrickDimensions'));

% 3. Check what happens if we set SphPositionTargetRotationMethod
try
    disp(['Current SphPositionTargetRotationMethod: ', get_param(j6, 'SphPositionTargetRotationMethod')]);
catch ME
    disp(ME.message);
end

close_system('AGV_Warehouse_Sim', 0);
