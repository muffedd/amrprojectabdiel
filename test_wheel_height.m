% test_wheel_height.m
evalin('base', 'run(''AGV_DataFile.m'')');
load_system('AGV_Aligned_Plant');

% In AGV_Aligned_Plant, let's find the path to Mecanum_Wheel_STEP_1_RIGID in DWA 1:
dwa1 = 'AGV_Aligned_Plant/AGV_STEP_1_RIGID/Drive_Wheel_Assembly_STEP_1_RIGID';
mw1_solid = [dwa1, '/Mecanum_Wheel_STEP_1_RIGID/Solid'];

% Let's see what blocks are at top level
disp('Top level blocks:');
blks = find_system('AGV_Aligned_Plant', 'SearchDepth', 1);
disp(blks);

% Let's run a 0.001s simulation:
simOut = sim('AGV_Aligned_Plant', 'StopTime', '0.001');
disp('Simulation successful!');
