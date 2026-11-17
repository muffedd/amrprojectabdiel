% check_timeseries_dim.m
clear; clc;
evalin('base', 'run(''AGV_DataFile.m'')');
load_system('AGV_Warehouse_Sim');

simOut = sim('AGV_Warehouse_Sim', 'StopTime', '0.002');
xy = simOut.xy_log.Data;
yaw = simOut.yaw_log.Data;

fprintf('Size of xy: %s\n', mat2str(size(xy)));
fprintf('Size of yaw: %s\n', mat2str(size(yaw)));

if ndims(xy) == 3
    fprintf('Step 1: X = %.4f, Y = %.4f\n', xy(1,1,1), xy(2,1,1));
    fprintf('Step 2: X = %.4f, Y = %.4f\n', xy(1,1,end), xy(2,1,end));
else
    fprintf('Step 1: X = %.4f, Y = %.4f\n', xy(1,1), xy(1,2));
end

close_system('AGV_Warehouse_Sim', 0);
