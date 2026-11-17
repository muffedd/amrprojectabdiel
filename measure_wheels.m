% measure_wheels.m
evalin('base', 'run(''AGV_DataFile.m'')');
load_system('AGV_Aligned_Plant');

% Let's inspect the DWA subsystems and Mecanum wheel subsystems
for i = 1:4
    dwa = sprintf('AGV_Aligned_Plant/AGV_STEP_1_RIGID/Drive_Wheel_Assembly_STEP_%d_RIGID', i);
    mw = sprintf('%s/Mecanum_Wheel_STEP_1_RIGID', dwa);
    disp(['--- ', dwa, ' ---']);
    blks = find_system(dwa, 'SearchDepth', 1);
    for b = 1:length(blks)
        disp(['   ', blks{b}]);
    end
end
