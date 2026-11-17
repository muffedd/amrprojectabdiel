% check_robot_center_and_wheels.m
clear; clc;
evalin('base', 'run(''AGV_DataFile.m'')');
load_system('AGV_Warehouse_Sim');

% Let's run a 0.001s test simulation and inspect the logged position
% of the 4 wheels and the chassis!
% In AGV_Warehouse_Sim:
% We have Pose_Sensor connected to Transform/RConn1.
% Let's see what Pose_Sensor outputs at t=0 when Px = -2.5, Py = -3.0!
simOut = sim('AGV_Warehouse_Sim', 'StopTime', '0.002');
p = simOut.pos_out.Data;
r = simOut.rot_out.Data;
fprintf('Chassis Pose at t=0: X=%.4f, Y=%.4f, Z=%.4f\n', p(1,1), p(1,2), p(1,3));
fprintf('Chassis Yaw at t=0:  %.4f rad (%.2f deg)\n', r(1,1), r(1,1)*180/pi);

close_system('AGV_Warehouse_Sim', 0);
