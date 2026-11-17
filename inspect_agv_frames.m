% inspect_agv_frames.m
clear; clc;
evalin('base', 'run(''AGV_DataFile.m'')');
load_system('AGV_Warehouse_Sim');

agv = 'AGV_Warehouse_Sim/AGV_STEP_1_RIGID';
lines = get_param(agv, 'Lines');
for l = 1:length(lines)
    sb = lines(l).SrcBlock;
    db = lines(l).DstBlock;
    if ~isempty(sb) && ~isempty(db) && all(sb ~= -1) && all(db ~= -1)
        sname = get_param(sb(1), 'Name');
        dname = get_param(db(1), 'Name');
        if contains(sname, 'Drive_Wheel') || contains(dname, 'Drive_Wheel') || ...
           contains(sname, 'Transform') || contains(dname, 'Transform') || ...
           contains(sname, 'Port') || contains(dname, 'Port')
            fprintf('  Line: %s -> %s\n', sname, dname);
        end
    end
end

% Let's also check all blocks inside AGV_STEP_1_RIGID
blks = find_system(agv, 'SearchDepth', 1);
fprintf('\nBlocks in AGV_STEP_1_RIGID:\n');
for b = 1:length(blks)
    fprintf('  %s\n', get_param(blks{b}, 'Name'));
end

close_system('AGV_Warehouse_Sim', 0);
