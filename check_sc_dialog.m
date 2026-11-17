% check_sc_dialog.m
clear; clc;
load_system('AGV_Warehouse_Sim');

sc = find_system('AGV_Warehouse_Sim', 'SearchDepth', 1, 'BlockType', 'SimscapeSolverConfiguration');
if isempty(sc)
    sc = find_system('AGV_Warehouse_Sim', 'SearchDepth', 1, 'RegExp', 'on', 'Name', 'Solver.*Config');
end

fprintf('Found SC block: %s\n', sc{1});
dp = get_param(sc{1}, 'DialogParameters');
disp(fieldnames(dp));

close_system('AGV_Warehouse_Sim', 0);
