% check_ps_filter_val.m
clear; clc;
load_system('nesl_utility');
fprintf('FilteringAndDerivatives: %s\n', get_param('nesl_utility/Simulink-PS Converter', 'FilteringAndDerivatives'));
fprintf('InputFilterTimeConstant: %s\n', get_param('nesl_utility/Simulink-PS Converter', 'InputFilterTimeConstant'));
