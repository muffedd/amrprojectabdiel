% verify_torque_signs.m
clear; clc;
evalin('base', 'run(''AGV_DataFile.m'')');
load_system('AGV_Warehouse_Sim');

% Test Case A: Right wheels +2 Nm, Left wheels -2 Nm
c1 = 'AGV_Warehouse_Sim/AGV_STEP_1_RIGID/Drive_Wheel_Assembly_STEP_1_RIGID/Const_Zero';
c2 = 'AGV_Warehouse_Sim/AGV_STEP_1_RIGID/Drive_Wheel_Assembly_STEP_2_RIGID/Const_Zero';
c3 = 'AGV_Warehouse_Sim/AGV_STEP_1_RIGID/Drive_Wheel_Assembly_STEP_3_RIGID/Const_Zero';
c4 = 'AGV_Warehouse_Sim/AGV_STEP_1_RIGID/Drive_Wheel_Assembly_STEP_4_RIGID/Const_Zero';

% Let's log wheel angular velocities
% In each DWA, there is already an Outport 'Wheel_Velocity'
% Let's run 0.05 s test with tau_R = +5, tau_L = -5
set_param(c1, 'Value', '5');
set_param(c2, 'Value', '5');
set_param(c3, 'Value', '-5');
set_param(c4, 'Value', '-5');

simOut = sim('AGV_Warehouse_Sim', 'StopTime', '0.05');

% Let's see the 6-DOF joint motion or chassis position
% If Out_XYZ is in the model:
try
    pos = simOut.pos_out.Data;
    fprintf('Delta X (case A: tau_R=+5, tau_L=-5): %.5f m\n', pos(end,1) - pos(1,1));
    fprintf('Delta Y (case A: tau_R=+5, tau_L=-5): %.5f m\n', pos(end,2) - pos(1,2));
catch
    disp('Out_XYZ not present in current model');
end

close_system('AGV_Warehouse_Sim', 0);
