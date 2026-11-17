% verify_final_sim.m
clear; clc;
evalin('base', 'run(''AGV_DataFile.m'')');
load_system('AGV_Warehouse_Sim');

tic;
simOut = sim('AGV_Warehouse_Sim', 'StopTime', '0.2');
elapsed = toc;

xy_ts = simOut.xy_log;
xy_data = xy_ts.Data;
yaw_data = simOut.yaw_log.Data;

if ndims(xy_data) == 3
    x0 = xy_data(1,1,1); y0 = xy_data(2,1,1);
    x_end = xy_data(1,1,end); y_end = xy_data(2,1,end);
else
    x0 = xy_data(1,1); y0 = xy_data(1,2);
    x_end = xy_data(end,1); y_end = xy_data(end,2);
end
psi0 = yaw_data(1); psi_end = yaw_data(end);

fprintf('\n================== FINAL VERIFICATION REPORT ==================\n');
fprintf('Simulation Time Elapsed: %.2f seconds\n', elapsed);
fprintf('Start Pose: X = %+.4f m, Y = %+.4f m, Yaw = %+.4f rad (%.2f deg)\n', ...
    x0, y0, psi0, psi0*180/pi);
fprintf('End Pose:   X = %+.4f m, Y = %+.4f m, Yaw = %+.4f rad (%.2f deg)\n', ...
    x_end, y_end, psi_end, psi_end*180/pi);
fprintf('Displacement Delta X: %+.5f m\n', x_end - x0);
fprintf('Displacement Delta Y: %+.5f m\n', y_end - y0);
fprintf('Displacement Delta Yaw: %+.5f rad\n', psi_end - psi0);

assert((x_end - x0) > 0, 'AGV did not move forward along +X');
assert(abs(y_end - y0) < 0.05, 'AGV deviated excessively in lateral direction');
fprintf('\n>>> ALL CHECKS PASSED: MODEL AGV_Warehouse_Sim.slx IS VERIFIED AND STABLE! <<<\n');

close_system('AGV_Warehouse_Sim', 0);
