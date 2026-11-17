% test_torque_and_heading_motion.m
clear; clc;
evalin('base', 'run(''AGV_DataFile.m'')');
load_system('AGV_Warehouse_Sim');

% First, expand Warehouse_Floor to 30m x 30m
set_param('AGV_Warehouse_Sim/Warehouse_Floor', 'BrickDimensions', '[30 30 0.1]');

% Set Joint_6DOF initial position:
% Center on bottom track (Y = -3.0 m) before Blue station (X = -2.0 m)
j6 = 'AGV_Warehouse_Sim/Joint_6DOF';
set_param(j6, 'PxPositionTargetSpecify', 'on', 'PxPositionTargetValue', '-2.0', 'PxPositionTargetPriority', 'High');
set_param(j6, 'PyPositionTargetSpecify', 'on', 'PyPositionTargetValue', '-3.0', 'PyPositionTargetPriority', 'High');
set_param(j6, 'SphPositionTargetSpecify', 'on', ...
              'SphPositionTargetPriority', 'High', ...
              'SphPositionTargetRotationMethod', 'StandardAxis', ...
              'SphPositionTargetRotationStandardAxis', '+Z', ...
              'SphPositionTargetRotationAngle', '180', ...
              'SphPositionTargetRotationAngleUnits', 'deg');

% Let's see what happens if we apply torque:
% In AGV_Warehouse_Sim, Line_Tracking_Controller provides tau_L and tau_R.
% In Line_Tracking_Controller:
% Let's test with tau_drive = +2 (or -2)
% Let's run 0.05 s test
simOut = sim('AGV_Warehouse_Sim', 'StopTime', '0.05');

% Read position from To Workspace Out_LatError or log
try
    % Let's see how much it moved
    disp('0.05s test completed.');
catch ME
    disp(ME.message);
end

close_system('AGV_Warehouse_Sim', 0);
