% check_frame_f.m
clear; clc;
evalin('base', 'run(''AGV_DataFile.m'')');
load_system('AGV_Warehouse_Sim');

disp('smiData.RigidTransform(51).translation (Front Casing):');
disp(smiData.RigidTransform(51).translation);

disp('smiData.RigidTransform(62).translation (SICK Sensor):');
disp(smiData.RigidTransform(62).translation);

% Check lines at top level connected to Transform
lines = get_param('AGV_Warehouse_Sim', 'Lines');
for l = 1:length(lines)
    sb = lines(l).SrcBlock;
    db = lines(l).DstBlock;
    if ~isempty(sb) && ~isempty(db) && all(sb ~= -1) && all(db ~= -1)
        sname = get_param(sb(1), 'Name');
        dname = get_param(db(1), 'Name');
        if strcmp(sname, 'Transform') || strcmp(dname, 'Transform') || ...
           strcmp(sname, 'AGV_STEP_1_RIGID') || strcmp(dname, 'AGV_STEP_1_RIGID')
            fprintf('  Top-level: %s -> %s\n', sname, dname);
        end
    end
end

close_system('AGV_Warehouse_Sim', 0);
