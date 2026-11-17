% check_measurement_frame.m
clear; clc;
load_system('sm_lib');
ts = 'sm_lib/Frames and Transforms/Transform Sensor';
dp = get_param(ts, 'DialogParameters');
disp('Measurement frame or related params:');
f = fieldnames(dp);
disp(f(contains(lower(f), 'frame') | contains(lower(f), 'coord')));
try
    disp(['Current MeasurementFrame: ', get_param(ts, 'MeasurementFrame')]);
catch
end
