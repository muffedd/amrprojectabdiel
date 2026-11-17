% inspect_ts_ports.m
clear; clc;
load_system('sm_lib');
sys = 'test_ts_model';
new_system(sys);
ts = [sys, '/TS'];
add_block('sm_lib/Frames and Transforms/Transform Sensor', ts);
set_param(ts, 'SenseXYZ', 'on', 'SenseRotationSequence', 'on', 'RotationSequence', 'ZYX');

ph = get_param(ts, 'PortHandles');
fprintf('LConn count: %d, RConn count: %d\n', length(ph.LConn), length(ph.RConn));

props = simscape.connectionPortProperties(ts);
for i = 1:length(props)
    fprintf('Port %d: Name=%s, Type=%s\n', i, props(i).PortName, props(i).Type);
end

close_system(sys, 0);
