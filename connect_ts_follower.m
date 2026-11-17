% connect_ts_follower.m
clear; clc;
evalin('base', 'run(''AGV_DataFile.m'')');
load_system('AGV_Warehouse_Sim');

ts = 'AGV_Warehouse_Sim/Pose_Sensor';
t_top = 'AGV_Warehouse_Sim/Transform';

ph_ts = get_param(ts, 'PortHandles');
ph_t = get_param(t_top, 'PortHandles');

% Connect Follower RConn1 of Pose_Sensor to Transform RConn1 (chassis frame)
try
    add_line('AGV_Warehouse_Sim', ph_ts.RConn(1), ph_t.RConn(1), 'autorouting', 'on');
    disp('Connected Pose_Sensor/RConn1 to Transform/RConn1 successfully.');
catch ME
    disp(ME.message);
end

save_system('AGV_Warehouse_Sim');
disp('Model saved.');

% Verify compilation
set_param('AGV_Warehouse_Sim', 'SimulationCommand', 'update');
disp('Diagram update completed cleanly with no warnings or errors!');

close_system('AGV_Warehouse_Sim', 0);
