% test_wheel_actuation.m
clear; clc;
evalin('base', 'run(''AGV_DataFile.m'')');
load_system('AGV_Warehouse_Sim');

% Let's see what the initial pose of Joint_6DOF is
j6 = 'AGV_Warehouse_Sim/Joint_6DOF';
set_param(j6, 'PxPositionTargetSpecify', 'on', 'PxPositionTargetValue', '-2.5', 'PxPositionTargetPriority', 'High');
set_param(j6, 'PyPositionTargetSpecify', 'on', 'PyPositionTargetValue', '-3.0', 'PyPositionTargetPriority', 'High');

% Let's add Transform Sensor if not present
load_system('sm_lib');
load_system('nesl_utility');
load_system('simulink');

ts = 'AGV_Warehouse_Sim/Transform_Sensor';
if isempty(find_system('AGV_Warehouse_Sim', 'SearchDepth', 1, 'Name', 'Transform_Sensor'))
    add_block('sm_lib/Frames and Transforms/Transform Sensor', ts);
    set_param(ts, 'SenseXYZ', 'on', 'SenseRotationSequence', 'on', 'RotationSequence', 'ZYX');
    add_line('AGV_Warehouse_Sim', 'World/RConn1', 'Transform_Sensor/LConn1', 'autorouting', 'on');
    add_line('AGV_Warehouse_Sim', 'Transform/RConn1', 'Transform_Sensor/RConn1', 'autorouting', 'on');
end

% Check lines for Out_XYZ
if isempty(find_system('AGV_Warehouse_Sim', 'SearchDepth', 1, 'Name', 'Out_XYZ'))
    add_block('nesl_utility/PS-Simulink Converter', 'AGV_Warehouse_Sim/PS_Sens_XYZ');
    add_block('simulink/Sinks/To Workspace', 'AGV_Warehouse_Sim/Out_XYZ', 'VariableName', 'pos_out', 'SaveFormat', 'Timeseries');
    add_line('AGV_Warehouse_Sim', 'Transform_Sensor/RConn2', 'PS_Sens_XYZ/LConn1', 'autorouting', 'on');
    add_line('AGV_Warehouse_Sim', 'PS_Sens_XYZ/1', 'Out_XYZ/1', 'autorouting', 'on');
end

if isempty(find_system('AGV_Warehouse_Sim', 'SearchDepth', 1, 'Name', 'Out_Rot'))
    add_block('nesl_utility/PS-Simulink Converter', 'AGV_Warehouse_Sim/PS_Sens_Rot');
    add_block('simulink/Sinks/To Workspace', 'AGV_Warehouse_Sim/Out_Rot', 'VariableName', 'rot_out', 'SaveFormat', 'Timeseries');
    add_line('AGV_Warehouse_Sim', 'Transform_Sensor/RConn3', 'PS_Sens_Rot/LConn1', 'autorouting', 'on');
    add_line('AGV_Warehouse_Sim', 'PS_Sens_Rot/1', 'Out_Rot/1', 'autorouting', 'on');
end

% Set wheel torques to test forward motion
% DWA 1 & 2 (Right): torque = +3 Nm
% DWA 3 & 4 (Left):  torque = +3 Nm (or test both + and -)
c1 = 'AGV_Warehouse_Sim/AGV_STEP_1_RIGID/Drive_Wheel_Assembly_STEP_1_RIGID/Const_Zero';
c2 = 'AGV_Warehouse_Sim/AGV_STEP_1_RIGID/Drive_Wheel_Assembly_STEP_2_RIGID/Const_Zero';
c3 = 'AGV_Warehouse_Sim/AGV_STEP_1_RIGID/Drive_Wheel_Assembly_STEP_3_RIGID/Const_Zero';
c4 = 'AGV_Warehouse_Sim/AGV_STEP_1_RIGID/Drive_Wheel_Assembly_STEP_4_RIGID/Const_Zero';

% Let's test with 5 Nm on right wheels and 5 Nm on left wheels
set_param(c1, 'Value', '5');
set_param(c2, 'Value', '5');
set_param(c3, 'Value', '5');
set_param(c4, 'Value', '5');

simOut = sim('AGV_Warehouse_Sim', 'StopTime', '0.2');

p_data = simOut.pos_out.Data;
r_data = simOut.rot_out.Data;
fprintf('Start pos: X=%.4f, Y=%.4f, Z=%.4f\n', p_data(1,1), p_data(1,2), p_data(1,3));
fprintf('End   pos: X=%.4f, Y=%.4f, Z=%.4f\n', p_data(end,1), p_data(end,2), p_data(end,3));
fprintf('Start yaw: %.4f deg, End yaw: %.4f deg\n', r_data(1,1)*180/pi, r_data(end,1)*180/pi);
fprintf('Delta X: %.4f m, Delta Y: %.4f m\n', p_data(end,1) - p_data(1,1), p_data(end,2) - p_data(1,2));

close_system('AGV_Warehouse_Sim', 0);
