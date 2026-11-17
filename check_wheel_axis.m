% check_wheel_axis.m
evalin('base', 'run(''AGV_DataFile.m'')');

% Function to compute rotation matrix from angle and axis
rot = @(ang, ax) axang2rotm([ax(:)', ang]);

% DWA 1:
% smiData.RigidTransform(40): Mecanum Wheel in DWA 1
R_mw_dwa = rot(smiData.RigidTransform(40).angle, smiData.RigidTransform(40).axis);
t_mw_dwa = smiData.RigidTransform(40).translation(:);

disp('R_mw_dwa:');
disp(R_mw_dwa);
disp('t_mw_dwa:');
disp(t_mw_dwa');

% The wheel file solid is Mecanum Wheel.STEP
% What is the wheel spin axis in the STEP file local coordinates?
% Let's test [1; 0; 0], [0; 1; 0], [0; 0; 1] transformed by R_mw_dwa:
disp('R_mw_dwa * [1; 0; 0]:'); disp((R_mw_dwa * [1; 0; 0])');
disp('R_mw_dwa * [0; 1; 0]:'); disp((R_mw_dwa * [0; 1; 0])');
disp('R_mw_dwa * [0; 0; 1]:'); disp((R_mw_dwa * [0; 0; 1])');

% DWA 1 in AGV:
R_dwa_agv = rot(smiData.RigidTransform(42).angle, smiData.RigidTransform(42).axis);
t_dwa_agv = smiData.RigidTransform(42).translation(:);
disp('R_dwa_agv:');
disp(R_dwa_agv);
disp('t_dwa_agv:');
disp(t_dwa_agv');
