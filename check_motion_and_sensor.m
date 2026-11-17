% check_motion_and_sensor.m
clear; clc;
evalin('base', 'run(''AGV_DataFile.m'')');
load_system('AGV_Warehouse_Sim');

% Check Transform22 (Front Casing) and Transform26 (SICK 3000 Sensor)
t22 = 'AGV_Warehouse_Sim/AGV_STEP_1_RIGID/Transform22';
t26 = 'AGV_Warehouse_Sim/AGV_STEP_1_RIGID/Transform26';
fprintf('Transform22 (Front Casing) translation: %s\n', get_param(t22, 'TranslationCartesianOffset'));
fprintf('Transform26 (SICK Sensor) translation:  %s\n', get_param(t26, 'TranslationCartesianOffset'));

% Check what frame F connects to inside AGV_STEP_1_RIGID
agv = 'AGV_Warehouse_Sim/AGV_STEP_1_RIGID';
lines = get_param(agv, 'Lines');
for l = 1:length(lines)
    sb = lines(l).SrcBlock;
    db = lines(l).DstBlock;
    if ~isempty(sb) && ~isempty(db) && all(sb ~= -1) && all(db ~= -1)
        sname = get_param(sb(1), 'Name');
        dname = get_param(db(1), 'Name');
        if strcmp(sname, 'F') || strcmp(dname, 'F')
            fprintf('Frame F connects: %s -> %s\n', sname, dname);
        end
    end
end

close_system('AGV_Warehouse_Sim', 0);
