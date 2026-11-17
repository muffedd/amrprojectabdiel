% find_vertex_radius.m
f = 'Mecanum Wheel.STEP_Default_sldprt.STEP';
txt = fileread(f);
lines = splitlines(txt);

x0 = -0.1454990063668878;
y0 = 0.0751741789496352;

% Find VERTEX_POINT lines
v_lines = lines(contains(lines, 'VERTEX_POINT'));
pt_ids = regexp(v_lines, 'VERTEX_POINT\s*\(\s*''[^'']*'',\s*#(\d+)\s*\)', 'tokens');
pt_ids = [pt_ids{:}];
pt_ids = cellfun(@(c) c{1}, pt_ids, 'UniformOutput', false);
pt_map = containers.Map();
for i = 1:length(pt_ids)
    pt_map(pt_ids{i}) = true;
end

disp(['Found ', num2str(pt_map.Count), ' unique vertex points.']);

max_r = 0;
min_z = Inf;
max_z = -Inf;

for i = 1:length(lines)
    line = lines{i};
    toks = regexp(line, '^#(\d+)\s*=\s*CARTESIAN_POINT\s*\(\s*''[^'']*'',\s*\(\s*([0-9.eE+-]+)\s*,\s*([0-9.eE+-]+)\s*,\s*([0-9.eE+-]+)\s*\)\s*\)', 'tokens');
    if ~isempty(toks)
        id = toks{1}{1};
        if isKey(pt_map, id)
            x = str2double(toks{1}{2});
            y = str2double(toks{1}{3});
            z = str2double(toks{1}{4});
            r = sqrt((x - x0)^2 + (y - y0)^2);
            if r > max_r, max_r = r; end
            if z < min_z, min_z = z; end
            if z > max_z, max_z = z; end
        end
    end
end

fprintf('Actual Physical Vertex Outer Radius R = %.6f m (%.2f mm)\n', max_r, max_r * 1000);
fprintf('Actual Physical Vertex Z range: [%.6f, %.6f] m (width = %.2f mm)\n', min_z, max_z, (max_z - min_z) * 1000);
