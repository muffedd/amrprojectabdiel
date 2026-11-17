% test_wheel_setup.m
clear; clc;

evalin('base', 'run(''AGV_DataFile.m'')');

modelName = 'test_whl_setup';
if bdIsLoaded(modelName), close_system(modelName, 0); end
if bdIsLoaded('AGV_Aligned_Plant'), close_system('AGV_Aligned_Plant', 0); end

copyfile('AGV_Aligned_Plant.slx', [modelName, '.slx'], 'f');
load_system(modelName);

load_system('sm_lib');
load_system('nesl_utility');
load_system('simulink');

rot = @(ang, ax) axang2rotm([ax(:)', ang]);
p_hub_w = [-0.1454990063668878; 0.0751741789496352; 0.2581649344177215];
wheel_rt_idx = [40, 47, 26, 57];

for k = 1:4
    dwa = sprintf('%s/AGV_STEP_1_RIGID/Drive_Wheel_Assembly_STEP_%d_RIGID', modelName, k);
    mw = sprintf('%s/Mecanum_Wheel_STEP_1_RIGID', dwa);
    solid = sprintf('%s/Solid', mw);
    
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
    
    disp(['DWA ', num2str(k), ' setup complete.']);
end

save_system(modelName);
disp('Saved successfully! Running 0.01s test simulation...');
simOut = sim(modelName, 'StopTime', '0.01');
disp('Simulation succeeded!');
close_system(modelName, 0);
delete([modelName, '.slx']);
