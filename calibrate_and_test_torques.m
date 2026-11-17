% calibrate_and_test_torques.m
clear; clc;
evalin('base', 'run(''AGV_DataFile.m'')');
load_system('AGV_Warehouse_Sim');

% Ensure Floor is 30m x 30m
set_param('AGV_Warehouse_Sim/Warehouse_Floor', 'BrickDimensions', '[30 30 0.1]');

% Spawn pose
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
ph_agv = get_param(agv, 'PortHandles');
l1 = get_param(ph_agv.Inport(1), 'Line');
l2 = get_param(ph_agv.Inport(2), 'Line');
if l1 ~= -1, delete_line(l1); end
if l2 ~= -1, delete_line(l2); end

% Add test source blocks if not present
if isempty(find_system('AGV_Warehouse_Sim', 'SearchDepth', 1, 'Name', 'Test_TR'))
    add_block('simulink/Sources/Constant', 'AGV_Warehouse_Sim/Test_TR', 'Value', '0.5');
    add_block('simulink/Sources/Constant', 'AGV_Warehouse_Sim/Test_TL', 'Value', '0.5');
    add_line('AGV_Warehouse_Sim', 'Test_TR/1', 'AGV_STEP_1_RIGID/1', 'autorouting', 'on');
    add_line('AGV_Warehouse_Sim', 'Test_TL/1', 'AGV_STEP_1_RIGID/2', 'autorouting', 'on');
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

test_cases = [ ...
    0.5,  0.5; ...  % Test 1: User requested TL=+0.5, TR=+0.5
   -0.5, -0.5; ...  % Test 1b: TL=-0.5, TR=-0.5
    0.8,  0.2; ...  % Test 2: User requested TL=+0.8, TR=+0.2
    0.2,  0.8; ...  % Test 2b: TL=+0.2, TR=+0.8
   -0.8, -0.2; ...  % Test 2c: TL=-0.8, TR=-0.2
];

for tc = 1:size(test_cases, 1)
    tl = test_cases(tc, 1);
    tr = test_cases(tc, 2);
    set_param('AGV_Warehouse_Sim/Test_TL', 'Value', num2str(tl));
    set_param('AGV_Warehouse_Sim/Test_TR', 'Value', num2str(tr));
    
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
    
    fprintf('TC %d: TL=%+.2f, TR=%+.2f -> dX = %+.5f m, dY = %+.5f m, dYaw = %+.5f rad\n', ...
        tc, tl, tr, x_end - x0, y_end - y0, psi_end - psi0);
end

close_system('AGV_Warehouse_Sim', 0);
