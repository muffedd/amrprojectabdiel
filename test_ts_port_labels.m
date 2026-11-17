% test_ts_port_labels.m
clear; clc;
load_system('sm_lib');
sys = 'test_ts_port_labels';
new_system(sys);
ts = [sys, '/TS'];
add_block('sm_lib/Frames and Transforms/Transform Sensor', ts);

% Case 1: only SenseXYZ = on
set_param(ts, 'SenseXYZ', 'on', 'SenseRotationSequence', 'off');
ph1 = get_param(ts, 'PortHandles');
fprintf('Only SenseXYZ: LConn=%d, RConn=%d\n', length(ph1.LConn), length(ph1.RConn));

% Case 2: only SenseRotationSequence = on
set_param(ts, 'SenseXYZ', 'off', 'SenseRotationSequence', 'on');
ph2 = get_param(ts, 'PortHandles');
fprintf('Only SenseRotSeq: LConn=%d, RConn=%d\n', length(ph2.LConn), length(ph2.RConn));

% Case 3: both
set_param(ts, 'SenseXYZ', 'on', 'SenseRotationSequence', 'on');
ph3 = get_param(ts, 'PortHandles');
fprintf('Both: LConn=%d, RConn=%d\n', length(ph3.LConn), length(ph3.RConn));

close_system(sys, 0);
