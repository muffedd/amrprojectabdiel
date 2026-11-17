% test_joint_transforms.m
evalin('base', 'run(''AGV_DataFile.m'')');

rot = @(ang, ax) axang2rotm([ax(:)', ang]);

% Original Transform4 for DWA 1:
rt4 = smiData.RigidTransform(40);
R4 = rot(rt4.angle, rt4.axis);
t4 = rt4.translation(:);
T4 = [R4, t4; 0 0 0 1];

% Wheel hub point in wheel solid frame:
p_hub_w = [-0.1454990063668878; 0.0751741789496352; 0.2581649344177215];
z_hub_w = [0; 0; 1];

% In DWA frame:
p_hub_dwa = R4 * p_hub_w + t4;
z_hub_dwa = R4 * z_hub_w;

disp('p_hub_dwa:'); disp(p_hub_dwa');
disp('z_hub_dwa:'); disp(z_hub_dwa');

% We want a joint frame J at p_hub_dwa with Z_J = z_hub_dwa (or spin axis).
% In wheel solid frame, J has origin at p_hub_w and Z_J = z_hub_w = [0; 0; 1].
% If joint J has the same orientation as the wheel solid frame (since Z_w is ALREADY [0; 0; 1]!):
% Then T_{w -> J} is simply translation by p_hub_w, with R = I!
% So T_{J -> w} is translation by -p_hub_w, with R = I!
R_J_w = eye(3);
t_J_w = -p_hub_w;
T_J_w = [R_J_w, t_J_w; 0 0 0 1];

% Then from DWA to J:
% T_{dwa -> J} = T4 * inv(T_J_w) = T4 * [eye(3), p_hub_w; 0 0 0 1]
T_dwa_J = T4 * [eye(3), p_hub_w; 0 0 0 1];
R_dwa_J = T_dwa_J(1:3, 1:3);
t_dwa_J = T_dwa_J(1:3, 4);

disp('t_dwa_J:'); disp(t_dwa_J');
disp('R_dwa_J:'); disp(R_dwa_J);
disp('Does R_dwa_J column 3 match z_hub_dwa?');
disp(R_dwa_J(:, 3)');

% Check equivalence when joint angle is 0:
T_total = T_dwa_J * T_J_w;
diff_T = max(abs(T_total(:) - T4(:)));
disp(['Max difference between T_total and T4: ', num2str(diff_T)]);
