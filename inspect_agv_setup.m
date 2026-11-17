% inspect_agv_setup.m
clear; clc;
evalin('base', 'run(''AGV_DataFile.m'')');
load_system('AGV_Warehouse_Sim');

disp('=== 1. Inspecting Joint_6DOF ===');
j6 = 'AGV_Warehouse_Sim/Joint_6DOF';
dp = get_param(j6, 'DialogParameters');
fnames = fieldnames(dp);
target_fields = fnames(contains(fnames, 'PositionTarget') | contains(fnames, 'VelocityTarget') | contains(fnames, 'Specify'));
for i = 1:length(target_fields)
    fn = target_fields{i};
    try
        val = get_param(j6, fn);
        fprintf('  %s: %s\n', fn, num2str(val));
    catch
    end
end

disp('=== 2. Inspecting DWA Subsystems & Revolute Joints ===');
for k = 1:4
    dwa = sprintf('AGV_Warehouse_Sim/AGV_STEP_1_RIGID/Drive_Wheel_Assembly_STEP_%d_RIGID', k);
    rj = sprintf('%s/Revolute_Joint', dwa);
    t4 = sprintf('%s/Transform4', dwa);
    tfoll = sprintf('%s/Transform_Follower', dwa);
    
    t_offset = get_param(t4, 'TranslationCartesianOffset');
    r_axis = get_param(t4, 'RotationArbitraryAxis');
    r_ang = get_param(t4, 'RotationAngle');
    fprintf('DWA %d:\n  t4 offset: %s\n  t4 axis: %s, angle: %s\n', k, t_offset, r_axis, r_ang);
    
    % Check ports of Revolute_Joint
    ph = get_param(rj, 'PortHandles');
    fprintf('  Revolute Joint LConn: %d, RConn: %d\n', length(ph.LConn), length(ph.RConn));
end

disp('=== 3. Inspecting AGV_STEP_1_RIGID Ports and Connections ===');
agv = 'AGV_Warehouse_Sim/AGV_STEP_1_RIGID';
ph_agv = get_param(agv, 'PortHandles');
fprintf('AGV LConn: %d, RConn: %d, Inport: %d, Outport: %d\n', length(ph_agv.LConn), length(ph_agv.RConn), length(ph_agv.Inport), length(ph_agv.Outport));

disp('=== 4. Inspecting Transform Sensor blocks available in sm_lib ===');
load_system('sm_lib');
sensor_blk = 'sm_lib/Frames and Transforms/Transform Sensor';
dp_sensor = get_param(sensor_blk, 'DialogParameters');
disp('Transform Sensor dialog parameters:');
sensor_fns = fieldnames(dp_sensor);
disp(sensor_fns(contains(sensor_fns, 'Sense') | contains(sensor_fns, 'Sequence') | contains(sensor_fns, 'Frame')));

close_system('AGV_Warehouse_Sim', 0);
