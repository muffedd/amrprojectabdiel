% build_agv_warehouse_sim.m
% Script to build AGV_Warehouse_Sim.slx from AGV_Aligned_Plant.slx
clear; clc;

disp('=== Step 1: Loading base workspace data and AGV_Aligned_Plant ===');
evalin('base', 'run(''AGV_DataFile.m'')');

modelName = 'AGV_Warehouse_Sim';
if bdIsLoaded(modelName)
    close_system(modelName, 0);
end
if bdIsLoaded('AGV_Aligned_Plant')
    close_system('AGV_Aligned_Plant', 0);
end

load_system('AGV_Aligned_Plant');
save_system('AGV_Aligned_Plant', [modelName, '.slx']);
close_system('AGV_Aligned_Plant', 0);
open_system(modelName);

load_system('sm_lib');
load_system('nesl_utility');
load_system('simulink');

disp('=== Step 2: Unlocking and actuating the 4 Mecanum wheels ===');
rot = @(ang, ax) axang2rotm([ax(:)', ang]);
p_hub_w = [-0.1454990063668878; 0.0751741789496352; 0.2581649344177215];
wheel_rt_idx = [40, 47, 26, 57];

for k = 1:4
    dwa = sprintf('%s/AGV_STEP_1_RIGID/Drive_Wheel_Assembly_STEP_%d_RIGID', modelName, k);
    mw = sprintf('%s/Mecanum_Wheel_STEP_1_RIGID', dwa);
    solid = sprintf('%s/Solid', mw);
    
    % Enable convex hull geometry export on the wheel File Solid
    set_param(solid, 'ExportConvexHullGeometry', 'on');
    
    % Add Connection Port for geometry in Mecanum_Wheel subsystem if not present
    g_port_mw = sprintf('%s/G', mw);
    if isempty(find_system(mw, 'SearchDepth', 1, 'Name', 'G'))
        add_block('nesl_utility/Connection Port', g_port_mw, 'Side', 'Right');
        add_line(mw, 'Solid/LConn1', 'G/RConn1', 'autorouting', 'on');
    end
    
    % Add Connection Port for geometry in DWA subsystem if not present
    g_port_dwa = sprintf('%s/G', dwa);
    if isempty(find_system(dwa, 'SearchDepth', 1, 'Name', 'G'))
        add_block('nesl_utility/Connection Port', g_port_dwa, 'Side', 'Right');
        add_line(dwa, 'Mecanum_Wheel_STEP_1_RIGID/RConn1', 'G/RConn1', 'autorouting', 'on');
    end
    
    % Delete existing line between Transform4 and Mecanum_Wheel
    lines = get_param(dwa, 'Lines');
    for l = 1:length(lines)
        sb = lines(l).SrcBlock;
        db = lines(l).DstBlock;
        if sb ~= -1 && db ~= -1
            sname = get_param(sb, 'Name');
            dname = get_param(db, 'Name');
            if (strcmp(sname, 'Transform4') && strcmp(dname, 'Mecanum_Wheel_STEP_1_RIGID')) || ...
               (strcmp(dname, 'Transform4') && strcmp(sname, 'Mecanum_Wheel_STEP_1_RIGID'))
                delete_line(lines(l).Handle);
            end
        end
    end
    
    % Calculate exact hub transform from DWA to wheel hub
    rt = smiData.RigidTransform(wheel_rt_idx(k));
    R_orig = rot(rt.angle, rt.axis);
    t_orig = rt.translation(:);
    T_orig = [R_orig, t_orig; 0 0 0 1];
    
    T_base = T_orig * [eye(3), p_hub_w; 0 0 0 1];
    R_base = T_base(1:3, 1:3);
    t_base = T_base(1:3, 4);
    
    % Update Transform4 as the base transform (from DWA ref frame to wheel hub)
    t4 = sprintf('%s/Transform4', dwa);
    set_param(t4, 'TranslationMethod', 'Cartesian', ...
                  'TranslationCartesianOffset', mat2str(t_base'), ...
                  'RotationMethod', 'ArbitraryAxis', ...
                  'RotationArbitraryAxis', mat2str(axang2rotm_to_axang(R_base, 1)), ...
                  'RotationAngle', num2str(axang2rotm_to_axang(R_base, 2)));
    
    % Add Revolute Joint
    rj = sprintf('%s/Revolute_Joint', dwa);
    if isempty(find_system(dwa, 'SearchDepth', 1, 'Name', 'Revolute_Joint'))
        add_block('sm_lib/Joints/Revolute Joint', rj);
    end
    set_param(rj, 'TorqueActuationMode', 'InputTorque', 'SenseVelocity', 'on');
    
    % Add Follower Rigid Transform (from Joint to wheel solid origin)
    tfoll = sprintf('%s/Transform_Follower', dwa);
    if isempty(find_system(dwa, 'SearchDepth', 1, 'Name', 'Transform_Follower'))
        add_block('sm_lib/Frames and Transforms/Rigid Transform', tfoll);
    end
    set_param(tfoll, 'TranslationMethod', 'Cartesian', ...
                     'TranslationCartesianOffset', mat2str((-p_hub_w)'), ...
                     'RotationMethod', 'ArbitraryAxis', ...
                     'RotationArbitraryAxis', '[0 0 1]', ...
                     'RotationAngle', '0');
    
    % Connect: Transform4/RConn1 -> Revolute_Joint/LConn1
    add_line(dwa, 'Transform4/RConn1', 'Revolute_Joint/LConn1', 'autorouting', 'on');
    % Connect: Revolute_Joint/RConn1 -> Transform_Follower/LConn1
    add_line(dwa, 'Revolute_Joint/RConn1', 'Transform_Follower/LConn1', 'autorouting', 'on');
    % Connect: Transform_Follower/RConn1 -> Mecanum_Wheel_STEP_1_RIGID/LConn1
    add_line(dwa, 'Transform_Follower/RConn1', 'Mecanum_Wheel_STEP_1_RIGID/LConn1', 'autorouting', 'on');
    
    % Add zero torque actuation: PS-Constant 0 -> Revolute_Joint/LConn2
    ps_c = sprintf('%s/PS_Zero_Torque', dwa);
    if isempty(find_system(dwa, 'SearchDepth', 1, 'Name', 'PS_Zero_Torque'))
        add_block('nesl_utility/Simulink-PS Converter', ps_c);
        c_blk = sprintf('%s/Const_Zero', dwa);
        add_block('simulink/Commonly Used Blocks/Constant', c_blk, 'Value', '0');
        add_line(dwa, 'Const_Zero/1', 'PS_Zero_Torque/1', 'autorouting', 'on');
        add_line(dwa, 'PS_Zero_Torque/RConn1', 'Revolute_Joint/LConn2', 'autorouting', 'on');
    end
    
    % Add velocity sensing output: Revolute_Joint/RConn2 -> PS-Simulink Converter -> Outport
    ps_s = sprintf('%s/PS_Velocity_Sensor', dwa);
    if isempty(find_system(dwa, 'SearchDepth', 1, 'Name', 'PS_Velocity_Sensor'))
        add_block('nesl_utility/PS-Simulink Converter', ps_s);
        out_blk = sprintf('%s/Wheel_Velocity', dwa);
        add_block('simulink/Commonly Used Blocks/Outport', out_blk);
        add_line(dwa, 'Revolute_Joint/RConn2', 'PS_Velocity_Sensor/LConn1', 'autorouting', 'on');
        add_line(dwa, 'PS_Velocity_Sensor/1', 'Wheel_Velocity/1', 'autorouting', 'on');
    end
    
    % Route DWA G port out of AGV_STEP_1_RIGID
    agv_sub = sprintf('%s/AGV_STEP_1_RIGID', modelName);
    g_port_agv = sprintf('%s/G_Wheel_%d', agv_sub, k);
    if isempty(find_system(agv_sub, 'SearchDepth', 1, 'Name', sprintf('G_Wheel_%d', k)))
        add_block('nesl_utility/Connection Port', g_port_agv, 'Side', 'Right');
        dwa_name = sprintf('Drive_Wheel_Assembly_STEP_%d_RIGID', k);
        add_line(agv_sub, [dwa_name, '/RConn1'], sprintf('G_Wheel_%d/RConn1', k), 'autorouting', 'on');
    end
    
    % Arrange DWA layout
    Simulink.BlockDiagram.arrangeSystem(dwa);
end

Simulink.BlockDiagram.arrangeSystem(agv_sub);
disp('Wheels unlocked, actuated, and geometry ports routed successfully.');

% Helper function to convert rotation matrix to axis-angle
function out = axang2rotm_to_axang(R, mode)
    axang = rotm2axang(R);
    if mode == 1
        out = axang(1:3);
    else
        out = axang(4);
    end
end
