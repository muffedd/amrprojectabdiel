% calc_all_wheels.m
evalin('base', 'run(''AGV_DataFile.m'')');

rot = @(ang, ax) axang2rotm([ax(:)', ang]);

% Wheel local bore axis and point:
p_bore = [-0.1454990063668878; 0.0751741789496352; 0.2581649344177215];
z_bore = [0; 0; 1];

% IDs of wheel transforms in smiData:
% DWA 1: 40, DWA in AGV: 42
% DWA 2: 47, DWA in AGV: 49
% DWA 3: 26, DWA in AGV: 28
% DWA 4: 57, DWA in AGV: 59

wheel_rt_idx = [40, 47, 26, 57];
dwa_rt_idx   = [42, 49, 28, 59];

for i = 1:4
    rt_w = smiData.RigidTransform(wheel_rt_idx(i));
    rt_d = smiData.RigidTransform(dwa_rt_idx(i));
    
    R_w = rot(rt_w.angle, rt_w.axis);
    t_w = rt_w.translation(:);
    
    R_d = rot(rt_d.angle, rt_d.axis);
    t_d = rt_d.translation(:);
    
    p_dwa = R_w * p_bore + t_w;
    z_dwa = R_w * z_bore;
    
    p_agv = R_d * p_dwa + t_d;
    z_agv = R_d * z_dwa;
    
    fprintf('Wheel %d (DWA %d):\n', i, i);
    fprintf('  In DWA: p = [%.4f, %.4f, %.4f], z_axis = [%.4f, %.4f, %.4f]\n', p_dwa(1), p_dwa(2), p_dwa(3), z_dwa(1), z_dwa(2), z_dwa(3));
    fprintf('  In AGV: p = [%.4f, %.4f, %.4f], z_axis = [%.4f, %.4f, %.4f]\n', p_agv(1), p_agv(2), p_agv(3), z_agv(1), z_agv(2), z_agv(3));
end
