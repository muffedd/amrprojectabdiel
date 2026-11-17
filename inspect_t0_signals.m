% inspect_t0_signals.m
clear; clc;
evalin('base', 'run(''AGV_DataFile.m'')');
load_system('AGV_Warehouse_Sim');

if isempty(find_system('AGV_Warehouse_Sim', 'SearchDepth', 1, 'Name', 'Log_XY'))
    add_block('simulink/Sinks/To Workspace', 'AGV_Warehouse_Sim/Log_XY', 'VariableName', 'xy_log', 'SaveFormat', 'Timeseries');
    add_line('AGV_Warehouse_Sim', 'Get_XY/1', 'Log_XY/1', 'autorouting', 'on');
end

if isempty(find_system('AGV_Warehouse_Sim', 'SearchDepth', 1, 'Name', 'Log_Yaw'))
    add_block('simulink/Sinks/To Workspace', 'AGV_Warehouse_Sim/Log_Yaw', 'VariableName', 'yaw_log', 'SaveFormat', 'Timeseries');
    add_line('AGV_Warehouse_Sim', 'Get_Yaw/1', 'Log_Yaw/1', 'autorouting', 'on');
end

simOut = sim('AGV_Warehouse_Sim', 'StopTime', '0.005');
xy = simOut.xy_log.Data;
yaw = simOut.yaw_log.Data;

fprintf('Sensor reported at t=0:\n');
fprintf('  X = %.4f m\n', xy(1,1));
fprintf('  Y = %.4f m\n', xy(1,2));
fprintf('  Yaw = %.4f rad (%.2f deg)\n', yaw(1), yaw(1)*180/pi);

close_system('AGV_Warehouse_Sim', 0);
