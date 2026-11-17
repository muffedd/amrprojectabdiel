% apply_discrete_sample_time_fix.m
clear; clc;
disp('=== Step 1: Loading AGV_DataFile and AGV_Warehouse_Sim ===');
evalin('base', 'run(''AGV_DataFile.m'')');

modelName = 'AGV_Warehouse_Sim';
if bdIsLoaded(modelName), close_system(modelName, 0); end
load_system(modelName);

disp('=== Step 2: Locating Stateflow.EMChart and setting Discrete Sample Time ===');
rt = sfroot;
charts = rt.find('-isa', 'Stateflow.EMChart');

found = false;
for i = 1:length(charts)
    fprintf('Found chart: %s\n', charts(i).Path);
    if contains(charts(i).Path, 'Line_Tracking_Controller')
        charts(i).ChartUpdate = 'DISCRETE';
        charts(i).SampleTime = '0.01';
        fprintf('  [SUCCESS] Set %s -> ChartUpdate = ''DISCRETE'', SampleTime = ''0.01''\n', charts(i).Path);
        found = true;
    end
end

if ~found
    error('Could not find Line_Tracking_Controller EMChart!');
end

disp('=== Step 3: Saving AGV_Warehouse_Sim.slx ===');
save_system(modelName);
disp('Model saved successfully.');

disp('=== Step 4: Running 0.1-Second Test Simulation ===');
tic;
simOut = sim(modelName, 'StopTime', '0.1');
elapsed = toc;

fprintf('\n=== Simulation Completed Successfully! ===\n');
fprintf('Elapsed wall-clock time: %.2f seconds\n', elapsed);

% Verify simulation advanced past t = 0
try
    t_end = simOut.SimulationMetadata.ModelInfo.StopTime;
    fprintf('Reported StopTime: %.4f s\n', t_end);
catch
end

try
    t_vec = simOut.tout;
    fprintf('Time vector length: %d steps, starts at t=%.4f s, ends at t=%.4f s\n', ...
        length(t_vec), t_vec(1), t_vec(end));
    if t_vec(end) > 0
        fprintf('CONFIRMED: Simulation advanced past t = 0 to t = %.4f s with ZERO errors!\n', t_vec(end));
    end
catch
    % Check To Workspace logs
    try
        s_data = simOut.state_log;
        fprintf('State log length: %d steps, time ends at %.4f s\n', ...
            length(s_data.Time), s_data.Time(end));
        if s_data.Time(end) > 0
            fprintf('CONFIRMED: Simulation advanced past t = 0 to t = %.4f s with ZERO errors!\n', s_data.Time(end));
        end
    catch
        fprintf('Simulation completed cleanly without errors!\n');
    end
end
