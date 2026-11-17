% analyze_agv_geometry_and_torque.m
clear; clc;
evalin('base', 'run(''AGV_DataFile.m'')');
load_system('AGV_Warehouse_Sim');

% Check lines to SICK sensor and Front Casing
agv = 'AGV_Warehouse_Sim/AGV_STEP_1_RIGID';
lines = get_param(agv, 'Lines');
for l = 1:length(lines)
    sb = lines(l).SrcBlock;
    db = lines(l).DstBlock;
    if ~isempty(sb) && ~isempty(db) && all(sb ~= -1) && all(db ~= -1)
        sname = get_param(sb(1), 'Name');
        dname = get_param(db(1), 'Name');
        if contains(sname, 'SICK') || contains(dname, 'SICK') || ...
           contains(sname, 'Front_Casing') || contains(dname, 'Front_Casing')
            fprintf('  %s -> %s\n', sname, dname);
        end
    end
end

% Let's run a quick 0.05s sim and check wheel velocities with small torque
set_param('AGV_Warehouse_Sim/AGV_STEP_1_RIGID/Drive_Wheel_Assembly_STEP_1_RIGID/Const_Zero', 'Value', '2.0');
set_param('AGV_Warehouse_Sim/AGV_STEP_1_RIGID/Drive_Wheel_Assembly_STEP_2_RIGID/Const_Zero', 'Value', '2.0');
set_param('AGV_Warehouse_Sim/AGV_STEP_1_RIGID/Drive_Wheel_Assembly_STEP_3_RIGID/Const_Zero', 'Value', '-2.0');
set_param('AGV_Warehouse_Sim/AGV_STEP_1_RIGID/Drive_Wheel_Assembly_STEP_4_RIGID/Const_Zero', 'Value', '-2.0');

simOut = sim('AGV_Warehouse_Sim', 'StopTime', '0.1');
disp('Sim ran successfully with torques!');

close_system('AGV_Warehouse_Sim', 0);
