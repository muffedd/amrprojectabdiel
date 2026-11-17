% test_wheel_directions.m
evalin('base', 'run(''AGV_DataFile.m'')');
load_system('AGV_Warehouse_Sim');

% Let's see the 4 DWA paths
dwa1 = 'AGV_Warehouse_Sim/AGV_STEP_1_RIGID/Drive_Wheel_Assembly_STEP_1_RIGID';
dwa2 = 'AGV_Warehouse_Sim/AGV_STEP_1_RIGID/Drive_Wheel_Assembly_STEP_2_RIGID';
dwa3 = 'AGV_Warehouse_Sim/AGV_STEP_1_RIGID/Drive_Wheel_Assembly_STEP_3_RIGID';
dwa4 = 'AGV_Warehouse_Sim/AGV_STEP_1_RIGID/Drive_Wheel_Assembly_STEP_4_RIGID';

disp(['DWA 1 (Rear Right):  ', dwa1]);
disp(['DWA 2 (Front Right): ', dwa2]);
disp(['DWA 3 (Front Left):  ', dwa3]);
disp(['DWA 4 (Rear Left):   ', dwa4]);
