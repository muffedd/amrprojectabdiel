% print_dwa_instances.m
clear; clc;
xml = fileread('AGV.xml');
for k = 1:4
    target = sprintf('name="Drive Wheel Assembly.STEP-%d"', k);
    pos = strfind(xml, target);
    if ~isempty(pos)
        chunk = xml(pos(1):pos(1)+600);
        disp(['=== DWA ', num2str(k), ' ===']);
        disp(chunk(1:min(500, length(chunk))));
    end
end
