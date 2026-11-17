% check_multibody_solver_choice.m
clear; clc;
load_system('AGV_Warehouse_Sim');
sc = find_system('AGV_Warehouse_Sim', 'SearchDepth', 1, 'BlockType', 'SimscapeSolverConfiguration');
if isempty(sc)
    sc = find_system('AGV_Warehouse_Sim', 'SearchDepth', 1, 'RegExp', 'on', 'Name', 'Solver.*Config');
end
fprintf('Current MultibodyLocalSolverChoice: %s\n', get_param(sc{1}, 'MultibodyLocalSolverChoice'));
% Try setting it to something bogus to trigger MATLAB's enum list
try
    set_param(sc{1}, 'MultibodyLocalSolverChoice', 'bogus');
catch ME
    disp(ME.message);
end
close_system('AGV_Warehouse_Sim', 0);
