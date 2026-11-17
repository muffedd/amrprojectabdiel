% inspect_shelves_now.m
load_system('AGV_Warehouse_Sim');
env = 'AGV_Warehouse_Sim/Warehouse_Environment';
tfs = {'Warehouse_Shelf_1_Transform', 'Cargo_Box_1_Transform', ...
       'Warehouse_Shelf_2_Transform', 'Cargo_Box_2_Transform', ...
       'Warehouse_Shelf_3_Transform', 'Cargo_Box_3_Transform'};

for i = 1:length(tfs)
    blk = [env, '/', tfs{i}];
    if ~isempty(find_system(env, 'SearchDepth', 1, 'Name', tfs{i}))
        fprintf('%s Offset: %s\n', tfs{i}, get_param(blk, 'TranslationCartesianOffset'));
    end
end
close_system('AGV_Warehouse_Sim', 0);
