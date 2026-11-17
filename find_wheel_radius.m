% find_wheel_radius.m
f = 'Mecanum Wheel.STEP_Default_sldprt.STEP';
txt = fileread(f);
lines = splitlines(txt);

% Center of axle in X, Y
x0 = -0.1454990063668878;
y0 = 0.0751741789496352;

% Find all CARTESIAN_POINT
pt_lines = lines(contains(lines, 'CARTESIAN_POINT'));
max_r = 0;
min_z = Inf;
max_z = -Inf;

for i = 1:length(pt_lines)
    line = pt_lines{i};
    toks = regexp(line, 'CARTESIAN_POINT\s*\(\s*''[^'']*'',\s*\(\s*([0-9.eE+-]+)\s*,\s*([0-9.eE+-]+)\s*,\s*([0-9.eE+-]+)\s*\)\s*\)', 'tokens');
    if ~isempty(toks)
        x = str2double(toks{1}{1});
        y = str2double(toks{1}{2});
        z = str2double(toks{1}{3});
        r = sqrt((x - x0)^2 + (y - y0)^2);
        if r > max_r && r < 0.5 % ignore any bounding box outliers if any
            max_r = r;
        end
        if z < min_z, min_z = z; end
        if z > max_z, max_z = z; end
    end
end

fprintf('Outer wheel radius R = %.6f m (%.2f mm)\n', max_r, max_r * 1000);
fprintf('Wheel axial width Z range: [%.6f, %.6f] m (width = %.2f mm)\n', min_z, max_z, (max_z - min_z) * 1000);
