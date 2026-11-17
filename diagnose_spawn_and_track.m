% diagnose_spawn_and_track.m
clear; clc;
evalin('base', 'run(''AGV_DataFile.m'')');
load_system('AGV_Warehouse_Sim');

% 1. Check Track and Floor dimensions and positions in Warehouse_Environment
env = 'AGV_Warehouse_Sim/Warehouse_Environment';
blks = find_system(env, 'SearchDepth', 1);
for i = 1:length(blks)
    b = blks{i};
    if contains(b, 'Track') || contains(b, 'Pallet') || contains(b, 'Floor')
        fprintf('Block: %s\n', get_param(b, 'Name'));
        if contains(b, 'Transform')
            fprintf('  Offset: %s\n', get_param(b, 'TranslationCartesianOffset'));
        end
        if strcmp(get_param(b, 'BlockType'), 'Reference')
            try fprintf('  Dims: %s\n', get_param(b, 'BrickDimensions')); end
        end
    end
end

% 2. Check Warehouse_Floor at root
wf = 'AGV_Warehouse_Sim/Warehouse_Floor';
fprintf('\nWarehouse_Floor at root:\n');
fprintf('  Dims: %s\n', get_param(wf, 'BrickDimensions'));
fprintf('  Floor_Transform Offset: %s\n', get_param('AGV_Warehouse_Sim/Floor_Transform', 'TranslationCartesianOffset'));

% 3. Check Joint_6DOF targets
j6 = 'AGV_Warehouse_Sim/Joint_6DOF';
fprintf('\nJoint_6DOF current targets:\n');
fprintf('  Px: %s (Specify: %s)\n', get_param(j6, 'PxPositionTargetValue'), get_param(j6, 'PxPositionTargetSpecify'));
fprintf('  Py: %s (Specify: %s)\n', get_param(j6, 'PyPositionTargetValue'), get_param(j6, 'PyPositionTargetSpecify'));
fprintf('  Pz: %s (Specify: %s)\n', get_param(j6, 'PzPositionTargetValue'), get_param(j6, 'PzPositionTargetSpecify'));

close_system('AGV_Warehouse_Sim', 0);
