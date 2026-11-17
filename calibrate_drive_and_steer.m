% calibrate_drive_and_steer.m
clear; clc;
evalin('base', 'run(''AGV_DataFile.m'')');
load_system('AGV_Warehouse_Sim');

agv = 'AGV_Warehouse_Sim/AGV_STEP_1_RIGID';

% Let's see what is connected to AGV_STEP_1_RIGID Inports 1 and 2
ph_agv = get_param(agv, 'PortHandles');
line1 = get_param(ph_agv.Inport(1), 'Line');
line2 = get_param(ph_agv.Inport(2), 'Line');
if line1 ~= -1, delete_line(line1); end
if line2 ~= -1, delete_line(line2); end

% Add test source blocks
if isempty(find_system('AGV_Warehouse_Sim', 'SearchDepth', 1, 'Name', 'Cal_TL'))
    add_block('simulink/Sources/Constant', 'AGV_Warehouse_Sim/Cal_TR', 'Value', '0.5');
    add_block('simulink/Sources/Constant', 'AGV_Warehouse_Sim/Cal_TL', 'Value', '0.5');
    add_line('AGV_Warehouse_Sim', 'Cal_TR/1', 'AGV_STEP_1_RIGID/1', 'autorouting', 'on');
    add_line('AGV_Warehouse_Sim', 'Cal_TL/1', 'AGV_STEP_1_RIGID/2', 'autorouting', 'on');
end

% Ensure Log_XY and Log_Yaw exist
if isempty(find_system('AGV_Warehouse_Sim', 'SearchDepth', 1, 'Name', 'Log_XY'))
    add_block('simulink/Sinks/To Workspace', 'AGV_Warehouse_Sim/Log_XY', 'VariableName', 'xy_log', 'SaveFormat', 'Timeseries');
    add_line('AGV_Warehouse_Sim', 'Get_XY/1', 'Log_XY/1', 'autorouting', 'on');
end
if isempty(find_system('AGV_Warehouse_Sim', 'SearchDepth', 1, 'Name', 'Log_Yaw'))
    add_block('simulink/Sinks/To Workspace', 'AGV_Warehouse_Sim/Log_Yaw', 'VariableName', 'yaw_log', 'SaveFormat', 'Timeseries');
    add_line('AGV_Warehouse_Sim', 'Get_Yaw/1', 'Log_Yaw/1', 'autorouting', 'on');
end

disp('=== Test 1: T_L = +0.5, T_R = +0.5 (StopTime = 0.15s) ===');
set_param('AGV_Warehouse_Sim/Cal_TR', 'Value', '0.5');
set_param('AGV_Warehouse_Sim/Cal_TL', 'Value', '0.5');

simOut1 = sim('AGV_Warehouse_Sim', 'StopTime', '0.15');
xy1 = simOut1.xy_log.Data;
yaw1 = simOut1.yaw_log.Data;

if ndims(xy1) == 3
    x1_0 = xy1(1,1,1); y1_0 = xy1(2,1,1);
    x1_end = xy1(1,1,end); y1_end = xy1(2,1,end);
else
    x1_0 = xy1(1,1); y1_0 = xy1(1,2);
    x1_end = xy1(end,1); y1_end = xy1(end,2);
end
psi1_0 = yaw1(1); psi1_end = yaw1(end);

fprintf('Test 1 Start: X=%.4f, Y=%.4f, Yaw=%.4f rad (%.2f deg)\n', x1_0, y1_0, psi1_0, psi1_0*180/pi);
fprintf('Test 1 End:   X=%.4f, Y=%.4f, Yaw=%.4f rad (%.2f deg)\n', x1_end, y1_end, psi1_end, psi1_end*180/pi);
fprintf('Test 1 Delta: dX = %+.4f m, dY = %+.4f m, dYaw = %+.4f rad\n', ...
    x1_end - x1_0, y1_end - y1_0, psi1_end - psi1_0);

disp('=== Test 2: T_L = +0.8, T_R = +0.2 (StopTime = 0.15s) ===');
set_param('AGV_Warehouse_Sim/Cal_TR', 'Value', '0.2');
set_param('AGV_Warehouse_Sim/Cal_TL', 'Value', '0.8');

simOut2 = sim('AGV_Warehouse_Sim', 'StopTime', '0.15');
xy2 = simOut2.xy_log.Data;
yaw2 = simOut2.yaw_log.Data;

if ndims(xy2) == 3
    x2_0 = xy2(1,1,1); y2_0 = xy2(2,1,1);
    x2_end = xy2(1,1,end); y2_end = xy2(2,1,end);
else
    x2_0 = xy2(1,1); y2_0 = xy2(1,2);
    x2_end = xy2(end,1); y2_end = xy2(end,2);
end
psi2_0 = yaw2(1); psi2_end = yaw2(end);

fprintf('Test 2 Start: X=%.4f, Y=%.4f, Yaw=%.4f rad (%.2f deg)\n', x2_0, y2_0, psi2_0, psi2_0*180/pi);
fprintf('Test 2 End:   X=%.4f, Y=%.4f, Yaw=%.4f rad (%.2f deg)\n', x2_end, y2_end, psi2_end, psi2_end*180/pi);
fprintf('Test 2 Delta: dX = %+.4f m, dY = %+.4f m, dYaw = %+.4f rad\n', ...
    x2_end - x2_0, y2_end - y2_0, psi2_end - psi2_0);

close_system('AGV_Warehouse_Sim', 0);
