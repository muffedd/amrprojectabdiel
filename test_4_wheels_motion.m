% test_4_wheels_motion.m
clear; clc;
evalin('base', 'run(''AGV_DataFile.m'')');
load_system('AGV_Warehouse_Sim');

set_param('AGV_Warehouse_Sim/Warehouse_Floor', 'BrickDimensions', '[30 30 0.1]');

j6 = 'AGV_Warehouse_Sim/Joint_6DOF';
set_param(j6, 'PxPositionTargetSpecify', 'on', 'PxPositionTargetValue', '-2.0', 'PxPositionTargetPriority', 'High');
set_param(j6, 'PyPositionTargetSpecify', 'on', 'PyPositionTargetValue', '-3.0', 'PyPositionTargetPriority', 'High');
set_param(j6, 'SphPositionTargetSpecify', 'on', ...
              'SphPositionTargetPriority', 'High', ...
              'SphPositionTargetRotationMethod', 'StandardAxis', ...
              'SphPositionTargetRotationStandardAxis', '+Z', ...
              'SphPositionTargetRotationAngle', '180', ...
              'SphPositionTargetRotationAngleUnits', 'deg');

agv = 'AGV_Warehouse_Sim/AGV_STEP_1_RIGID';

% Let's see the inports of DWA 1, 2, 3, 4
% We can disconnect DWA/Torque_Cmd inside AGV_STEP_1_RIGID and connect test constants
for k = 1:4
    dwa_name = sprintf('Drive_Wheel_Assembly_STEP_%d_RIGID', k);
    % Find lines connected to DWA inport 1
    ph = get_param([agv, '/', dwa_name], 'PortHandles');
    l = get_param(ph.Inport(1), 'Line');
    if l ~= -1, delete_line(l); end
    
    % Add constant block for wheel k inside AGV_STEP_1_RIGID
    c_name = sprintf('T_Wheel_%d', k);
    if isempty(find_system(agv, 'SearchDepth', 1, 'Name', c_name))
        add_block('simulink/Sources/Constant', [agv, '/', c_name], 'Value', '0');
        add_line(agv, [c_name, '/1'], [dwa_name, '/1'], 'autorouting', 'on');
    end
end

% Ensure Log_XY exists
if isempty(find_system('AGV_Warehouse_Sim', 'SearchDepth', 1, 'Name', 'Log_XY'))
    add_block('simulink/Sinks/To Workspace', 'AGV_Warehouse_Sim/Log_XY', 'VariableName', 'xy_log', 'SaveFormat', 'Timeseries');
    add_line('AGV_Warehouse_Sim', 'Get_XY/1', 'Log_XY/1', 'autorouting', 'on');
end
if isempty(find_system('AGV_Warehouse_Sim', 'SearchDepth', 1, 'Name', 'Log_Yaw'))
    add_block('simulink/Sinks/To Workspace', 'AGV_Warehouse_Sim/Log_Yaw', 'VariableName', 'yaw_log', 'SaveFormat', 'Timeseries');
    add_line('AGV_Warehouse_Sim', 'Get_Yaw/1', 'Log_Yaw/1', 'autorouting', 'on');
end

for w = 1:4
    % Reset all to 0
    for k = 1:4
        set_param([agv, sprintf('/T_Wheel_%d', k)], 'Value', '0');
    end
    % Set wheel w to +1.0 Nm
    set_param([agv, sprintf('/T_Wheel_%d', w)], 'Value', '1.0');
    
    simOut = sim('AGV_Warehouse_Sim', 'StopTime', '0.15');
    xy = simOut.xy_log.Data;
    yaw = simOut.yaw_log.Data;
    
    if ndims(xy) == 3
        x0 = xy(1,1,1); y0 = xy(2,1,1);
        x_end = xy(1,1,end); y_end = xy(2,1,end);
    else
        x0 = xy(1,1); y0 = xy(1,2);
        x_end = xy(end,1); y_end = xy(end,2);
    end
    psi0 = yaw(1); psi_end = yaw(end);
    
    fprintf('Wheel %d (+1.0 Nm): dX = %+.5f m, dY = %+.5f m, dYaw = %+.5f rad\n', ...
        w, x_end - x0, y_end - y0, psi_end - psi0);
end

close_system('AGV_Warehouse_Sim', 0);
