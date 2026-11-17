% verify_discrete_settings.m
clear; clc;
evalin('base', 'run(''AGV_DataFile.m'')');
load_system('AGV_Warehouse_Sim');

rt = sfroot;
charts = rt.find('-isa', 'Stateflow.EMChart');
for i = 1:length(charts)
    if contains(charts(i).Path, 'Line_Tracking_Controller')
        fprintf('Chart: %s\n', charts(i).Path);
        fprintf('  ChartUpdate: %s\n', charts(i).ChartUpdate);
        fprintf('  SampleTime:  %s\n', charts(i).SampleTime);
    end
end

close_system('AGV_Warehouse_Sim', 0);
