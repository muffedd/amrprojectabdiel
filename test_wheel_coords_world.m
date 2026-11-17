% test_wheel_coords_world.m
clear; clc;
evalin('base', 'run(''AGV_DataFile.m'')');
load_system('AGV_Warehouse_Sim');

% Let's run a 0.01s sim and inspect wheel positions in World
% Or inspect via Transform Sensor!
% Let's add a temporary Transform Sensor between World and AGV_STEP_1_RIGID
load_system('sm_lib');
load_system('nesl_utility');

ts = 'AGV_Warehouse_Sim/Temp_Sensor';
if isempty(find_system('AGV_Warehouse_Sim', 'SearchDepth', 1, 'Name', 'Temp_Sensor'))
    add_block('sm_lib/Frames and Transforms/Transform Sensor', ts);
    set_param(ts, 'SenseXYZ', 'on', 'SenseRotationSequence', 'on', 'RotationSequence', 'ZYX');
    add_line('AGV_Warehouse_Sim', 'World/RConn1', 'Temp_Sensor/LConn1', 'autorouting', 'on');
    add_line('AGV_Warehouse_Sim', 'Transform/RConn1', 'Temp_Sensor/RConn1', 'autorouting', 'on');
end

% Also add PS-Simulink converters and To Workspace blocks
ps_xyz = 'AGV_Warehouse_Sim/Temp_PS_XYZ';
if isempty(find_system('AGV_Warehouse_Sim', 'SearchDepth', 1, 'Name', 'Temp_PS_XYZ'))
    add_block('nesl_utility/PS-Simulink Converter', ps_xyz);
    add_block('simulink/Sinks/To Workspace', 'AGV_Warehouse_Sim/Out_XYZ', 'VariableName', 'pos_out', 'SaveFormat', 'Array');
    add_line('AGV_Warehouse_Sim', 'Temp_Sensor/RConn2', 'Temp_PS_XYZ/LConn1', 'autorouting', 'on');
    add_line('AGV_Warehouse_Sim', 'Temp_PS_XYZ/1', 'Out_XYZ/1', 'autorouting', 'on');
end

ps_rot = 'AGV_Warehouse_Sim/Temp_PS_Rot';
if isempty(find_system('AGV_Warehouse_Sim', 'SearchDepth', 1, 'Name', 'Temp_PS_Rot'))
    add_block('nesl_utility/PS-Simulink Converter', ps_rot);
    add_block('simulink/Sinks/To Workspace', 'AGV_Warehouse_Sim/Out_Rot', 'VariableName', 'rot_out', 'SaveFormat', 'Array');
    add_line('AGV_Warehouse_Sim', 'Temp_Sensor/RConn3', 'Temp_PS_Rot/LConn1', 'autorouting', 'on');
    add_line('AGV_Warehouse_Sim', 'Temp_PS_Rot/1', 'Out_Rot/1', 'autorouting', 'on');
end

% Set non-zero torques to see motion:
% Let's set 2 Nm on wheels 1, 2, 3, 4
c1 = 'AGV_Warehouse_Sim/AGV_STEP_1_RIGID/Drive_Wheel_Assembly_STEP_1_RIGID/Const_Zero';
c2 = 'AGV_Warehouse_Sim/AGV_STEP_1_RIGID/Drive_Wheel_Assembly_STEP_2_RIGID/Const_Zero';
c3 = 'AGV_Warehouse_Sim/AGV_STEP_1_RIGID/Drive_Wheel_Assembly_STEP_3_RIGID/Const_Zero';
c4 = 'AGV_Warehouse_Sim/AGV_STEP_1_RIGID/Drive_Wheel_Assembly_STEP_4_RIGID/Const_Zero';

set_param(c1, 'Value', '5');
set_param(c2, 'Value', '5');
set_param(c3, 'Value', '5');
set_param(c4, 'Value', '5');

simOut = sim('AGV_Warehouse_Sim', 'StopTime', '0.2');
fprintf('Initial pos: %s\n', mat2str(simOut.pos_out(1,:), 4));
fprintf('Final pos:   %s\n', mat2str(simOut.pos_out(end,:), 4));
fprintf('Initial rot (ZYX): %s\n', mat2str(simOut.rot_out(1,:), 4));
fprintf('Final rot (ZYX):   %s\n', mat2str(simOut.rot_out(end,:), 4));

close_system('AGV_Warehouse_Sim', 0);
