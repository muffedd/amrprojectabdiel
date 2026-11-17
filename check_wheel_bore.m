% check_wheel_bore.m
f = 'Mecanum Wheel.STEP_Default_sldprt.STEP';
txt = fileread(f);
lines = splitlines(txt);

% Find all CYLINDRICAL_SURFACE
cyl_idx = find(contains(lines, 'CYLINDRICAL_SURFACE'));
disp(['Found ', num2str(length(cyl_idx)), ' cylindrical surfaces.']);

% Let's look at the radii and axes of the cylindrical surfaces:
for k = 1:min(15, length(cyl_idx))
    line = lines{cyl_idx(k)};
    toks = regexp(line, 'CYLINDRICAL_SURFACE\s*\(\s*''[^'']*'',\s*#(\d+),\s*([0-9.eE+-]+)\s*\)', 'tokens');
    if ~isempty(toks)
        axis_id = toks{1}{1};
        radius = str2double(toks{1}{2});
        % find axis2_placement_3d
        pattern = ['^#', axis_id, '\s*=\s*AXIS2_PLACEMENT_3D'];
        ax_line = lines{find(~cellfun(@isempty, regexp(lines, pattern)), 1)};
        % get location and dir
        toks2 = regexp(ax_line, 'AXIS2_PLACEMENT_3D\s*\(\s*''[^'']*'',\s*#(\d+),\s*#(\d+)', 'tokens');
        if ~isempty(toks2)
            pt_id = toks2{1}{1};
            dir_id = toks2{1}{2};
            pt_line = lines{find(~cellfun(@isempty, regexp(lines, ['^#', pt_id, '\s*=\s*CARTESIAN_POINT'])), 1)};
            dir_line = lines{find(~cellfun(@isempty, regexp(lines, ['^#', dir_id, '\s*=\s*DIRECTION'])), 1)};
            disp(['Radius: ', num2str(radius), ' m | AxLine: ', ax_line]);
            disp(['   Pt: ', pt_line]);
            disp(['   Dir: ', dir_line]);
        end
    end
end
