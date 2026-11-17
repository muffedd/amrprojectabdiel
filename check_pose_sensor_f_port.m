% check_pose_sensor_f_port.m
clear; clc;
load_system('AGV_Warehouse_Sim');

ts = 'AGV_Warehouse_Sim/Pose_Sensor';
pc = get_param(ts, 'PortConnectivity');
for i = 1:length(pc)
    fprintf('TS Port %s (Type: %s): connected to %d dst blocks\n', num2str(i), pc(i).Type, length(pc(i).DstBlock));
    if ~isempty(pc(i).DstBlock)
        for d = 1:length(pc(i).DstBlock)
            fprintf('   -> %s\n', get_param(pc(i).DstBlock(d), 'Name'));
        end
    end
end

close_system('AGV_Warehouse_Sim', 0);
