% build_and_verify_warehouse_sim.m
% Master build script for AGV_Warehouse_Sim.slx
clear; clc;

disp('=== Step 1: Initializing Workspace and Base Model ===');
evalin('base', 'run(''AGV_DataFile.m'')');

modelName = 'AGV_Warehouse_Sim';
if bdIsLoaded(modelName), close_system(modelName, 0); end
if bdIsLoaded('AGV_Aligned_Plant'), close_system('AGV_Aligned_Plant', 0); end

copyfile('AGV_Aligned_Plant.slx', [modelName, '.slx'], 'f');
load_system(modelName);

load_system('sm_lib');
load_system('nesl_utility');
load_system('simulink');

disp('=== Step 2: Unlocking & Actuating 4 Mecanum Wheels ===');
rot = @(ang, ax) axang2rotm([ax(:)', ang]);
p_hub_w = [-0.1454990063668878; 0.0751741789496352; 0.2581649344177215];
wheel_rt_idx = [40, 47, 26, 57];

for k = 1:4
    dwa = sprintf('%s/AGV_STEP_1_RIGID/Drive_Wheel_Assembly_STEP_%d_RIGID', modelName, k);
    mw = sprintf('%s/Mecanum_Wheel_STEP_1_RIGID', dwa);
    solid = sprintf('%s/Solid', mw);
    
    % Enable convex hull geometry export
    set_param(solid, 'ExportConvexHullGeometry', 'on');
    
    % Add G port in MW
    g_blk_mw = add_block('nesl_utility/Connection Port', [mw, '/G'], 'Side', 'Right');
    ph_g_mw = get_param(g_blk_mw, 'PortHandles');
    ph_solid = get_param(solid, 'PortHandles');
    add_line(mw, ph_solid.LConn(1), ph_g_mw.RConn(1), 'autorouting', 'on');
    
    % Add G port in DWA
    g_blk_dwa = add_block('nesl_utility/Connection Port', [dwa, '/G'], 'Side', 'Right');
    ph_g_dwa = get_param(g_blk_dwa, 'PortHandles');
    ph_mw = get_param(mw, 'PortHandles');
    add_line(dwa, ph_mw.RConn(1), ph_g_dwa.RConn(1), 'autorouting', 'on');
    
    % Delete line between Transform4 and Mecanum_Wheel
    lines = get_param(dwa, 'Lines');
    for l = 1:length(lines)
        sb = lines(l).SrcBlock;
        db = lines(l).DstBlock;
        if ~isempty(sb) && ~isempty(db) && all(sb ~= -1) && all(db ~= -1)
            sname = get_param(sb(1), 'Name');
            dname = get_param(db(1), 'Name');
            if (strcmp(sname, 'Transform4') && strcmp(dname, 'Mecanum_Wheel_STEP_1_RIGID')) || ...
               (strcmp(dname, 'Transform4') && strcmp(sname, 'Mecanum_Wheel_STEP_1_RIGID'))
                delete_line(lines(l).Handle);
            end
        end
    end
    
    % Compute base transform
    rt = smiData.RigidTransform(wheel_rt_idx(k));
    R_orig = rot(rt.angle, rt.axis);
    t_orig = rt.translation(:);
    T_orig = [R_orig, t_orig; 0 0 0 1];
    
    T_base = T_orig * [eye(3), p_hub_w; 0 0 0 1];
    R_base = T_base(1:3, 1:3);
    t_base = T_base(1:3, 4);
    
    axang = rotm2axang(R_base);
    t4 = sprintf('%s/Transform4', dwa);
    set_param(t4, 'TranslationMethod', 'Cartesian', ...
                  'TranslationCartesianOffset', mat2str(t_base'), ...
                  'RotationMethod', 'ArbitraryAxis', ...
                  'RotationArbitraryAxis', mat2str(axang(1:3)), ...
                  'RotationAngle', num2str(axang(4)));
    
    % Add Revolute Joint
    rj = sprintf('%s/Revolute_Joint', dwa);
    add_block('sm_lib/Joints/Revolute Joint', rj);
    set_param(rj, 'TorqueActuationMode', 'InputTorque', 'SenseVelocity', 'on');
    
    % Add Follower transform
    tfoll = sprintf('%s/Transform_Follower', dwa);
    add_block('sm_lib/Frames and Transforms/Rigid Transform', tfoll);
    set_param(tfoll, 'TranslationMethod', 'Cartesian', ...
                     'TranslationCartesianOffset', mat2str((-p_hub_w)'), ...
                     'RotationMethod', 'ArbitraryAxis', ...
                     'RotationArbitraryAxis', '[0 0 1]', ...
                     'RotationAngle', '0');
    
    % Connect chain
    add_line(dwa, 'Transform4/RConn1', 'Revolute_Joint/LConn1', 'autorouting', 'on');
    add_line(dwa, 'Revolute_Joint/RConn1', 'Transform_Follower/LConn1', 'autorouting', 'on');
    add_line(dwa, 'Transform_Follower/RConn1', 'Mecanum_Wheel_STEP_1_RIGID/LConn1', 'autorouting', 'on');
    
    % Zero torque actuation
    ps_c = sprintf('%s/PS_Zero_Torque', dwa);
    add_block('nesl_utility/Simulink-PS Converter', ps_c);
    set_param(ps_c, 'FilteringAndDerivatives', 'filter', 'InputFilterTimeConstant', '0.04');
    c_blk = sprintf('%s/Const_Zero', dwa);
    add_block('simulink/Sources/Constant', c_blk, 'Value', '0');
    add_line(dwa, 'Const_Zero/1', 'PS_Zero_Torque/1', 'autorouting', 'on');
    add_line(dwa, 'PS_Zero_Torque/RConn1', 'Revolute_Joint/LConn2', 'autorouting', 'on');
    
    % Velocity sensing
    ps_s = sprintf('%s/PS_Velocity_Sensor', dwa);
    add_block('nesl_utility/PS-Simulink Converter', ps_s);
    out_blk = sprintf('%s/Wheel_Velocity', dwa);
    add_block('simulink/Ports & Subsystems/Out1', out_blk);
    add_line(dwa, 'Revolute_Joint/RConn2', 'PS_Velocity_Sensor/LConn1', 'autorouting', 'on');
    add_line(dwa, 'PS_Velocity_Sensor/1', 'Wheel_Velocity/1', 'autorouting', 'on');
    
    % Route DWA G port out of AGV_STEP_1_RIGID
    agv_sub = sprintf('%s/AGV_STEP_1_RIGID', modelName);
    g_port_agv = sprintf('%s/G_Wheel_%d', agv_sub, k);
    g_blk_agv = add_block('nesl_utility/Connection Port', g_port_agv, 'Side', 'Right');
    ph_g_agv = get_param(g_blk_agv, 'PortHandles');
    ph_dwa = get_param(dwa, 'PortHandles');
    add_line(agv_sub, ph_dwa.RConn(end), ph_g_agv.RConn(1), 'autorouting', 'on');
    
    disp(['  DWA ', num2str(k), ' wheel unlocked & actuated.']);
end

disp('=== Step 3: Configuring Robot Mobility & World Alignment ===');
% Gravity points down in World -Z
set_param([modelName, '/MechanismConfiguration'], 'GravityVector', '[0 0 -9.80665]');

% Reconfigure top-level Transform so CAD Y maps to World Z
t_top = [modelName, '/Transform'];
set_param(t_top, 'RotationMethod', 'ArbitraryAxis', ...
                 'RotationArbitraryAxis', '[1 0 0]', ...
                 'RotationAngle', num2str(pi/2), ...
                 'TranslationMethod', 'Cartesian', ...
                 'TranslationCartesianOffset', '[0 0 0]');

% Delete existing line connected to Transform LConn1
ph_t = get_param(t_top, 'PortHandles');
line_in = get_param(ph_t.LConn(1), 'Line');
if line_in ~= -1
    delete_line(line_in);
end

j6_blk = [modelName, '/Joint_6DOF'];
if isempty(find_system(modelName, 'SearchDepth', 1, 'Name', 'Joint_6DOF'))
    add_block('sm_lib/Joints/Bushing Joint', j6_blk);
end
set_param(j6_blk, ...
    'RxSpringStiffness', '500', ...
    'RxDampingCoefficient', '50', ...
    'RxEquilibriumPosition', '0', ...
    'RySpringStiffness', '500', ...
    'RyDampingCoefficient', '50', ...
    'RyEquilibriumPosition', '0', ...
    'PxSpringStiffness', '0', 'PxDampingCoefficient', '0', ...
    'PySpringStiffness', '0', 'PyDampingCoefficient', '0', ...
    'PzSpringStiffness', '0', 'PzDampingCoefficient', '0', ...
    'RzSpringStiffness', '0', 'RzDampingCoefficient', '0');
add_line(modelName, 'World/RConn1', 'Joint_6DOF/LConn1', 'autorouting', 'on');
add_line(modelName, 'Joint_6DOF/RConn1', 'Transform/LConn1', 'autorouting', 'on');

disp('=== Step 4: Measuring Wheel Bottom Z-Height and Building Floor ===');
% Wheel hub center in World Z: 1.3650 m
% Outer physical radius: 0.073182 m
Z_hub = 1.3650;
R_wheel = 0.073182;
Z_bottom = Z_hub - R_wheel; % 1.291818 m
floor_thickness = 0.1;
Z_floor_top = Z_bottom;
Z_floor_center = Z_floor_top - floor_thickness / 2; % 1.241818 m

fprintf('  Wheel Hub Height: %.4f m\n', Z_hub);
fprintf('  Wheel Outer Radius: %.4f m\n', R_wheel);
fprintf('  Lowest Wheel Z-Coordinate: %.4f m\n', Z_bottom);
fprintf('  Floor Top Flush Surface: %.4f m\n', Z_floor_top);
fprintf('  Floor Center Z-Coordinate: %.4f m\n', Z_floor_center);

% Add Floor Rigid Transform
add_block('sm_lib/Frames and Transforms/Rigid Transform', [modelName, '/Floor_Transform']);
set_param([modelName, '/Floor_Transform'], 'TranslationMethod', 'Cartesian', ...
          'TranslationCartesianOffset', sprintf('[0 0 %.6f]', Z_floor_center), ...
          'RotationMethod', 'None');
add_line(modelName, 'World/RConn1', 'Floor_Transform/LConn1', 'autorouting', 'on');

% Add Warehouse Floor Brick Solid
add_block('sm_lib/Body Elements/Brick Solid', [modelName, '/Warehouse_Floor']);
set_param([modelName, '/Warehouse_Floor'], ...
          'BrickDimensions', '[20 20 0.1]', ...
          'GraphicDiffuseColor', '[0.5 0.5 0.5]', ...
          'ExportEntireGeometry', 'on');
add_line(modelName, 'Floor_Transform/RConn1', 'Warehouse_Floor/RConn1', 'autorouting', 'on');

% Add 4 Spatial Contact Force blocks connecting each wheel to the floor
ph_floor = get_param([modelName, '/Warehouse_Floor'], 'PortHandles');
ph_agv = get_param([modelName, '/AGV_STEP_1_RIGID'], 'PortHandles');

for k = 1:4
    scf_name = sprintf('Spatial_Contact_Wheel_%d', k);
    scf_blk = [modelName, '/', scf_name];
    add_block('sm_lib/Forces and Torques/Spatial Contact Force', scf_blk);
    set_param(scf_blk, ...
              'NormalForceType', 'SmoothSpringDamper', ...
              'NormalStiffness', '1.5e5', ...
              'NormalDamping', '2.5e3', ...
              'NormalTransitionRegionWidth', '5e-4', ...
              'FrictionType', 'SmoothStickSlip', ...
              'CoefficientOfDynamicFriction', '0.25', ...
              'CoefficientOfStaticFriction', '0.30');
    
    ph_scf = get_param(scf_blk, 'PortHandles');
    % Base geometry: connect to Floor geometry (LConn1)
    add_line(modelName, ph_scf.LConn(1), ph_floor.LConn(1), 'autorouting', 'on');
    % Follower geometry: connect to Wheel k geometry (RConn_k on AGV)
    add_line(modelName, ph_scf.RConn(1), ph_agv.RConn(k), 'autorouting', 'on');
    disp(['  Spatial Contact Force configured for Wheel ', num2str(k)]);
end

disp('=== Step 5: Adding Warehouse Scenery (Track, Pallet Bays, Shelves) ===');
env_sub = [modelName, '/Warehouse_Environment'];
add_block('built-in/SubSystem', env_sub);
env_lines = get_param(env_sub, 'Lines');
for l = 1:length(env_lines), delete_line(env_lines(l).Handle); end
blks = find_system(env_sub, 'SearchDepth', 1);
for b = 1:length(blks)
    if ~strcmp(blks{b}, env_sub), delete_block(blks{b}); end
end

% Port connecting Environment to World
add_block('nesl_utility/Connection Port', [env_sub, '/World_Frame'], 'Side', 'Left');
add_line(modelName, 'World/RConn1', 'Warehouse_Environment/LConn1', 'autorouting', 'on');

% Helper function to create solid with transform inside environment
add_env_solid = @(name, dims, color, pos) ...
    create_env_part(env_sub, name, dims, color, pos);

Z_track = Z_floor_top + 0.001; % 1 mm above floor surface

% 1. Closed rectangular track loop (10m x 6m, 0.05m wide, 0.002m high, black)
add_env_solid('Track_North', [10 0.05 0.002], [0 0 0], [0 3 Z_track]);
add_env_solid('Track_South', [10 0.05 0.002], [0 0 0], [0 -3 Z_track]);
add_env_solid('Track_East',  [0.05 6 0.002],  [0 0 0], [5 0 Z_track]);
add_env_solid('Track_West',  [0.05 6 0.002],  [0 0 0], [-5 0 Z_track]);

% 2. Three colored pallet stations
Z_station = Z_floor_top + 0.0025;
add_env_solid('Pallet_Bay_Red_Station1',   [1.2 0.8 0.005], [0.85 0.2 0.2], [-2.5 3.8 Z_station]);
add_env_solid('Pallet_Bay_Green_Station2', [1.2 0.8 0.005], [0.2 0.8 0.2],  [5.8 0 Z_station]);
add_env_solid('Pallet_Bay_Blue_Station3',  [1.2 0.8 0.005], [0.2 0.4 0.85], [0 -3.8 Z_station]);

% 3. Warehouse Shelves & Cargo Boxes alongside track (shifted outward by 0.4 m for clearance)
Z_shelf = Z_floor_top + 0.75;
add_env_solid('Warehouse_Shelf_1', [3.0 0.8 1.5], [0.6 0.4 0.2], [2.5 4.6 Z_shelf]);
add_env_solid('Warehouse_Shelf_2', [3.0 0.8 1.5], [0.6 0.4 0.2], [-2.5 -4.6 Z_shelf]);
add_env_solid('Warehouse_Shelf_3', [0.8 3.0 1.5], [0.6 0.4 0.2], [-6.2 0 Z_shelf]);

% Cargo boxes on shelves
add_env_solid('Cargo_Box_1', [0.6 0.6 0.5], [0.85 0.75 0.5], [2.5 4.6 Z_floor_top + 1.5 + 0.25]);
add_env_solid('Cargo_Box_2', [0.6 0.6 0.5], [0.85 0.75 0.5], [-2.5 -4.6 Z_floor_top + 1.5 + 0.25]);
add_env_solid('Cargo_Box_3', [0.5 0.5 0.4], [0.75 0.65 0.4], [5.8 1.2 Z_floor_top + 0.2]);

Simulink.BlockDiagram.arrangeSystem(env_sub);
disp('Warehouse environment created.');

disp('=== Step 6: Arranging Block Diagram Layout and Saving ===');
set_param(modelName, 'Solver', 'ode23t', 'MaxStep', '0.005', 'StopTime', '90');
Simulink.BlockDiagram.arrangeSystem(modelName);
save_system(modelName);
disp(['Saved ', modelName, '.slx successfully.']);

disp('=== Step 7: Verifying Simulation (StopTime = 1 s) ===');
tic;
simOut = sim(modelName, 'StopTime', '1');
elapsed = toc;
fprintf('Simulation completed successfully in %.2f seconds!\n', elapsed);

disp('=== Build and Verification Finished Successfully! ===');

function create_env_part(sys, name, dims, color, pos)
    tf_name = [name, '_Transform'];
    add_block('sm_lib/Frames and Transforms/Rigid Transform', [sys, '/', tf_name]);
    set_param([sys, '/', tf_name], 'TranslationMethod', 'Cartesian', ...
              'TranslationCartesianOffset', mat2str(pos), ...
              'RotationMethod', 'None');
    
    add_block('sm_lib/Body Elements/Brick Solid', [sys, '/', name]);
    set_param([sys, '/', name], ...
              'BrickDimensions', mat2str(dims), ...
              'GraphicDiffuseColor', mat2str(color));
    
    add_line(sys, 'World_Frame/RConn1', [tf_name, '/LConn1'], 'autorouting', 'on');
    add_line(sys, [tf_name, '/RConn1'], [name, '/RConn1'], 'autorouting', 'on');
end
