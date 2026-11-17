% test_forward_differential_motion.m
clear; clc;
evalin('base', 'run(''AGV_DataFile.m'')');
load_system('AGV_Warehouse_Sim');

% Floor 30m x 30m
set_param('AGV_Warehouse_Sim/Warehouse_Floor', 'BrickDimensions', '[30 30 0.1]');

% Initial pose: X = -2.0, Y = -3.0, yaw = 180 deg
j6 = 'AGV_Warehouse_Sim/Joint_6DOF';
set_param(j6, 'PxPositionTargetSpecify', 'on', 'PxPositionTargetValue', '-2.0', 'PxPositionTargetPriority', 'High');
set_param(j6, 'PyPositionTargetSpecify', 'on', 'PyPositionTargetValue', '-3.0', 'PyPositionTargetPriority', 'High');
set_param(j6, 'SphPositionTargetSpecify', 'on', ...
              'SphPositionTargetPriority', 'High', ...
              'SphPositionTargetRotationMethod', 'StandardAxis', ...
              'SphPositionTargetRotationStandardAxis', '+Z', ...
              'SphPositionTargetRotationAngle', '180', ...
              'SphPositionTargetRotationAngleUnits', 'deg');

% Disconnect controller outputs and connect:
% Right wheels (Inport 1): +5 Nm
% Left wheels  (Inport 2): -5 Nm
% Delete lines to AGV_STEP_1_RIGID Inports 1 and 2
agv = 'AGV_Warehouse_Sim/AGV_STEP_1_RIGID';
lines = get_param('AGV_Warehouse_Sim', 'Lines');
for l = 1:length(lines)
    db = lines(l).DstBlock;
    if ~isempty(db) && all(db ~= -1) && strcmp(get_param(db(1), 'Name'), 'AGV_STEP_1_RIGID')
        delete_line(lines(l).Handle);
    end
end

% Add constant sources
if isempty(find_system('AGV_Warehouse_Sim', 'SearchDepth', 1, 'Name', 'Const_R'))
    add_block('simulink/Sources/Constant', 'AGV_Warehouse_Sim/Const_R', 'Value', '5');
    add_block('simulink/Sources/Constant', 'AGV_Warehouse_Sim/Const_L', 'Value', '-5');
end
add_line('AGV_Warehouse_Sim', 'Const_R/1', 'AGV_STEP_1_RIGID/1', 'autorouting', 'on');
add_line('AGV_Warehouse_Sim', 'Const_L/1', 'AGV_STEP_1_RIGID/2', 'autorouting', 'on');

% Add To Workspace logger for Get_XY
if isempty(find_system('AGV_Warehouse_Sim', 'SearchDepth', 1, 'Name', 'Test_Pos'))
    add_block('simulink/Sinks/To Workspace', 'AGV_Warehouse_Sim/Test_Pos', 'VariableName', 'p_test', 'SaveFormat', 'Array');
    add_line('AGV_Warehouse_Sim', 'Get_XY/1', 'Test_Pos/1', 'autorouting', 'on');
end

% Run 0.05s test
simOut = sim('AGV_Warehouse_Sim', 'StopTime', '0.05');

p = simOut.p_test;
fprintf('Array size of p: %s\n', mat2str(size(p)));
if size(p, 1) == 2
    x_start = p(1,1); y_start = p(2,1);
    x_end = p(1,end); y_end = p(2,end);
else
    x_start = p(1,1); y_start = p(1,2);
    x_end = p(end,1); y_end = p(end,2);
end

fprintf('Start: X = %.5f, Y = %.5f\n', x_start, y_start);
fprintf('End:   X = %.5f, Y = %.5f\n', x_end, y_end);
fprintf('Delta X: %.5f m\n', x_end - x_start);
fprintf('Delta Y: %.5f m\n', y_end - y_start);

if (x_end - x_start) > 0
    disp('--> SUCCESS: CHASSIS MOVES FORWARD ALONG +X TOWARDS BLUE PALLET STATION!');
else
    disp('--> Still moving backward.');
end

close_system('AGV_Warehouse_Sim', 0);
