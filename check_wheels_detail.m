% check_wheels_detail.m
clear; clc;
evalin('base', 'run(''AGV_DataFile.m'')');

rot = @(ang, ax) axang2rotm([ax(:)', ang]);
R_top = rot(pi/2, [1 0 0]);

dwa_rt_idx = [42, 49, 28, 59];
wheel_rt_idx = [40, 47, 26, 57];

for k = 1:4
    rt_dwa = smiData.RigidTransform(dwa_rt_idx(k));
    R_dwa = rot(rt_dwa.angle, rt_dwa.axis);
    t_dwa = rt_dwa.translation(:);
    
    rt_mw = smiData.RigidTransform(wheel_rt_idx(k));
    R_mw = rot(rt_mw.angle, rt_mw.axis);
    t_mw = rt_mw.translation(:);
    
    % Total position in AGV
    p_agv = t_dwa + R_dwa * t_mw;
    p_world_yaw0 = R_top * p_agv;
    % When yaw = 180 deg (rotation by 180 around Z_world):
    R_yaw180 = rot(pi, [0 0 1]);
    p_world = R_yaw180 * p_world_yaw0 + [-2; -3; 0];
    
    % Wheel rotation axis in AGV (Revolute joint axis is along Z of follower)
    % Let's see the axle orientation in World
    z_axle_agv = R_dwa * R_mw * [0; 0; 1];
    z_axle_world = R_yaw180 * R_top * z_axle_agv;
    
    fprintf('Wheel %d: World Pos = [%.3f, %.3f, %.3f], Axle in World = [%.3f, %.3f, %.3f]\n', ...
        k, p_world(1), p_world(2), p_world(3), z_axle_world(1), z_axle_world(2), z_axle_world(3));
end
