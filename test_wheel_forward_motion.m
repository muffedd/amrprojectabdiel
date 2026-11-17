% test_wheel_forward_motion.m
clear; clc;
evalin('base', 'run(''AGV_DataFile.m'')');
load_system('AGV_Warehouse_Sim');

% Expand floor to 30m x 30m
set_param('AGV_Warehouse_Sim/Warehouse_Floor', 'BrickDimensions', '[30 30 0.1]');

% Set start pose on track before Blue station
% Track_South is Y = -3.0. Blue is at (0, -3.0).
% Start at X = -2.0, Y = -3.0, yaw = 180 deg
j6 = 'AGV_Warehouse_Sim/Joint_6DOF';
set_param(j6, 'PxPositionTargetSpecify', 'on', 'PxPositionTargetValue', '-2.0', 'PxPositionTargetPriority', 'High');
set_param(j6, 'PyPositionTargetSpecify', 'on', 'PyPositionTargetValue', '-3.0', 'PyPositionTargetPriority', 'High');
set_param(j6, 'SphPositionTargetSpecify', 'on', ...
              'SphPositionTargetPriority', 'High', ...
              'SphPositionTargetRotationMethod', 'StandardAxis', ...
              'SphPositionTargetRotationStandardAxis', '+Z', ...
              'SphPositionTargetRotationAngle', '180', ...
              'SphPositionTargetRotationAngleUnits', 'deg');

% Log Get_XY
if isempty(find_system('AGV_Warehouse_Sim', 'SearchDepth', 1, 'Name', 'Log_Pos'))
    add_block('simulink/Sinks/To Workspace', 'AGV_Warehouse_Sim/Log_Pos', 'VariableName', 'pos_log', 'SaveFormat', 'Array');
    add_line('AGV_Warehouse_Sim', 'Get_XY/1', 'Log_Pos/1', 'autorouting', 'on');
end

% Check if Out_LatError and Out_State exist
% Let's run a 0.05s test simulation
simOut = sim('AGV_Warehouse_Sim', 'StopTime', '0.05');

p = simOut.pos_log;
fprintf('Start pos: X = %.5f, Y = %.5f\n', p(1,1), p(1,2));
fprintf('End   pos: X = %.5f, Y = %.5f\n', p(end,1), p(end,2));
fprintf('Delta X:   %.5f m\n', p(end,1) - p(1,1));
fprintf('Delta Y:   %.5f m\n', p(end,2) - p(1,2));

if (p(end,1) - p(1,1)) > 0
    disp('--> SUCCESS: Chassis moved FORWARD along +X toward Blue Station!');
else
    disp('--> Chassis moved BACKWARD along -X.');
end

close_system('AGV_Warehouse_Sim', 0);
