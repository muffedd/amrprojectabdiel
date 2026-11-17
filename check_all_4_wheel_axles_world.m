% check_all_4_wheel_axles_world.m
clear; clc;
evalin('base', 'run(''AGV_DataFile.m'')');

rot = @(ang, ax) axang2rotm([ax(:)', ang]);
R_top = rot(pi/2, [1 0 0]);

% In AGV.xml, let's find the transforms of all 4 DWAs in AGV:
% DWA 1: RT 42
% DWA 2: RT 49
% DWA 3: RT 28
% DWA 4: RT 59
% Let's verify their indices in smiData:
dwa_rt_idx = [42, 49, 28, 59];
wheel_rt_idx = [40, 47, 26, 57];
p_hub_w = [-0.1454990063668878; 0.0751741789496352; 0.2581649344177215];
z_hub_w = [0; 0; 1];

for k = 1:4
    % Transform of MW in DWA
    rt_mw = smiData.RigidTransform(wheel_rt_idx(k));
    R_mw = rot(rt_mw.angle, rt_mw.axis);
    z_hub_dwa = R_mw * z_hub_w;
    
    % Transform of DWA in AGV
    rt_dwa = smiData.RigidTransform(dwa_rt_idx(k));
    R_dwa = rot(rt_dwa.angle, rt_dwa.axis);
    
    % Axle in AGV
    z_agv = R_dwa * z_hub_dwa;
    
    % Axle in World (when AGV is at yaw = 0)
    z_world = R_top * z_agv;
    
    fprintf('Wheel %d: Axle in AGV = [%.3f, %.3f, %.3f] -> Axle in World = [%.3f, %.3f, %.3f]\n', ...
        k, z_agv(1), z_agv(2), z_agv(3), z_world(1), z_world(2), z_world(3));
end
