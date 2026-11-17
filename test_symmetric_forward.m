% test_symmetric_forward.m
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

% Wheel 1 & 2: -0.5 Nm (Left side forward)
% Wheel 3 & 4: +0.5 Nm (Right side forward)
set_param([agv, '/T_Wheel_1'], 'Value', '-0.5');
set_param([agv, '/T_Wheel_2'], 'Value', '-0.5');
set_param([agv, '/T_Wheel_3'], 'Value', '+0.5');
set_param([agv, '/T_Wheel_4'], 'Value', '+0.5');

simOut = sim('AGV_Warehouse_Sim', 'StopTime', '0.15');
xy = simOut.xy_log.Data;
yaw = simOut.yaw_log.Data;

if ndims(xy) == 3
    x0 = xy(1,1,1); y0 = xy(2,1,1);
    x_end = xy(1,1,end); y_end = xy(2,1,end);
else
    x0 = xy(1,1); y0 = xy(1,2);
    x_end = xy(end,1); y_end = xy(end,2);
end
psi0 = yaw(1); psi_end = yaw(end);

fprintf('Symmetric Forward (+0.5 N*m both sides):\n');
fprintf('Start: X = %.5f, Y = %.5f, Yaw = %.4f\n', x0, y0, psi0);
fprintf('End:   X = %.5f, Y = %.5f, Yaw = %.4f\n', x_end, y_end, psi_end);
fprintf('Delta X: %+.5f m\n', x_end - x0);
fprintf('Delta Y: %+.5f m\n', y_end - y0);
fprintf('Delta Yaw: %+.5f rad\n', psi_end - psi0);

close_system('AGV_Warehouse_Sim', 0);
