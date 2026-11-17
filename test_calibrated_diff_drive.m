% test_calibrated_diff_drive.m
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

% Let's configure the inside of AGV_STEP_1_RIGID cleanly:
% Inport 1: Torque_Left (drives DWA 1 & 2 with gain -1)
% Inport 2: Torque_Right (drives DWA 3 & 4 with gain +1)

% Disconnect any old lines from Torque_Right and Torque_Left inside AGV_STEP_1_RIGID
lines = get_param(agv, 'Lines');
for l = 1:length(lines)
    sb = lines(l).SrcBlock;
    if ~isempty(sb) && all(sb ~= -1)
        name = get_param(sb(1), 'Name');
        if contains(name, 'Torque') || contains(name, 'Gain_')
            delete_line(lines(l).Handle);
        end
    end
end

% Rename / configure Inports
if ~isempty(find_system(agv, 'SearchDepth', 1, 'Name', 'Torque_Right'))
    set_param([agv, '/Torque_Right'], 'Name', 'Inport_Right');
end
if ~isempty(find_system(agv, 'SearchDepth', 1, 'Name', 'Torque_Left'))
    set_param([agv, '/Torque_Left'], 'Name', 'Inport_Left');
end

set_param([agv, '/Inport_Left'], 'Name', 'Torque_Left', 'Port', '1');
set_param([agv, '/Inport_Right'], 'Name', 'Torque_Right', 'Port', '2');

% Add Inverter Gain for Left wheels (Gain = -1)
g_left = [agv, '/Gain_Left'];
if isempty(find_system(agv, 'SearchDepth', 1, 'Name', 'Gain_Left'))
    add_block('simulink/Math Operations/Gain', g_left, 'Gain', '-1');
else
    set_param(g_left, 'Gain', '-1');
end

% Connect Torque_Left -> Gain_Left -> DWA 1 & DWA 2
add_line(agv, 'Torque_Left/1', 'Gain_Left/1', 'autorouting', 'on');
add_line(agv, 'Gain_Left/1', 'Drive_Wheel_Assembly_STEP_1_RIGID/1', 'autorouting', 'on');
add_line(agv, 'Gain_Left/1', 'Drive_Wheel_Assembly_STEP_2_RIGID/1', 'autorouting', 'on');

% Connect Torque_Right -> DWA 3 & DWA 4
add_line(agv, 'Torque_Right/1', 'Drive_Wheel_Assembly_STEP_3_RIGID/1', 'autorouting', 'on');
add_line(agv, 'Torque_Right/1', 'Drive_Wheel_Assembly_STEP_4_RIGID/1', 'autorouting', 'on');

% Now at top level:
% Disconnect controller outputs temporarily
ph_agv = get_param(agv, 'PortHandles');
l1 = get_param(ph_agv.Inport(1), 'Line');
l2 = get_param(ph_agv.Inport(2), 'Line');
if l1 ~= -1, delete_line(l1); end
if l2 ~= -1, delete_line(l2); end

if isempty(find_system('AGV_Warehouse_Sim', 'SearchDepth', 1, 'Name', 'Test_TL'))
    add_block('simulink/Sources/Constant', 'AGV_Warehouse_Sim/Test_TL', 'Value', '0.5');
    add_block('simulink/Sources/Constant', 'AGV_Warehouse_Sim/Test_TR', 'Value', '0.5');
    add_line('AGV_Warehouse_Sim', 'Test_TL/1', 'AGV_STEP_1_RIGID/1', 'autorouting', 'on');
    add_line('AGV_Warehouse_Sim', 'Test_TR/1', 'AGV_STEP_1_RIGID/2', 'autorouting', 'on');
end

% Ensure Log_XY and Log_Yaw
if isempty(find_system('AGV_Warehouse_Sim', 'SearchDepth', 1, 'Name', 'Log_XY'))
    add_block('simulink/Sinks/To Workspace', 'AGV_Warehouse_Sim/Log_XY', 'VariableName', 'xy_log', 'SaveFormat', 'Timeseries');
    add_line('AGV_Warehouse_Sim', 'Get_XY/1', 'Log_XY/1', 'autorouting', 'on');
end
if isempty(find_system('AGV_Warehouse_Sim', 'SearchDepth', 1, 'Name', 'Log_Yaw'))
    add_block('simulink/Sinks/To Workspace', 'AGV_Warehouse_Sim/Log_Yaw', 'VariableName', 'yaw_log', 'SaveFormat', 'Timeseries');
    add_line('AGV_Warehouse_Sim', 'Get_Yaw/1', 'Log_Yaw/1', 'autorouting', 'on');
end

fprintf('=== Running Test 1: T_L = +0.5, T_R = +0.5 (0.15s) ===\n');
set_param('AGV_Warehouse_Sim/Test_TL', 'Value', '0.5');
set_param('AGV_Warehouse_Sim/Test_TR', 'Value', '0.5');
simOut1 = sim('AGV_Warehouse_Sim', 'StopTime', '0.15');
xy1 = simOut1.xy_log.Data; yaw1 = simOut1.yaw_log.Data;
if ndims(xy1) == 3, x1_0 = xy1(1,1,1); y1_0 = xy1(2,1,1); x1_end = xy1(1,1,end); y1_end = xy1(2,1,end);
else, x1_0 = xy1(1,1); y1_0 = xy1(1,2); x1_end = xy1(end,1); y1_end = xy1(end,2); end
fprintf('Test 1 Start: X=%.4f, Y=%.4f, Yaw=%.4f\n', x1_0, y1_0, yaw1(1));
fprintf('Test 1 End:   X=%.4f, Y=%.4f, Yaw=%.4f\n', x1_end, y1_end, yaw1(end));
fprintf('Test 1 Delta: dX = %+.5f m, dY = %+.5f m, dYaw = %+.5f rad\n', x1_end-x1_0, y1_end-y1_0, yaw1(end)-yaw1(1));

fprintf('\n=== Running Test 2: T_L = +0.8, T_R = +0.2 (0.15s) ===\n');
set_param('AGV_Warehouse_Sim/Test_TL', 'Value', '0.8');
set_param('AGV_Warehouse_Sim/Test_TR', 'Value', '0.2');
simOut2 = sim('AGV_Warehouse_Sim', 'StopTime', '0.15');
xy2 = simOut2.xy_log.Data; yaw2 = simOut2.yaw_log.Data;
if ndims(xy2) == 3, x2_0 = xy2(1,1,1); y2_0 = xy2(2,1,1); x2_end = xy2(1,1,end); y2_end = xy2(2,1,end);
else, x2_0 = xy2(1,1); y2_0 = xy2(1,2); x2_end = xy2(end,1); y2_end = xy2(end,2); end
fprintf('Test 2 Start: X=%.4f, Y=%.4f, Yaw=%.4f\n', x2_0, y2_0, yaw2(1));
fprintf('Test 2 End:   X=%.4f, Y=%.4f, Yaw=%.4f\n', x2_end, y2_end, yaw2(end));
fprintf('Test 2 Delta: dX = %+.5f m, dY = %+.5f m, dYaw = %+.5f rad\n', x2_end-x2_0, y2_end-y2_0, yaw2(end)-yaw2(1));

close_system('AGV_Warehouse_Sim', 0);
