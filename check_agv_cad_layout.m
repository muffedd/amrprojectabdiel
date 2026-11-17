% check_agv_cad_layout.m
clear; clc;
evalin('base', 'run(''AGV_DataFile.m'')');

% Let's see the 4 wheel translations in CAD:
% DWA 1, 2, 3, 4
wheel_rt_idx = [40, 47, 26, 57];
% But wait! How are DWA 1, 2, 3, 4 connected to the chassis?
% Let's check the lines connecting to DWA 1, 2, 3, 4 in AGV.xml or AGV_STEP_1_RIGID!
load_system('AGV_Warehouse_Sim');
agv = 'AGV_Warehouse_Sim/AGV_STEP_1_RIGID';
lines = get_param(agv, 'Lines');
for k = 1:4
    dwa_name = sprintf('Drive_Wheel_Assembly_STEP_%d_RIGID', k);
    for l = 1:length(lines)
        sb = lines(l).SrcBlock;
        db = lines(l).DstBlock;
        if ~isempty(sb) && ~isempty(db) && all(sb ~= -1) && all(db ~= -1)
            sname = get_param(sb(1), 'Name');
            dname = get_param(db(1), 'Name');
            if strcmp(dname, dwa_name)
                fprintf('%s connects to %s\n', sname, dwa_name);
                % Print transform parameters if it is a transform
                try
                    fprintf('  Translation: %s\n', get_param([agv, '/', sname], 'TranslationCartesianOffset'));
                catch
                end
            end
        end
    end
end
close_system('AGV_Warehouse_Sim', 0);
