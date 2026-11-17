% check_exact_wheel_positions.m
clear; clc;
evalin('base', 'run(''AGV_DataFile.m'')');

% Let's see the wheel translations and rotations from AGV_DataFile / smiData
% In AGV_Aligned_Plant / AGV_Warehouse_Sim:
% Top transform has:
% RotationMethod = ArbitraryAxis, [1 0 0], pi/2.
rot = @(ang, ax) axang2rotm([ax(:)', ang]);
R_top = rot(pi/2, [1 0 0]);

wheel_rt_idx = [40, 47, 26, 57];
for k = 1:4
    idx = wheel_rt_idx(k);
    rt = smiData.RigidTransform(idx);
    R_w = rot(rt.angle, rt.axis);
    t_w = rt.translation(:);
    
    % In World coordinates (when Joint_6DOF = [0, 0, 0]):
    % Top transform maps CAD vector v to: R_top * v + t_top
    t_world = R_top * t_w;
    fprintf('Wheel %d (CAD idx %d): CAD = [%.4f, %.4f, %.4f] -> World = [%.4f, %.4f, %.4f]\n', ...
        k, idx, t_w(1), t_w(2), t_w(3), t_world(1), t_world(2), t_world(3));
end

% Let's also check the CAD positions of all solid parts in smiData!
fprintf('\nAll solid transforms in smiData (sample):\n');
for i = 1:min(10, length(smiData.RigidTransform))
    t = smiData.RigidTransform(i).translation(:);
    tw = R_top * t;
    fprintf('RT %d: CAD [%.3f, %.3f, %.3f] -> World [%.3f, %.3f, %.3f]\n', i, t(1), t(2), t(3), tw(1), tw(2), tw(3));
end
