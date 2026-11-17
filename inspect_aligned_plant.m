% inspect_aligned_plant.m
evalin('base', 'run(''AGV_DataFile.m'')');
load_system('AGV_Aligned_Plant');

blks = find_system('AGV_Aligned_Plant', 'SearchDepth', 1);
for i = 1:length(blks)
    b = blks{i};
    if strcmp(b, 'AGV_Aligned_Plant'), continue; end
    disp(['Block: ', b, ' (Type: ', get_param(b, 'BlockType'), ')']);
    if strcmp(get_param(b, 'BlockType'), 'Reference')
        disp(['   SourceBlock: ', get_param(b, 'SourceBlock')]);
    end
    if contains(b, 'Transform')
        disp(['   RotMethod: ', get_param(b, 'RotationMethod')]);
        try disp(['   RotMat: ', get_param(b, 'RotationMatrix')]); end
        disp(['   TransMethod: ', get_param(b, 'TranslationMethod')]);
        try disp(['   TransVec: ', get_param(b, 'TranslationCartesianOffset')]); end
    end
    if contains(b, 'Mechanism')
        disp(['   Gravity: ', get_param(b, 'GravityVector')]);
    end
end
