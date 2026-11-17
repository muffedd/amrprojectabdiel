% inspect_ts_conn.m
clear; clc;
load_system('sm_lib');
sys = 'test_ts_model2';
new_system(sys);
ts = [sys, '/TS'];
add_block('sm_lib/Frames and Transforms/Transform Sensor', ts);
set_param(ts, 'SenseXYZ', 'on', 'SenseRotationSequence', 'on', 'RotationSequence', 'ZYX');

pc = get_param(ts, 'PortConnectivity');
for i = 1:length(pc)
    fprintf('Port %d: Type=%s\n', i, pc(i).Type);
end

close_system(sys, 0);
