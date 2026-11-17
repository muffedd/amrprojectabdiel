% test_forward_torque_direction.m
clear; clc;
evalin('base', 'run(''AGV_DataFile.m'')');
load_system('AGV_Warehouse_Sim');

% In AGV_STEP_1_RIGID:
% Port 1 is Torque_Right (DWA 1 & 2)
% Port 2 is Torque_Left (DWA 3 & 4)
% Let's disconnect the controller temporarily and apply constant torque +2 to both!
% First, let's see current lines to AGV_STEP_1_RIGID
agv = 'AGV_Warehouse_Sim/AGV_STEP_1_RIGID';
c_src = 'AGV_Warehouse_Sim/Test_Const_Torque';
if isempty(find_system('AGV_Warehouse_Sim', 'SearchDepth', 1, 'Name', 'Test_Const_Torque'))
    add_block('simulink/Sources/Constant', c_src, 'Value', '2');
end

% Connect to Inport 1 and 2
% Delete old lines to Inport 1 and 2 of AGV_STEP_1_RIGID
lines = get_param('AGV_Warehouse_Sim', 'Lines');
for l = 1:length(lines)
    db = lines(l).DstBlock;
    if ~isempty(db) && all(db ~= -1) && strcmp(get_param(db(1), 'Name'), 'AGV_STEP_1_RIGID')
        delete_line(lines(l).Handle);
    end
end

add_line('AGV_Warehouse_Sim', 'Test_Const_Torque/1', 'AGV_STEP_1_RIGID/1', 'autorouting', 'on');
add_line('AGV_Warehouse_Sim', 'Test_Const_Torque/1', 'AGV_STEP_1_RIGID/2', 'autorouting', 'on');

% Add To Workspace logger for Get_XY
log_blk = 'AGV_Warehouse_Sim/Test_Log_XY';
if isempty(find_system('AGV_Warehouse_Sim', 'SearchDepth', 1, 'Name', 'Test_Log_XY'))
    add_block('simulink/Sinks/To Workspace', log_blk, 'VariableName', 'test_xy', 'SaveFormat', 'Array');
    add_line('AGV_Warehouse_Sim', 'Get_XY/1', 'Test_Log_XY/1', 'autorouting', 'on');
end

% Run 0.05 s test
simOut = sim('AGV_Warehouse_Sim', 'StopTime', '0.05');

xy = simOut.test_xy;
fprintf('Start pos: X = %.5f, Y = %.5f\n', xy(1,1), xy(1,2));
fprintf('End   pos: X = %.5f, Y = %.5f\n', xy(end,1), xy(end,2));
fprintf('Delta X:   %.5f m\n', xy(end,1) - xy(1,1));
fprintf('Delta Y:   %.5f m\n', xy(end,2) - xy(1,2));

if (xy(end,1) - xy(1,1)) > 0
    fprintf('Motion direction is POSITIVE X (+X)\n');
else
    fprintf('Motion direction is NEGATIVE X (-X)\n');
end

close_system('AGV_Warehouse_Sim', 0);
