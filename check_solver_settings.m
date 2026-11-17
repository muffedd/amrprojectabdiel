% check_solver_settings.m
clear; clc;
load_system('AGV_Warehouse_Sim');

fprintf('Model Solver: %s\n', get_param('AGV_Warehouse_Sim', 'Solver'));
fprintf('MaxStep:      %s\n', get_param('AGV_Warehouse_Sim', 'MaxStep'));
fprintf('RelTol:       %s\n', get_param('AGV_Warehouse_Sim', 'RelTol'));

sc = 'AGV_Warehouse_Sim/Solver_Configuration';
try
    dp = get_param(sc, 'DialogParameters');
    f = fieldnames(dp);
    for i = 1:length(f)
        fprintf('SC param %s: %s\n', f{i}, num2str(get_param(sc, f{i})));
    end
catch ME
    disp(ME.message);
end

close_system('AGV_Warehouse_Sim', 0);
