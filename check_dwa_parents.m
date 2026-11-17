% check_dwa_parents.m
clear; clc;
evalin('base', 'run(''AGV_DataFile.m'')');
load_system('AGV_Warehouse_Sim');

agv = 'AGV_Warehouse_Sim/AGV_STEP_1_RIGID';
for k = 1:4
    dwa_name = sprintf('Drive_Wheel_Assembly_STEP_%d_RIGID', k);
    dwa_blk = [agv, '/', dwa_name];
    pc = get_param(dwa_blk, 'PortConnectivity');
    for p = 1:length(pc)
        if ~isempty(pc(p).DstBlock)
            for d = 1:length(pc(p).DstBlock)
                dst = pc(p).DstBlock(d);
                fprintf('DWA %d port %s connects to %s\n', k, pc(p).Type, get_param(dst, 'Name'));
            end
        end
    end
end

close_system('AGV_Warehouse_Sim', 0);
