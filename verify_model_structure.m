% verify_model_structure.m
clear; clc;
load_system('AGV_Warehouse_Sim');

fprintf('=== Model Inspection: AGV_Warehouse_Sim ===\n');

% 1. Joint_6DOF targets
j6 = 'AGV_Warehouse_Sim/Joint_6DOF';
fprintf('Joint_6DOF Px: %s m (specify: %s)\n', get_param(j6, 'PxPositionTargetValue'), get_param(j6, 'PxPositionTargetSpecify'));
fprintf('Joint_6DOF Py: %s m (specify: %s)\n', get_param(j6, 'PyPositionTargetValue'), get_param(j6, 'PyPositionTargetSpecify'));

% 2. Pose Sensor
ts = 'AGV_Warehouse_Sim/Pose_Sensor';
fprintf('Pose Sensor exists: %s\n', mat2str(~isempty(find_system('AGV_Warehouse_Sim', 'SearchDepth', 1, 'Name', 'Pose_Sensor'))));
fprintf('SenseXYZ: %s, SenseRotationSequence: %s, Sequence: %s\n', ...
    get_param(ts, 'SenseXYZ'), get_param(ts, 'SenseRotationSequence'), get_param(ts, 'RotationSequence'));

% 3. Controller
mf = 'AGV_Warehouse_Sim/Line_Tracking_Controller';
fprintf('Line_Tracking_Controller exists: %s\n', mat2str(~isempty(find_system('AGV_Warehouse_Sim', 'SearchDepth', 1, 'Name', 'Line_Tracking_Controller'))));

% 4. DWA Torque converters
for k = 1:4
    ps_blk = sprintf('AGV_Warehouse_Sim/AGV_STEP_1_RIGID/Drive_Wheel_Assembly_STEP_%d_RIGID/PS_Zero_Torque', k);
    if isempty(find_system('AGV_Warehouse_Sim', 'SearchDepth', 3, 'Name', sprintf('PS_Zero_Torque')))
        ps_blk = sprintf('AGV_Warehouse_Sim/AGV_STEP_1_RIGID/Drive_Wheel_Assembly_STEP_%d_RIGID/PS_Torque', k);
    end
    fprintf('DWA %d PS filter: %s, time const: %s s\n', k, ...
        get_param(ps_blk, 'FilteringAndDerivatives'), get_param(ps_blk, 'InputFilterTimeConstant'));
end

close_system('AGV_Warehouse_Sim', 0);
fprintf('Verification completed successfully!\n');
