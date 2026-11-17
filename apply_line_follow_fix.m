% apply_line_follow_fix.m
% Replaces Line_Tracking_Controller in AGV_Warehouse_Sim with v2
% (code in line_tracking_controller_v2.txt). Makes a backup first.
clear; clc;
modelName = 'AGV_Warehouse_Sim';
here = fileparts(mfilename('fullpath')); cd(here);
evalin('base', 'run(''AGV_DataFile.m'')');

bak = sprintf('%s_backup_%s.slx', modelName, datestr(now, 'yyyymmdd_HHMMSS'));
copyfile([modelName '.slx'], bak);
fprintf('Backup saved: %s\n', bak);

if bdIsLoaded(modelName), close_system(modelName, 0); end
load_system(modelName);

code = fileread(fullfile(here, 'line_tracking_controller_v2.txt'));
rt = sfroot;
chart = rt.find('-isa', 'Stateflow.EMChart', 'Path', [modelName '/Line_Tracking_Controller']);
assert(~isempty(chart), 'Line_Tracking_Controller block not found');
chart.Script = code;
chart.ChartUpdate = 'DISCRETE';
chart.SampleTime = '0.01';
save_system(modelName);
disp('Controller v2 written and model saved.');

disp('Running 0.2 s compile check ...');
simOut = sim(modelName, 'StopTime', '0.2'); %#ok<NASGU>
disp('>>> Compile check passed. Now run verify_line_follow.m for the full lap. <<<');
