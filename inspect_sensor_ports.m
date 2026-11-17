% inspect_sensor_ports.m
clear; clc;
load_system('sm_lib');
ts_props = simscape.connectionPortProperties('sm_lib/Frames and Transforms/Transform Sensor');
disp('Transform Sensor ports:');
for i = 1:length(ts_props)
    fprintf('  Port %d: %s, Type: %s, Desc: %s\n', i, ts_props(i).PortName, ts_props(i).Type, ts_props(i).Description);
end

% Check dialog parameters of Transform Sensor
dp = get_param('sm_lib/Frames and Transforms/Transform Sensor', 'DialogParameters');
disp('Relevant dialog params:');
f = fieldnames(dp);
disp(f(contains(f, 'Sense') | contains(f, 'Frame') | contains(f, 'Sequence')));

% Check Joint_6DOF parameters
j6_props = simscape.connectionPortProperties('sm_lib/Joints/6-DOF Joint');
disp('6-DOF Joint ports:');
for i = 1:length(j6_props)
    fprintf('  Port %d: %s, Type: %s\n', i, j6_props(i).PortName, j6_props(i).Type);
end
