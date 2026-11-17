% find_dwa_transforms_in_smidata.m
clear; clc;
evalin('base', 'run(''AGV_DataFile.m'')');

% Let's see all fields and transforms in smiData
% In AGV.xml, let's find the transforms of Drive_Wheel_Assembly_STEP_1 to 4!
xml = fileread('AGV.xml');
lines = splitlines(xml);
for i = 1:length(lines)
    line = lines{i};
    if contains(line, 'Drive_Wheel_Assembly_STEP') && contains(line, '<Instance')
        disp(strtrim(line));
        % Print next 10 lines
        for j = 1:10
            if (i+j) <= length(lines)
                disp(['   ', strtrim(lines{i+j})]);
            end
        end
    end
end
