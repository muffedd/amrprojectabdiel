% check_scf_params.m
load_system('AGV_Warehouse_Sim');
scf = 'AGV_Warehouse_Sim/Spatial_Contact_Wheel_1';
p = get_param(scf, 'DialogParameters');
flds = fieldnames(p);
disp('Matching contact parameters:');
for i = 1:length(flds)
    if contains(lower(flds{i}), 'stiff') || contains(lower(flds{i}), 'damp') || ...
       contains(lower(flds{i}), 'frict') || contains(lower(flds{i}), 'transit') || ...
       contains(lower(flds{i}), 'width') || contains(lower(flds{i}), 'region')
        fprintf('  %s: %s\n', flds{i}, get_param(scf, flds{i}));
    end
end
close_system('AGV_Warehouse_Sim', 0);
