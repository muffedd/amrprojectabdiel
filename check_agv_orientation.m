% check_agv_orientation.m
clear; clc;
evalin('base', 'run(''AGV_DataFile.m'')');
load_system('AGV_Warehouse_Sim');

% Let's inspect the positions of DWA 1, 2, 3, 4 and Front Casing and Rear
% We can use simscape.multibody or inspect the RigidTransform translations
disp('Rigid transforms for key parts:');
% In AGV.xml or smiData:
% Let's look for part names in AGV.xml
xml = fileread('AGV.xml');
% Find where Front Casing, Bottom Casing, Drive Motor, DWA 1, 2, 3, 4 are
lines = splitlines(xml);
for i = 1:length(lines)
    if contains(lines{i}, 'Drive_Wheel') || contains(lines{i}, 'Front Casing') || ...
       contains(lines{i}, 'Front Back') || contains(lines{i}, 'SICK')
        disp(strtrim(lines{i}));
    end
end
