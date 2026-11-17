% check_ps_params.m
clear; clc;
load_system('nesl_utility');
dp = get_param('nesl_utility/Simulink-PS Converter', 'DialogParameters');
disp('Simulink-PS Converter parameters:');
f = fieldnames(dp);
disp(f(contains(lower(f), 'filter') | contains(lower(f), 'input') | contains(lower(f), 'time') | contains(lower(f), 'handling')));
