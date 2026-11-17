% inspect_wheel_axles.m
clear; clc;
evalin('base', 'run(''AGV_DataFile.m'')');
load_system('AGV_Warehouse_Sim');

rot = @(ang, ax) axang2rotm([ax(:)', ang]);
for k = 1:4
    dwa = sprintf('AGV_Warehouse_Sim/AGV_STEP_1_RIGID/Drive_Wheel_Assembly_STEP_%d_RIGID', k);
    t4 = [dwa, '/Transform4'];
    ax = eval(get_param(t4, 'RotationArbitraryAxis'));
    ang = eval(get_param(t4, 'RotationAngle'));
    R = rot(ang, ax);
    % In Simscape Multibody Revolute Joint, the rotation axle is the Z-axis of the Base port (LConn1)!
    % Let's see what the Z-axis of the base frame is in CAD / chassis frame:
    z_axle = R * [0; 0; 1];
    fprintf('DWA %d axle (in chassis frame): [%.4f, %.4f, %.4f]\n', k, z_axle(1), z_axle(2), z_axle(3));
end

close_system('AGV_Warehouse_Sim', 0);
