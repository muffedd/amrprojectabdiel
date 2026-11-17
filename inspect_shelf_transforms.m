% inspect_shelf_transforms.m
clear; clc;
load_system('AGV_Warehouse_Sim');

env = 'AGV_Warehouse_Sim/Warehouse_Environment';
blks = find_system(env, 'SearchDepth', 1);
for i = 1:length(blks)
    b = blks{i};
    if contains(b, 'Shelf') || contains(b, 'Cargo')
        fprintf('Block: %s\n', get_param(b, 'Name'));
        if contains(b, 'Transform')
            fprintf('  Offset: %s\n', get_param(b, 'TranslationCartesianOffset'));
        end
        if strcmp(get_param(b, 'BlockType'), 'Reference')
            try fprintf('  Dims: %s\n', get_param(b, 'BrickDimensions')); end
        end
    end
end

close_system('AGV_Warehouse_Sim', 0);
