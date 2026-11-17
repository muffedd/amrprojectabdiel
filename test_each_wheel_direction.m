% test_each_wheel_direction.m
clear; clc;
evalin('base', 'run(''AGV_DataFile.m'')');
load_system('AGV_Warehouse_Sim');

set_param('AGV_Warehouse_Sim/Warehouse_Floor', 'BrickDimensions', '[30 30 0.1]');

j6 = 'AGV_Warehouse_Sim/Joint_6DOF';
set_param(j6, 'PxPositionTargetSpecify', 'on', 'PxPositionTargetValue', '-2.0', 'PxPositionTargetPriority', 'High');
set_param(j6, 'PyPositionTargetSpecify', 'on', 'PyPositionTargetValue', '-3.0', 'PyPositionTargetPriority', 'High');
set_param(j6, 'SphPositionTargetSpecify', 'on', ...
              'SphPositionTargetPriority', 'High', ...
              'SphPositionTargetRotationMethod', 'StandardAxis', ...
              'SphPositionTargetRotationStandardAxis', '+Z', ...
              'SphPositionTargetRotationAngle', '180', ...
              'SphPositionTargetRotationAngleUnits', 'deg');

agv = 'AGV_Warehouse_Sim/AGV_STEP_1_RIGID';

% Inside each DWA, let's see how Revolute_Joint is oriented and connected!
for k = 1:4
    dwa = sprintf('%s/Drive_Wheel_Assembly_STEP_%d_RIGID', agv, k);
    rj = [dwa, '/Revolute_Joint'];
    fprintf('DWA %d Revolute Joint:\n', k);
    fprintf('  ReverseDirection: %s\n', get_param(rj, 'ReverseDirection'));
end

close_system('AGV_Warehouse_Sim', 0);
