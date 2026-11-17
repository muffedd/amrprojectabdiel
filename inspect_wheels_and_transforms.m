% inspect_wheels_and_transforms.m
evalin('base', 'run(''AGV_DataFile.m'')');
load_system('AGV_Aligned_Plant');

for i = 1:4
    dwa = sprintf('AGV_Aligned_Plant/AGV_STEP_1_RIGID/Drive_Wheel_Assembly_STEP_%d_RIGID', i);
    t4 = [dwa, '/Transform4'];
    disp(['=== DWA ', num2str(i), ' Transform4 ===']);
    try disp(['RotMethod: ', get_param(t4, 'RotationMethod')]); end
    try disp(['RotMatrix: ', mat2str(eval(get_param(t4, 'RotationMatrix')))]); end
    try disp(['TransMethod: ', get_param(t4, 'TranslationMethod')]); end
    try disp(['TransVec: ', mat2str(eval(get_param(t4, 'TranslationVector')))]); end
end

mw = 'AGV_Aligned_Plant/AGV_STEP_1_RIGID/Drive_Wheel_Assembly_STEP_1_RIGID/Mecanum_Wheel_STEP_1_RIGID';
lines = get_param(mw, 'Lines');
disp('=== Lines inside Mecanum_Wheel_STEP_1_RIGID ===');
for i = 1:length(lines)
    s = lines(i).SrcBlock;
    d = lines(i).DstBlock;
    if ~isempty(s), sn = get_param(s, 'Name'); else, sn = 'none'; end
    if ~isempty(d), dn = get_param(d, 'Name'); else, dn = 'none'; end
    disp([sn, ' (', lines(i).SrcPort, ') -> ', dn, ' (', lines(i).DstPort, ')']);
end

rf = [mw, '/ReferenceFrame'];
disp('=== ReferenceFrame inside Mecanum_Wheel ===');
try disp(get_param(rf, 'DialogParameters')); end
solid = [mw, '/Solid'];
disp('=== Solid inside Mecanum_Wheel ===');
disp(['GeometryFile: ', get_param(solid, 'ExtGeomFileName')]);

