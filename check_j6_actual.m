% check_j6_actual.m
clear; clc;
load_system('AGV_Warehouse_Sim');
j6 = 'AGV_Warehouse_Sim/Joint_6DOF';
fprintf('Px: %s (specify: %s)\n', get_param(j6, 'PxPositionTargetValue'), get_param(j6, 'PxPositionTargetSpecify'));
fprintf('Py: %s (specify: %s)\n', get_param(j6, 'PyPositionTargetValue'), get_param(j6, 'PyPositionTargetSpecify'));
fprintf('Pz: %s (specify: %s)\n', get_param(j6, 'PzPositionTargetValue'), get_param(j6, 'PzPositionTargetSpecify'));
close_system('AGV_Warehouse_Sim', 0);
