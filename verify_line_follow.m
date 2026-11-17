% verify_line_follow.m  - full-lap run, prints deviation from the black line and plots path
clear; clc;
modelName = 'AGV_Warehouse_Sim';
evalin('base', 'run(''AGV_DataFile.m'')');
load_system(modelName);
T = 120;   % s, about one lap with 3 stops
simOut = sim(modelName, 'StopTime', num2str(T));

xy = squeeze(simOut.xy_log.Data);
if size(xy,1) == 2 && size(xy,2) ~= 2, xy = xy'; end
t  = simOut.xy_log.Time;
X = xy(:,1); Y = xy(:,2);

% shortest distance from AGV centre to the rectangular track (x=+-5, y=+-3)
dx = max(abs(X) - 5, 0); dy = max(abs(Y) - 3, 0);
outside = dx > 0 | dy > 0;
d = hypot(dx, dy);
d(~outside) = min(5 - abs(X(~outside)), 3 - abs(Y(~outside)));

k = t > 3;   % ignore first 3 s (start-up)
fprintf('Max deviation from line : %.3f m\n', max(d(k)));
fprintf('RMS deviation from line : %.3f m\n', sqrt(mean(d(k).^2)));
fprintf('Distance driven         : %.1f m\n', sum(hypot(diff(X), diff(Y))));

figure('Name', 'AGV path vs line'); hold on; axis equal; grid on;
plot([-5 5 5 -5 -5], [-3 -3 3 3 -3], 'k-', 'LineWidth', 3);
plot(X, Y, 'r-', 'LineWidth', 1.2);
plot([0 5 -2.5], [-3 0 3], 'bo', 'MarkerSize', 10, 'LineWidth', 2);
legend('Black line', 'AGV path', 'Stations'); xlabel('X (m)'); ylabel('Y (m)');
figure('Name', 'Deviation'); plot(t, d); grid on; xlabel('t (s)'); ylabel('distance to line (m)');
