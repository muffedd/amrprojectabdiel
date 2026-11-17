% test_torque_direction.m
evalin('base', 'run(''AGV_DataFile.m'')');
load_system('AGV_Warehouse_Sim');

% Let's test by setting Const_Zero value to 2.0 Nm on wheel 1 & 2
c1 = 'AGV_Warehouse_Sim/AGV_STEP_1_RIGID/Drive_Wheel_Assembly_STEP_1_RIGID/Const_Zero';
c2 = 'AGV_Warehouse_Sim/AGV_STEP_1_RIGID/Drive_Wheel_Assembly_STEP_2_RIGID/Const_Zero';
c3 = 'AGV_Warehouse_Sim/AGV_STEP_1_RIGID/Drive_Wheel_Assembly_STEP_3_RIGID/Const_Zero';
c4 = 'AGV_Warehouse_Sim/AGV_STEP_1_RIGID/Drive_Wheel_Assembly_STEP_4_RIGID/Const_Zero';

% Let's see current values
disp(['c1: ', get_param(c1, 'Value')]);
disp(['c2: ', get_param(c2, 'Value')]);
disp(['c3: ', get_param(c3, 'Value')]);
disp(['c4: ', get_param(c4, 'Value')]);

% Let's test wheel 1 & 2 with torque +5 Nm
set_param(c1, 'Value', '5');
set_param(c2, 'Value', '5');
simOut = sim('AGV_Warehouse_Sim', 'StopTime', '0.1');

% Let's check joint position / velocity of 6-DOF joint
disp('Sim completed with wheel 1 & 2 torque = +5 Nm.');
